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

// Run AFTER all subprojects are evaluated to avoid "already evaluated" errors
// and "not yet finalized" errors when reading compileOptions properties.
gradle.projectsEvaluated {
    allprojects {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            ?: return@allprojects

        // Inject compileSdkVersion=34 for older plugins that omit it (e.g. audio_session 0.1.x)
        try {
            @Suppress("DEPRECATION")
            if (android.compileSdkVersion == null) {
                android.compileSdkVersion(34)
            }
        } catch (_: Exception) {
            android.compileSdkVersion(34)
        }

        // Inject namespace for plugins that predate AGP 7.3 namespace requirement
        if (android.namespace == null) {
            android.namespace = when (name) {
                "speech_to_text"               -> "com.csdcorp.speech_to_text"
                "audio_session"                -> "com.ryanheise.audio_session"
                "just_audio"                   -> "com.ryanheise.just_audio"
                "flutter_local_notifications"  -> "com.dexterous.flutterlocalnotifications"
                "permission_handler"           -> "com.baseflow.permissionhandler"
                "permission_handler_android"   -> "com.baseflow.permissionhandler"
                "device_info_plus"             -> "dev.fluttercommunity.plus.device_info"
                "package_info_plus"            -> "dev.fluttercommunity.plus.package_info"
                "file_picker"                  -> "com.mr.flutter.plugin.filepicker"
                "open_filex"                   -> "com.example.open_filex"
                "shared_preferences_android"   -> "io.flutter.plugins.sharedpreferences"
                "sqflite_android"              -> "io.flutter.plugins.sqflite"
                "url_launcher_android"         -> "io.flutter.plugins.urllauncher"
                "path_provider_android"        -> "io.flutter.plugins.pathprovider"
                "syncfusion_flutter_pdfviewer" -> "com.syncfusion.flutter.pdfviewer"
                "syncfusion_flutter_pdf"       -> "com.syncfusion.flutter.pdf"
                else -> "com.nova.${name.replace("-", "_")}"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
