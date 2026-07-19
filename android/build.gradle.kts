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