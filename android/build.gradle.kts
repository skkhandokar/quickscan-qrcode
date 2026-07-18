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

// সাবপ্রজেক্টের missing namespace সমস্যা দূর করার জন্য নিরাপদ ও কার্যকরী কোড
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

// wifi_connector এর Manifest থেকে package="..." অ্যাট্রিবিউটের এরর বাইপাস করার সোয়াপ ট্রিক
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

// জাভা, কোটলিন কমপ্যাটিবিলিটি এবং ওল্ড প্লাগইনের compileSdk কনф্লিক্ট দূর করার টাইপ-সেফ মেথড
subprojects {
    // ১. ওল্ড প্লাগইনগুলোর compileSdkVersion এবং targetSdkVersion রানটাইমে ওভাররাইড করা
    plugins.withType(com.android.build.gradle.api.AndroidBasePlugin::class.java) {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                // সরাসরি জাভা রিফ্লেকশন ব্যবহার করে সেট করা, যাতে গ্রেডল তার নিজস্ব মেথডের সাথে গুলিয়ে না ফেলে
                try {
                    val setCompileSdkVersionMethod = android.javaClass.getMethod("setCompileSdkVersion", Int::class.java)
                    setCompileSdkVersionMethod.invoke(android, 34)
                } catch (e: Exception) {
                    try {
                        val setCompileSdkMethod = android.javaClass.getMethod("setCompileSdk", Int::class.java)
                        setCompileSdkMethod.invoke(android, 34)
                    } catch (ignored: Exception) {}
                }
                
                // targetSdkVersion ৩৪ এ লক করা
                val defaultConfig = android.javaClass.getMethod("getDefaultConfig").invoke(android)
                try {
                    defaultConfig.javaClass.getMethod("setTargetSdkVersion", Any::class.java).invoke(defaultConfig, 34)
                } catch (e: Exception) {
                    try {
                        defaultConfig.javaClass.getMethod("setTargetSdk", Int::class.java).invoke(defaultConfig, 34)
                    } catch (ignored: Exception) {}
                }
            } catch (e: Exception) {
                // মেথড ইনভোকেশন ফেইল করলে সেফলি এড়িয়ে যাবে
            }

            // ২. জাভা কমপ্যাটিবিলিটি ১৭ সেট করা
            try {
                val compileOptions = android.javaClass.getMethod("getCompileOptions").invoke(android)
                compileOptions.javaClass.getMethod("setSourceCompatibility", Any::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions.javaClass.getMethod("setTargetCompatibility", Any::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
            } catch (e: Exception) {
                // ব্যাকআপ ট্রিক
            }
        }
    }

    // ৩. কোটলিন টাস্কগুলোর জন্য রানটাইম স্ট্রিং প্রোপার্টি দিয়ে JVM Target 17 ফিক্স
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
                    // ওল্ড কোটলিন প্লাগইন ব্যাকআপ প্রোপার্টি ওভাররাইড (Groovy টাইপ এড়িয়ে সরাসরি মেথড কল)
                    val kotlinOptions = this.javaClass.getMethod("getKotlinOptions").invoke(this)
                    kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java).invoke(kotlinOptions, "17")
                } catch (ignored: Exception) {
                    try {
                        val compilerOptions = this.javaClass.getMethod("getCompilerOptions").invoke(this)
                        val jvmTargetProp = compilerOptions.javaClass.getMethod("getJvmTarget")
                        val jvmTargetObj = jvmTargetProp.invoke(compilerOptions)
                        jvmTargetObj.javaClass.getMethod("set", String::class.java).invoke(jvmTargetObj, "17")
                    } catch (lastHope: Exception) {}
                }
            }
        }
    }
}