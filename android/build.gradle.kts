// ১. সমস্ত সাবপ্রজেক্টের জাভা এবং কোটলিন টাস্ককে একসাথে জাভা ১৭ সংস্করণে লক করার গ্লোবাল টুলচেইন
subprojects {
    plugins.withType(org.gradle.api.plugins.JavaPlugin::class.java) {
        extensions.configure<org.gradle.api.plugins.JavaPluginExtension>("java") {
            toolchain {
                languageVersion.set(JavaLanguageVersion.of(17))
            }
        }
    }
}

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

// সাবপ্রজেক্টের missing namespace সমস্যা দূর করার সেফ কোড
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