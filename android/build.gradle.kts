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
    // নেমস্পেস সেট করার মূল লজিক
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
                // কোনো মেথড বা কাস্টিং সমস্যা হলে তা এড়িয়ে যাবে
            }
        }
    }

    // প্রজেক্ট অলরেডি ইভালুয়েট হয়ে গেলে সরাসরি রান করবে, নয়তো afterEvaluate এর জন্য অপেক্ষা করবে
    if (project.state.executed) {
        configureNamespace()
    } else {
        project.afterEvaluate {
            configureNamespace()
        }
    }
}



subprojects {
    val currentProject = this
    // প্রোজেক্ট অলরেডি রেডি থাকলে সরাসরি কনফিগার করা
    if (currentProject.hasProperty("android") && currentProject.name == "wifi_connector") {
        val androidExtension = currentProject.extensions.findByName("android")
        if (androidExtension != null) {
            try {
                val dslNamespace = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                dslNamespace.invoke(androidExtension, "com.wonjerry.wifi_connector")
            } catch (e: Exception) {
                // রিফ্লেকশন ব্যাকআপ এরর হ্যান্ডলিং
            }
        }
    }
}