import java.util.Properties
import java.io.File

pluginManagement {
    val flutterSdkPath = run {
        val properties = Properties()
        val localPropertiesFile = File("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { properties.load(it) }
        }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.6.0" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

val newBuildDir: File = rootProject.layout.buildDirectory.asFile.get().parentFile.parentFile.resolve("build")
rootProject.layout.buildDirectory.set(newBuildDir.asDirectory)

subprojects {
    val newSubprojectBuildDir: File = newBuildDir.resolve(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir.asDirectory)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}