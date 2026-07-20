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

// ১. সাবপ্রজেক্টের missing namespace সমস্যা দূর করার সেফ কোড
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
            } catch (e: Exception) {}
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
                } catch (e: Exception) {}
            }
        }
    }
}

// ৩. 🎯 ব্রহ্মাস্ত্র: গ্রেডল লাইফসাইকেল ইন্টারসেপ্টর (জাভা ও কোটলিন উভয়কে Genuine Java 11-এ লক করার সমাধান)
gradle.projectsEvaluated {
    rootProject.subprojects {
        // সব অ্যান্ড্রয়েড সাবপ্রজেক্টের কমপাইল অপশন ১১ এ ফিক্স করা
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            try {
                val compileOptionsObj = androidExt.javaClass.getMethod("getCompileOptions").invoke(androidExt)
                compileOptionsObj.javaClass.getMethod("setSourceCompatibility", Any::class.java).invoke(compileOptionsObj, JavaVersion.VERSION_11)
                compileOptionsObj.javaClass.getMethod("setTargetCompatibility", Any::class.java).invoke(compileOptionsObj, JavaVersion.VERSION_11)
            } catch (e: Exception) {}
        }

        // সমস্ত কম্পাইল টাস্ক এক্সিকিউট হওয়ার ঠিক আগের মুহূর্তে রানটাইমে টার্গেট ১১ এ ফোর্স ডাউনগ্রেড করা
        tasks.configureEach {
            if (name.contains("compile", ignoreCase = true)) {
                if (name.contains("kotlin", ignoreCase = true)) {
                    try {
                        // Kotlin 2.x+ compilerOptions DSL ফিক্স
                        val compilerOptions = this.javaClass.getMethod("getCompilerOptions").invoke(this)
                        val jvmTargetProp = compilerOptions.javaClass.getMethod("getJvmTarget")
                        val jvmTargetObj = jvmTargetProp.invoke(compilerOptions)
                        val setMethod = jvmTargetObj.javaClass.getMethod("set", Any::class.java)
                        
                        val jvmTargetEnumClass = Class.forName("org.jetbrains.kotlin.gradle.dsl.JvmTarget")
                        val jvmTargetValue = jvmTargetEnumClass.getField("JVM_11").get(null) // ১১ এ সিঙ্ক
                        setMethod.invoke(jvmTargetObj, jvmTargetValue)
                    } catch (e: Exception) {
                        try {
                            val kotlinOptions = this.javaClass.getMethod("getKotlinOptions").invoke(this)
                            kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java).invoke(kotlinOptions, "11")
                        } catch (ignored: Exception) {}
                    }
                } else if (name.contains("java", ignoreCase = true)) {
                    try {
                        val setTargetCompatibilityMethod = this.javaClass.getMethod("setTargetCompatibility", String::class.java)
                        setTargetCompatibilityMethod.invoke(this, "11")
                        val setSourceCompatibilityMethod = this.javaClass.getMethod("setSourceCompatibility", String::class.java)
                        setSourceCompatibilityMethod.invoke(this, "11")
                    } catch (ignored: Exception) {}
                }
            }
        }
    }
}