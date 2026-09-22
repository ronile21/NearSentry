plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nearsentry.app"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nearsentry.app"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.0.0.1"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(project(":sentry"))
    implementation("androidx.biometric:biometric:1.1.0")
}
