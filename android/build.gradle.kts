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

// ওল্ড প্লাগইনের ম্যানিফেস্ট ফাইলটিকে আমাদের কাস্টম ফ্রেশ ফাইল দিয়ে সোয়াপ করার চূড়ান্ত ট্রিক
subprojects {
    val currentProject = this
    if (currentProject.name == "wifi_connector") {
        plugins.withType(com.android.build.gradle.api.AndroidBasePlugin::class.java) {
            val androidExtension = currentProject.extensions.findByName("android")
            if (androidExtension != null) {
                try {
                    // ডাইরেক্ট প্লাগইনের সোর্স সেট ওভাররাইড করা
                    val sourceSets = androidExtension.javaClass.getMethod("getSourceSets").invoke(androidExtension)
                    val mainSourceSet = sourceSets.javaClass.getMethod("getByName", String::class.java).invoke(sourceSets, "main")
                    val manifest = mainSourceSet.javaClass.getMethod("getManifest").invoke(mainSourceSet)
                    
                    // আমাদের তৈরি করা কাস্টম ফাইলের পাথ ধরিয়ে দেওয়া
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





// সব সাব-প্রজেক্ট এবং প্লাগইনের জাভা ও কোটলিন কম্পাইলার টার্গেট ১৭-এ লক করার কোড
subprojects {
    tasks.withType(org.jetbrains.kotlin.graphql.plugin.tasks.KotlinCompile::class.java).configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
    
    // ব্যাকআপ হিসেবে অল্টারনেটিভ কোটলিন টাস্ক হ্যান্ডেল করার জন্য
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }

    plugins.withType(com.android.build.gradle.api.AndroidBasePlugin::class.java) {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val compileOptions = android::class.java.getMethod("getCompileOptions").invoke(android)
                compileOptions::class.java.getMethod("setSourceCompatibility", Any::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions::class.java.getMethod("setTargetCompatibility", Any::class.java).invoke(compileOptions, JavaVersion.VERSION_17)
            } catch (e: Exception) {
                // রিফ্লেকশন ব্যাকআপ হ্যান্ডলিং
            }
        }
    }
}