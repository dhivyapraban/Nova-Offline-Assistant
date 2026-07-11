package com.nova.nova_assistant

import android.content.Intent
import android.net.Uri
import android.view.KeyEvent
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.provider.Settings
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.os.Bundle

class MainActivity : FlutterActivity() {
    private val SYSTEM_CHANNEL   = "com.nova.nova_assistant/system"
    private val LAUNCHER_CHANNEL = "com.nova.nova_assistant/launcher"
    private val LLAMA_CHANNEL    = "com.nova.nova_assistant/llama"

    private val llamaService = LlamaService()
    private var isFlashlightOn = false
    private var pendingVoiceUiTrigger = false
    private var systemChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (intent?.getBooleanExtra("trigger_voice_ui", false) == true) {
            pendingVoiceUiTrigger = true
            try {
                stopService(Intent(this, WakeWordService::class.java))
            } catch (e: Exception) {}
        }

        // System controls channel
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL)
        systemChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isBluetoothEnabled" -> {
                    // Placeholder - requires BLUETOOTH permission
                    result.success(false)
                }
                "toggleBluetooth" -> {
                    // Placeholder - restricted on Android 13+
                    result.error("UNAVAILABLE", "Bluetooth toggle not implemented", null)
                }
                "isWifiEnabled" -> {
                    // Placeholder - requires ACCESS_WIFI_STATE
                    result.success(false)
                }
                "toggleWifi" -> {
                    // Placeholder - requires opening Settings panel on Android 10+
                    result.error("UNAVAILABLE", "WiFi toggle not implemented", null)
                }
                "isFlashlightOn" -> {
                    result.success(isFlashlightOn)
                }
                "toggleFlashlight" -> {
                    try {
                        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
                        val cameraId = cameraManager.cameraIdList[0]
                        isFlashlightOn = !isFlashlightOn
                        cameraManager.setTorchMode(cameraId, isFlashlightOn)
                        result.success(isFlashlightOn)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Flashlight not available: ${e.message}", null)
                    }
                }
                "getVolume" -> {
                    try {
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                        val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                        result.success(current.toDouble() / max.toDouble())
                    } catch (e: Exception) {
                        result.success(0.5)
                    }
                }
                "setVolume" -> {
                    try {
                        val level = call.argument<Double>("level") ?: 0.5
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                        val target = (level * max).toInt()
                        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, 0)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Volume control failed: ${e.message}", null)
                    }
                }
                "getBrightness" -> {
                    try {
                        val brightness = Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS)
                        result.success(brightness.toDouble() / 255.0)
                    } catch (e: Exception) {
                        result.success(0.5)
                    }
                }
                "setBrightness" -> {
                    // Placeholder - requires WRITE_SETTINGS permission
                    result.error("UNAVAILABLE", "Brightness control requires WRITE_SETTINGS permission", null)
                }
                "openCamera" -> {
                    try {
                        val intent = Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open camera: ${e.message}", null)
                    }
                }
                "openGallery" -> {
                    try {
                        val intent = Intent(Intent.ACTION_VIEW)
                        intent.type = "image/*"
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open gallery: ${e.message}", null)
                    }
                }
                "openCalculator" -> {
                    try {
                        val intent = Intent()
                        intent.action = Intent.ACTION_MAIN
                        intent.addCategory(Intent.CATEGORY_APP_CALCULATOR)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open calculator: ${e.message}", null)
                    }
                }
                "openSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_SETTINGS)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open settings: ${e.message}", null)
                    }
                }
                "openClock" -> {
                    try {
                        val intent = Intent(android.provider.AlarmClock.ACTION_SHOW_ALARMS).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        try {
                            val clockKeywords = listOf("clock", "alarmclock", "deskclock")
                            var launched = false
                            val packages = packageManager.getInstalledPackages(0)
                            for (pkg in packages) {
                                val pkgName = pkg.packageName.lowercase()
                                if (clockKeywords.any { pkgName.contains(it) } && !pkgName.contains("widget")) {
                                    val launchIntent = packageManager.getLaunchIntentForPackage(pkg.packageName)
                                    if (launchIntent != null) {
                                        launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                        startActivity(launchIntent)
                                        launched = true
                                        break
                                    }
                                }
                            }
                            if (launched) {
                                result.success(null)
                            } else {
                                result.error("UNAVAILABLE", "Cannot find Clock app", null)
                            }
                        } catch (ex: Exception) {
                            result.error("UNAVAILABLE", "Cannot open clock: ${ex.message}", null)
                        }
                    }
                }
                "openTimer" -> {
                    try {
                        val seconds = (call.argument<Any>("seconds") as? Number)?.toInt() ?: 300
                        val intent = Intent(android.provider.AlarmClock.ACTION_SET_TIMER).apply {
                            putExtra(android.provider.AlarmClock.EXTRA_LENGTH, seconds)
                            putExtra(android.provider.AlarmClock.EXTRA_SKIP_UI, false)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(android.provider.AlarmClock.ACTION_SHOW_ALARMS).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (ex: Exception) {
                            result.error("UNAVAILABLE", "Cannot open timer: ${e.message}", null)
                        }
                    }
                }

                "openAlarm" -> {
                    try {
                        val hour = (call.argument<Any>("hour") as? Number)?.toInt() ?: 8
                        val minute = (call.argument<Any>("minute") as? Number)?.toInt() ?: 0
                        val intent = Intent(android.provider.AlarmClock.ACTION_SET_ALARM).apply {
                            putExtra(android.provider.AlarmClock.EXTRA_HOUR, hour)
                            putExtra(android.provider.AlarmClock.EXTRA_MINUTES, minute)
                            putExtra(android.provider.AlarmClock.EXTRA_SKIP_UI, false)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open alarm: ${e.message}", null)
                    }
                }
                "openNotes" -> {
                    try {
                        val noteText = call.argument<String>("text")
                        val noteKeywords = listOf("note", "keep", "memo", "diary")
                        var launched = false
                        val packages = packageManager.getInstalledPackages(0)

                        if (noteText != null && noteText.isNotEmpty()) {
                            for (pkg in packages) {
                                val pkgName = pkg.packageName.lowercase()
                                if (noteKeywords.any { pkgName.contains(it) } && !pkgName.contains("notification")) {
                                    try {
                                        val intent = Intent(Intent.ACTION_SEND).apply {
                                            type = "text/plain"
                                            putExtra(Intent.EXTRA_TEXT, noteText)
                                            `package` = pkg.packageName
                                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                        }
                                        startActivity(intent)
                                        launched = true
                                        break
                                    } catch (ex: Exception) {
                                        // Fallback to normal launch if ACTION_SEND fails
                                    }
                                }
                            }
                            if (!launched) {
                                try {
                                    val intent = Intent(Intent.ACTION_SEND).apply {
                                        type = "text/plain"
                                        putExtra(Intent.EXTRA_TEXT, noteText)
                                        `package` = "com.google.android.keep"
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    }
                                    startActivity(intent)
                                    launched = true
                                } catch (ex: Exception) {}
                            }
                            if (!launched) {
                                try {
                                    val intent = Intent(Intent.ACTION_SEND).apply {
                                        type = "text/plain"
                                        putExtra(Intent.EXTRA_TEXT, noteText)
                                    }
                                    val chooser = Intent.createChooser(intent, "Save Note")
                                    chooser.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    startActivity(chooser)
                                    launched = true
                                } catch (ex: Exception) {}
                            }
                        } else {
                            for (pkg in packages) {
                                val pkgName = pkg.packageName.lowercase()
                                if (noteKeywords.any { pkgName.contains(it) } && !pkgName.contains("notification")) {
                                    val intent = packageManager.getLaunchIntentForPackage(pkg.packageName)
                                    if (intent != null) {
                                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                        startActivity(intent)
                                        launched = true
                                        break
                                    }
                                }
                            }
                            if (!launched) {
                                val intent = packageManager.getLaunchIntentForPackage("com.google.android.keep")
                                if (intent != null) {
                                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    startActivity(intent)
                                    launched = true
                                }
                            }
                        }

                        if (launched) {
                            result.success(null)
                        } else {
                            result.error("UNAVAILABLE", "No note app found on device", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open notes: ${e.message}", null)
                    }
                }
                "openMusic" -> {
                    try {
                        val songName = call.argument<String>("songName")
                        if (songName != null && songName.isNotEmpty()) {
                            val intent = Intent(android.provider.MediaStore.INTENT_ACTION_MEDIA_PLAY_FROM_SEARCH).apply {
                                putExtra(android.provider.MediaStore.EXTRA_MEDIA_FOCUS, "audio/*")
                                putExtra(android.provider.MediaStore.EXTRA_MEDIA_TITLE, songName)
                                putExtra("query", songName)
                                putExtra("android.intent.extra.play", true)
                                putExtra("play", true)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            
                            // Send keycode play event after a delay to ensure it plays
                            Thread {
                                try {
                                    Thread.sleep(1000)
                                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                                    val downEvent = KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PLAY)
                                    val upEvent = KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PLAY)
                                    audioManager.dispatchMediaKeyEvent(downEvent)
                                    audioManager.dispatchMediaKeyEvent(upEvent)
                                } catch (e: Exception) {}
                            }.start()
                            
                            result.success(null)
                        } else {
                            val intent = Intent(Intent.ACTION_MAIN).apply {
                                addCategory(Intent.CATEGORY_APP_MUSIC)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        var launched = false
                        val musicKeywords = listOf("music", "player", "spotify", "ytmusic")
                        val packages = packageManager.getInstalledPackages(0)
                        for (pkg in packages) {
                            val pkgName = pkg.packageName.lowercase()
                            if (musicKeywords.any { pkgName.contains(it) }) {
                                val intentLaunch = packageManager.getLaunchIntentForPackage(pkg.packageName)
                                if (intentLaunch != null) {
                                    intentLaunch.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    startActivity(intentLaunch)
                                    launched = true
                                    break
                                }
                            }
                        }
                        if (launched) {
                            result.success(null)
                        } else {
                            result.error("UNAVAILABLE", "Cannot open music: ${e.message}", null)
                        }
                    }
                }
                "openFiles" -> {
                    try {
                        val intent = Intent(Intent.ACTION_VIEW)
                        intent.setDataAndType(android.net.Uri.parse("content://media/external/file"), "*/*")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        var launched = false
                        val fileKeywords = listOf("filemanager", "files", "fileexplorer", "documentsui")
                        val packages = packageManager.getInstalledPackages(0)
                        for (pkg in packages) {
                            val pkgName = pkg.packageName.lowercase()
                            if (fileKeywords.any { pkgName.contains(it) } && !pkgName.contains("google.android.apps")) {
                                val intentLaunch = packageManager.getLaunchIntentForPackage(pkg.packageName)
                                if (intentLaunch != null) {
                                    intentLaunch.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    startActivity(intentLaunch)
                                    launched = true
                                    break
                                }
                            }
                        }
                        if (!launched) {
                            val fallback = packageManager.getLaunchIntentForPackage("com.google.android.apps.nbu.files")
                                ?: packageManager.getLaunchIntentForPackage("com.android.documentsui")
                            if (fallback != null) {
                                fallback.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                startActivity(fallback)
                                launched = true
                            }
                        }
                        if (launched) {
                            result.success(null)
                        } else {
                            result.error("UNAVAILABLE", "Cannot open files: ${e.message}", null)
                        }
                    }
                }
                "openCalendar" -> {
                    try {
                        val intent = Intent(Intent.ACTION_MAIN)
                        intent.addCategory(Intent.CATEGORY_APP_CALENDAR)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot open calendar: ${e.message}", null)
                    }
                }
                "makeCall" -> {
                    try {
                        val name = call.argument<String>("name")
                        if (name != null && name.isNotEmpty()) {
                            // Check if the query itself is a phone number
                            val cleanInput = name.replace(Regex("[^0-9+]"), "")
                            if (cleanInput.length >= 5) {
                                val intent = Intent(Intent.ACTION_CALL).apply {
                                    data = Uri.parse("tel:$name")
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                                startActivity(intent)
                                result.success(null)
                            } else {
                                val uniqueNumbers = getContactPhoneNumbersList(this, name)
                                if (uniqueNumbers.size == 1) {
                                    // Exactly one unique number, call directly
                                    val intent = Intent(Intent.ACTION_CALL).apply {
                                        data = Uri.parse("tel:${uniqueNumbers.values.first()}")
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    }
                                    startActivity(intent)
                                    result.success(null)
                                } else if (uniqueNumbers.size > 1) {
                                    // Multiple matching numbers, pre-fill dialer with first match
                                    val intent = Intent(Intent.ACTION_DIAL).apply {
                                        data = Uri.parse("tel:${uniqueNumbers.values.first()}")
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    }
                                    startActivity(intent)
                                    result.success(null)
                                } else {
                                    // No match found, open general dialer
                                    val intent = Intent(Intent.ACTION_DIAL).apply {
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    }
                                    startActivity(intent)
                                    result.success(null)
                                }
                            }
                        } else {
                            val intent = Intent(Intent.ACTION_DIAL).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            startActivity(intent)
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot make call: ${e.message}", null)
                    }
                }
                "adjustVolume" -> {
                    try {
                        val action = call.argument<String>("action") ?: "set"
                        val value = (call.argument<Any>("value") as? Number)?.toInt() ?: 10
                        
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                        
                        var targetVolume = currentVolume
                        if (action == "increase") {
                            val delta = ((value / 100.0) * maxVolume).toInt().coerceAtLeast(1)
                            targetVolume = (currentVolume + delta).coerceAtMost(maxVolume)
                        } else if (action == "decrease") {
                            val delta = ((value / 100.0) * maxVolume).toInt().coerceAtLeast(1)
                            targetVolume = (currentVolume - delta).coerceAtLeast(0)
                        } else {
                            targetVolume = ((value / 100.0) * maxVolume).toInt().coerceIn(0, maxVolume)
                        }
                        
                        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, AudioManager.FLAG_SHOW_UI)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot adjust volume: ${e.message}", null)
                    }
                }
                "lockPhone" -> {
                    try {
                        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                        val adminComponent = ComponentName(applicationContext, MyDeviceAdminReceiver::class.java)
                        if (dpm.isAdminActive(adminComponent)) {
                            dpm.lockNow()
                            result.success(null)
                        } else {
                            try {
                                val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                                    putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
                                    putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Nova Assistant needs Device Admin to lock your phone.")
                                }
                                startActivity(intent)
                            } catch (e: Exception) {
                                val intent = Intent("android.settings.DEVICE_ADMIN_SETTINGS").apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                }
                                startActivity(intent)
                            }
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot lock phone: ${e.message}", null)
                    }
                }
                "startWakeWordService" -> {
                    try {
                        val serviceIntent = Intent(this, WakeWordService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent)
                        } else {
                            startService(serviceIntent)
                        }
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot start wake word service: ${e.message}", null)
                    }
                }
                "stopWakeWordService" -> {
                    try {
                        val serviceIntent = Intent(this, WakeWordService::class.java)
                        stopService(serviceIntent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot stop wake word service: ${e.message}", null)
                    }
                }
                "pauseWakeWordListener" -> {
                    try {
                        val intent = Intent("com.nova.nova_assistant.PAUSE_LISTENING")
                        sendBroadcast(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot pause listener: ${e.message}", null)
                    }
                }
                "resumeWakeWordListener" -> {
                    try {
                        val intent = Intent("com.nova.nova_assistant.RESUME_LISTENING")
                        sendBroadcast(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot resume listener: ${e.message}", null)
                    }
                }
                "checkPendingVoiceTrigger" -> {
                    result.success(pendingVoiceUiTrigger)
                    pendingVoiceUiTrigger = false
                }
                else -> result.notImplemented()
            }
        }

        // App launcher channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LAUNCHER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val intent = Intent(Intent.ACTION_MAIN)
                        intent.addCategory(Intent.CATEGORY_LAUNCHER)
                        val apps = packageManager.queryIntentActivities(intent, 0)
                        val appList = apps.map { app ->
                            mapOf(
                                "packageName" to app.activityInfo.packageName,
                                "appName" to app.loadLabel(packageManager).toString(),
                                "versionName" to try {
                                    packageManager.getPackageInfo(app.activityInfo.packageName, 0).versionName ?: ""
                                } catch (e: Exception) { "" }
                            )
                        }
                        result.success(appList)
                    } catch (e: Exception) {
                        result.success(emptyList<Map<String, String>>())
                    }
                }
                "launchApp" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            val intent = packageManager.getLaunchIntentForPackage(packageName)
                            if (intent != null) {
                                startActivity(intent)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } else {
                            result.error("INVALID", "Package name is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Cannot launch app: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }



        // LLM inference channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LLAMA_CHANNEL)
            .setMethodCallHandler { call, result ->
                @Suppress("UNCHECKED_CAST")
                llamaService.handleCall(call.method, call.arguments as? Map<*, *>, result)
            }
    }

    private fun getContactPhoneNumbersList(context: Context, name: String): Map<String, String> {
        val contentResolver = context.contentResolver
        val uri = android.provider.ContactsContract.CommonDataKinds.Phone.CONTENT_URI
        val projection = arrayOf(
            android.provider.ContactsContract.CommonDataKinds.Phone.NUMBER,
            android.provider.ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME
        )
        
        val uniqueNumbers = mutableMapOf<String, String>() // normalized -> raw
        val searchName = name.lowercase().trim()
        
        try {
            val cursor = contentResolver.query(uri, projection, null, null, null)
            cursor?.use {
                val numIdx = it.getColumnIndex(android.provider.ContactsContract.CommonDataKinds.Phone.NUMBER)
                val nameIdx = it.getColumnIndex(android.provider.ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                
                if (numIdx != -1 && nameIdx != -1) {
                    while (it.moveToNext()) {
                        val displayName = it.getString(nameIdx)?.lowercase() ?: ""
                        if (displayName.contains(searchName)) {
                            val rawNumber = it.getString(numIdx)
                            if (rawNumber != null) {
                                var clean = rawNumber.replace(Regex("[^0-9]"), "")
                                if (clean.length > 10) {
                                    clean = clean.takeLast(10)
                                }
                                if (clean.isNotEmpty()) {
                                    uniqueNumbers[clean] = rawNumber
                                }
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            // Query error or permission denied
        }
        return uniqueNumbers
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("trigger_voice_ui", false)) {
            pendingVoiceUiTrigger = true
            try {
                stopService(Intent(this, WakeWordService::class.java))
            } catch (e: Exception) {}
            runOnUiThread {
                systemChannel?.invokeMethod("onWakeWordTriggered", null)
            }
        }
    }
}

