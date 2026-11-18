import java.io.FileInputStream
import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.skkhandokar.quickscan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("android/key.properties")
            val altKeystoreFile = rootProject.file("key.properties")
            
            val propFile = if (keystorePropertiesFile.exists()) keystorePropertiesFile else altKeystoreFile
            
            if (propFile.exists()) {
                val properties = Properties()
                properties.load(FileInputStream(propFile))
                
                keyAlias = properties.getProperty("keyAlias")
                keyPassword = properties.getProperty("keyPassword")
                storePassword = properties.getProperty("storePassword")
                
                val storeFileName = properties.getProperty("storeFile") ?: "quickscan-release-key.jks"
                val fileInAndroid = rootProject.file("android/$storeFileName")
                val fileInRoot = rootProject.file(storeFileName)
                
                if (fileInAndroid.exists()) {
                    storeFile = fileInAndroid
                } else if (fileInRoot.exists()) {
                    storeFile = fileInRoot
                }
            }
        }
    }

    defaultConfig {
        applicationId = "com.skkhandokar.quickscan"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}