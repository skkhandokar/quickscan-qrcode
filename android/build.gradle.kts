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

// wifi_connector এর Manifest থেকে package="..." অ্যাট্রিবিউট রানটাইমে মুছে দেওয়ার কিলার ট্রিক
subprojects {
    val currentProject = this
    if (currentProject.name == "wifi_connector") {
        // ম্যানিফেস্ট প্রসেস হওয়ার ঠিক আগের মুহূর্তে এই টাস্কটি ট্রিগার হবে
        currentProject.tasks.all {
            if (name.contains("manifest", ignoreCase = true)) {
                doFirst {
                    val manifestFile = currentProject.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        var content = manifestFile.readText()
                        // যদি ফাইলে package অ্যাট্রিবিউটটি থেকে থাকে তবে তাRegex দিয়ে সম্পূর্ণ রিমুভ করে দেওয়া হবে
                        if (content.contains("package=")) {
                            content = content.replace(Regex("""package="[^"]*""""), "")
                            manifestFile.writeText(content)
                        }
                    }
                }
            }
        }
    }
}