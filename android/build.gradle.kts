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

// ১. সাবপ্রজেক্টের missing namespace সমস্যা দূর করার সেফ কোড (afterEvaluate ডেডলক মুক্ত)
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
                // ইগনোরড
            }
        }
    }

    if (project.state.executed) {
        configureNamespace()
    } else {
        project.afterEvaluate {
            try { configureNamespace() } catch(e: Exception) {}
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
                    // ইগনোরড
                }
            }
        }
    }
}

// ৩. জাভা, কোটলিন কমপ্যাটিবিলিটি, ওল্ড প্লাগইনের compileSdk এবং JVM Target কনফ্লিক্ট মেটানোর চূড়ান্ত সমাধান (afterEvaluate মুক্ত)
// ৩. জাভা, কোটলিন, ওল্ড প্লাগইনের compileSdk এবং JVM Target কনф্লিক্ট মেটানোর চূড়ান্ত ফুলপ্রুফ টুলচেইন ফিক্স
subprojects {
    val currentProject = this
    
    // অ্যান্ড্রয়েড বেস প্লাগইন ট্র্যাকিং এবং SDK ৩৪ এলিভেশন
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

                    // অ্যান্ড্রেয়েড কমপাইল অপশন গ্লোবালি জাভা ১৭ এ সিঙ্ক
                    val getCompileOptions = androidExt.javaClass.getMethod("getCompileOptions")
                    val compileOptionsObj = getCompileOptions.invoke(androidExt)
                    compileOptionsObj.javaClass.getMethod("setSourceCompatibility", Any::class.java).invoke(compileOptionsObj, JavaVersion.VERSION_17)
                    compileOptionsObj.javaClass.getMethod("setTargetCompatibility", Any::class.java).invoke(compileOptionsObj, JavaVersion.VERSION_17)
                }
            } catch (ignored: Exception) {}
        }
        false
    }

    // ১. গ্রেডল জাভা টাস্কগুলোর (compileJavaWithJavac) ভেতরের ইন্টারনাল অপশন ভেঙে জাভা ১৭ ফোর্স করা
    tasks.withType(JavaCompile::class.java).configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
        options.compilerArgs.addAll(listOf("-source", "17", "-target", "17"))
        
        // যদি গ্রেডল টুলচেইন কনফিগারড থাকে, সেটারও ল্যাঙ্গুয়েজ ভার্সন ১৭ এ ফোর্স করা
        try {
            val toolchainMethod = this.javaClass.getMethod("getToolchain")
            val toolchainObj = toolchainMethod.invoke(this)
            toolchainObj.javaClass.getMethod("getLanguageVersion").let { versionProp ->
                val versionObj = versionProp.invoke(toolchainObj)
                versionObj.javaClass.getMethod("set", Any::class.java).invoke(versionObj, org.gradle.jvm.toolchain.JavaLanguageVersion.of(17))
            }
        } catch (ignored: Exception) {}
    }

    // ২. কোটলিন কম্পাইলার টাস্কগুলোর জন্য রানটাইম প্রোপার্টি দিয়ে JVM Target 17 ফিক্স (কোনো টাইপ কনফ্লিক্ট ছাড়া)
    tasks.configureEach {
        if (name.contains("compile", ignoreCase = true) && name.contains("kotlin", ignoreCase = true)) {
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
        }
    }
}