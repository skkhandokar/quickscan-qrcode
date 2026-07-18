allprojects {
    repositories {
        google()
        central()
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

// wifi_connector এর Manifest Incorrect Package এরর বাইপাস করার জন্য চূড়ান্ত রুলস
subprojects {
    val currentProject = this
    
    // অ্যান্ড্রয়েড বেস প্লাগইন লোড হওয়ার সাথে সাথে এটি এক্সিকিউট হবে
    currentProject.plugins.withType(com.android.build.gradle.api.AndroidBasePlugin::class.java) {
        
        // আমাদের টার্গেটেড প্লাগইনটি চেক করা
        if (currentProject.name == "wifi_connector") {
            
            // লাইব্রেরি ম্যানিফেস্ট প্রসেস করার টাস্কটি খুঁজে বের করা
            currentProject.tasks.withType(com.android.build.gradle.tasks.ProcessLibraryManifest::class.java).configureEach {
                try {
                    // গ্রেডল ৮+ এর কড়া গাইডলাইন চেকটিকে ফোর্সফুলি বাইপাস করা
                    val bypassField = this.javaClass.getMethod("setIsBypassNamespaceCheck", Boolean::class.java)
                    bypassField.invoke(this, true)
                } catch (e: Exception) {
                    try {
                        // গ্রেডলের ইন্টারনাল ফিল্ডের ভিন্ন নামের জন্য অল্টারনেটিভ ব্যাকআপ ট্রিক
                        val alternativeField = this.javaClass.getField("isBypassNamespaceCheck")
                        alternativeField.set(this, true)
                    } catch (ignored: Exception) {
                        // কোনো কারণে মেথড ম্যাচ না করলে ক্র্যাশ এড়াতে
                    }
                }
            }
        }
    }
}