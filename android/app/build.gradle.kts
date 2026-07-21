import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin অবশ্যই Android এবং Kotlin-এর পরে থাকবে
    id("dev.flutter.flutter-gradle-plugin")
}

// ---- ১. key.properties ফাইলটি রিড করার নিখুঁত লজিক ----
val keystoreProperties = Properties()
// android/key.properties অথবা root এর key.properties দুটোই নিরাপদে চেক করবে
val keyPropsFileInAndroid = rootProject.file("android/key.properties")
val keyPropsFileInRoot = rootProject.file("key.properties")

if (keyPropsFileInAndroid.exists()) {
    keystoreProperties.load(FileInputStream(keyPropsFileInAndroid))
} else if (keyPropsFileInRoot.exists()) {
    keystoreProperties.load(FileInputStream(keyPropsFileInRoot))
}

android {
    namespace = "com.skkhandokar.quickscan" // Kotlin-এ সবসময় ডাবল কোটেশন ("") হবে
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ---- ২. রিলিজ সাইনিং কনফিগারেশন ব্লক (পাথ ডুপ্লিকেশন ফিক্সড) ----
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            
            // keystore ফাইলটি android/ ফোল্ডারে থাকলে সরাসরি খুঁজে পাওয়ার লজিক
            storeFile = keystoreProperties.getProperty("storeFile")?.let { fileName ->
                val fileInAndroid = rootProject.file("android/$fileName")
                val fileInRoot = rootProject.file(fileName)
                
                if (fileInAndroid.exists()) fileInAndroid else fileInRoot
            }
            
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.skkhandokar.quickscan"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ---- ৩. রিলিজ সাইনিং কানেক্ট করা হলো ----
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

// ==================================================================================
// 🛠️ গ্লোবাল কম্পাইলার রুল: আপনার অ্যাপ এবং সমস্ত ওল্ড/নিউ প্লাগইনের JVM Target সিঙ্ক করার কোড
// ==================================================================================
rootProject.subprojects {
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    tasks.withType(JavaCompile::class.java).configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
}