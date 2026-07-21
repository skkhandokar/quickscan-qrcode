import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keyPropsFileInAndroid = rootProject.file("android/key.properties")
val keyPropsFileInRoot = rootProject.file("key.properties")

if (keyPropsFileInAndroid.exists()) {
    keystoreProperties.load(FileInputStream(keyPropsFileInAndroid))
} else if (keyPropsFileInRoot.exists()) {
    keystoreProperties.load(FileInputStream(keyPropsFileInRoot))
}

android {
    namespace = "com.skkhandokar.quickscan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            
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

        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // রিলিজ ক্র্যাশ রোধ করতে class/resource shrink রাখা হয়েছে false
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