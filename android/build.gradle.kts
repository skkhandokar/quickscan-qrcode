allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ১. সাবপ্রজেক্টের missing namespace সমস্যা দূর করার জন্য নিরাপদ ও কার্যকরী কোড
subprojects {
    val configureNamespace = {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val extensionClass = android::class.java
                val getNamespace = extensionClass.getMethod("getNamespace")
                val namespace = getNamespace.invoke(android) as? String
                
                if (namespace.isNullOrEmpty()) {
                    val setNamespace = extensionClass.getMethod("setNamespace", String::class.java)
                    val safeName = project.name.replace("-", ".").replace("_", ".")
                    setNamespace.invoke(android, "com.dummy.$safeName")
                }
            } catch (e: Exception) {
                // কোনো মেথড বা কাস্টিং সমস্যা হলে তা এড়িয়ে যাবে
            }
        }
    }

    if (project.state.executed) {
        configureNamespace()
    } else {
        project.afterEvaluate {
            configureNamespace()
        }
    }
}

// ২. wifi_connector এর Manifest থেকে package="..." অ্যাট্রিবিউটের এরর বাইপাস করার সোয়াপ ট্রিক
subprojects {
    val currentProject = this
    if (currentProject.name == "wifi_connector") {
        plugins.withType(com.android.build.gradle.api.AndroidBasePlugin::class.java) {
            val androidExtension = currentProject.extensions.findByName("android")
            if (androidExtension != null) {
                try {
                    val sourceSets = androidExtension.javaClass.getMethod("getSourceSets").invoke(androidExtension)
                    val mainSourceSet = sourceSets.javaClass.getMethod("getByName", String::class.java).invoke(sourceSets, "main")
                    val manifest = mainSourceSet.javaClass.getMethod("getManifest").invoke(mainSourceSet)
                    
                    val customManifestFile = rootProject.file("app/wifi_connector_manifest/AndroidManifest.xml")
                    if (customManifestFile.exists()) {
                        manifest.javaClass.getMethod("srcFile", Any::class.java).invoke(manifest, customManifestFile)
                    }
                } catch (e: Exception) {
                    // ব্যাকআপ হ্যান্ডলিং
                }
            }
        }
    }
}

// ৩. জাভা, কোটলিন এবং ওল্ড প্লাগইনের compileSdk কনফ্লিক্ট মেটানোর চূড়ান্ত ফুলপ্রুফ মেথড
// ৩. জাভা, কোটলিন কমপ্যাটিবিলিটি, ওল্ড প্লাগইনের compileSdk এবং JVM Target কনফ্লিক্ট মেটানোর চূড়ান্ত সমাধান
subprojects {
    val currentProject = this
    
    // অ্যান্ড্রয়েড বেস প্লাগইন ট্র্যাকিং (afterEvaluate এর আগে এক্সিকিউট হবে)
    currentProject.plugins.any { plugin ->
        if (plugin.javaClass.name.startsWith("com.android.build")) {
            try {
                val androidExt = currentProject.extensions.findByName("android")
                if (androidExt != null) {
                    val methods = androidExt.javaClass.methods
                    
                    // compileSdk এবং compileSdkVersion ৩৪ এ লক করা (জাভা ১৭ সাপোর্ট করার জন্য)
                    methods.find { it.name == "setCompileSdkVersion" && it.parameterTypes.size == 1 && it.parameterTypes[0] == Int::class.java }?.invoke(androidExt, 34)
                    methods.find { it.name == "setCompileSdk" && it.parameterTypes.size == 1 && it.parameterTypes[0] == Int::class.java }?.invoke(androidExt, 34)

                    // defaultConfig এর targetSdkVersion আপডেট করা
                    val getDefaultConfig = androidExt.javaClass.getMethod("getDefaultConfig")
                    val defaultConfigObj = getDefaultConfig.invoke(androidExt)
                    defaultConfigObj.javaClass.methods.find { it.name == "setTargetSdkVersion" }?.invoke(defaultConfigObj, 34)
                    defaultConfigObj.javaClass.methods.find { it.name == "setTargetSdk" }?.invoke(defaultConfigObj, 34)

                    // সব সাবপ্রজেক্টের জাভা অপশন এবং কম্পাইলেশন লেভেল ১৭ এ ফোর্স সেট করা
                    val getCompileOptions = androidExt.javaClass.getMethod("getCompileOptions")
                    val compileOptionsObj = getCompileOptions.invoke(androidExt)
                    compileOptionsObj.javaClass.getMethod("setSourceCompatibility", Any::class.java).invoke(compileOptionsObj, JavaVersion.VERSION_17)
                    compileOptionsObj.javaClass.getMethod("setTargetCompatibility", Any::class.java).invoke(compileOptionsObj, JavaVersion.VERSION_17)
                }
            } catch (ignored: Exception) {}
        }
        false
    }

    // google_mlkit_commons সহ সব প্লাগইনের Java এবং Kotlin JVM Target সম্পূর্ণ সিঙ্ক করার জন্য Java Toolchain হুক
    currentProject.plugins.withType(org.gradle.api.plugins.JavaPlugin::class.java) {
        extensions.configure<org.gradle.api.plugins.JavaPluginExtension>("java") {
            toolchain {
                languageVersion.set(JavaLanguageVersion.of(17))
            }
        }
    }

    // কোটলিন টাস্ক কম্পাইলার অপশন সিঙ্ক্রোনাইজেশন (Java এবং Kotlin দুটিকেই জেন্যুইন ১৭ সংস্করণে লক করা)
    tasks.configureEach {
        if (name.contains("compile", ignoreCase = true)) {
            if (name.contains("kotlin", ignoreCase = true)) {
                try {
                    val compilerOptions = this.javaClass.getMethod("getCompilerOptions").invoke(this)
                    val jvmTargetProp = compilerOptions.javaClass.getMethod("getJvmTarget")
                    val jvmTargetObj = jvmTargetProp.invoke(compilerOptions)
                    val setMethod = jvmTargetObj.javaClass.getMethod("set", Any::class.java)
                    
                    val jvmTargetEnumClass = Class.forName("org.jetbrains.kotlin.gradle.dsl.JvmTarget")
                    val jvmTargetValue = jvmTargetEnumClass.getField("JVM_17").get(null)
                    setMethod.invoke(jvmTargetObj, jvmTargetValue)
                } catch (e: Exception) {
                    try {
                        val kotlinOptions = this.javaClass.getMethod("getKotlinOptions").invoke(this)
                        kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java).invoke(kotlinOptions, "17")
                    } catch (ignored: Exception) {}
                }
            } else if (name.contains("java", ignoreCase = true)) {
                // জাভা কম্পাইলার টাস্কগুলোর (যেমন compileDebugJavaWithJavac) টার্গেট ফোর্সফুলি ১৭ করা
                try {
                    val setTargetCompatibilityMethod = this.javaClass.getMethod("setTargetCompatibility", String::class.java)
                    setTargetCompatibilityMethod.invoke(this, "17")
                    val setSourceCompatibilityMethod = this.javaClass.getMethod("setSourceCompatibility", String::class.java)
                    setSourceCompatibilityMethod.invoke(this, "17")
                } catch (ignored: Exception) {}
            }
        }
    }
}