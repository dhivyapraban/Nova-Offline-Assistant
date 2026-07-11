package com.nova.nova_assistant

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.Settings
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import java.util.Locale

class WakeWordService : Service() {
    private val TAG = "WakeWordService"
    private val CHANNEL_ID = "nova_wakeword_service_channel"
    private val NOTIFICATION_ID = 992
    
    private var speechRecognizer: SpeechRecognizer? = null
    private var recognizerIntent: Intent? = null
    private var isListening = false
    private var isMuted = false

    // Overlay components
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var overlayTextView: TextView? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // State Machine
    enum class ServiceState {
        IDLE_WAITING,    // Listening for "Hey Nova"
        COMMAND_WAITING  // Displaying overlay, listening for command
    }
    private var serviceState = ServiceState.IDLE_WAITING

    private val commandReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                "com.nova.nova_assistant.PAUSE_LISTENING" -> {
                    Log.d(TAG, "Broadcast received: PAUSE_LISTENING")
                    serviceState = ServiceState.COMMAND_WAITING
                    mainHandler.removeCallbacks(commandTimeoutRunnable)
                    try {
                        speechRecognizer?.setRecognitionListener(null)
                        speechRecognizer?.cancel()
                        speechRecognizer?.destroy()
                        speechRecognizer = null
                    } catch (e: Exception) {}
                    isListening = false
                    muteSystem()
                }
                "com.nova.nova_assistant.RESUME_LISTENING" -> {
                    Log.d(TAG, "Broadcast received: RESUME_LISTENING")
                    serviceState = ServiceState.IDLE_WAITING
                    restartListening()
                }
            }
        }
    }

    private val commandTimeoutRunnable = Runnable {
        Log.d(TAG, "Timeout: No command spoken inside 4 seconds.")
        vibrate(longArrayOf(0, 80))
        dismissOverlay()
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "WakeWordService Created")
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
        startForegroundServiceNotification()
        
        val filter = android.content.IntentFilter().apply {
            addAction("com.nova.nova_assistant.PAUSE_LISTENING")
            addAction("com.nova.nova_assistant.RESUME_LISTENING")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(commandReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(commandReceiver, filter)
        }
        
        initializeRecognizer()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Nova Wake Word Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(serviceChannel)
        }
    }

    private fun startForegroundServiceNotification() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Nova Assistant")
            .setContentText("Listening for 'Hey Nova'...")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
            
        try {
            startForeground(NOTIFICATION_ID, notification)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start foreground service: ${e.message}")
        }
    }

    private fun isWakeWord(text: String): Boolean {
        val cleanText = text.lowercase(Locale.getDefault())
            .replace(",", "")
            .replace(".", "")
            .replace("?", "")
            .replace("!", "")
            .trim()
            
        val words = cleanText.split("\\s+".toRegex())
        if (words.isEmpty()) return false
        
        val firstWord = words[0]
        val secondWord = if (words.size > 1) words[1] else ""
        
        val targetFirstWords = listOf("nova", "hanoa", "henova", "hynova")
        if (targetFirstWords.contains(firstWord)) return true
        
        val greetingWords = listOf("hey", "hi", "hello", "ok", "okay", "he")
        if (greetingWords.contains(firstWord) && targetFirstWords.contains(secondWord)) return true
        
        return false
    }

    private fun isCommand(text: String): Boolean {
        val t = text.lowercase(Locale.getDefault())
        return t.contains("lock") || 
               t.contains("flashlight") || 
               t.contains("torch") || 
               t.contains("volume") || 
               t.contains("mute") || 
               t.contains("open") || 
               t.contains("launch") ||
               t.contains("timer") ||
               t.contains("alarm")
    }

    private fun cleanWakeWord(text: String): String {
        val clean = text.lowercase(Locale.getDefault())
            .replace(",", "")
            .replace(".", "")
            .replace("?", "")
            .replace("!", "")
            .trim()
            
        val words = clean.split("\\s+".toRegex())
        if (words.isEmpty()) return ""
        
        val firstWord = words[0]
        val secondWord = if (words.size > 1) words[1] else ""
        
        val targetFirstWords = listOf("nova", "hanoa", "henova", "hynova")
        val greetingWords = listOf("hey", "hi", "hello", "ok", "okay", "he")
        
        if (targetFirstWords.contains(firstWord)) {
            return words.drop(1).joinToString(" ")
        }
        
        if (greetingWords.contains(firstWord) && targetFirstWords.contains(secondWord)) {
            return words.drop(2).joinToString(" ")
        }
        
        return clean
    }

    private fun muteSystem() {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            if (audioManager.ringerMode != AudioManager.RINGER_MODE_NORMAL) {
                // If phone is in vibration or silent mode, respect it and do not modify volumes!
                return
            }
            if (isMuted) return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                audioManager.adjustStreamVolume(AudioManager.STREAM_SYSTEM, AudioManager.ADJUST_MUTE, 0)
                audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_MUTE, 0)
            } else {
                @Suppress("DEPRECATION")
                audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, true)
                @Suppress("DEPRECATION")
                audioManager.setStreamMute(AudioManager.STREAM_NOTIFICATION, true)
            }
            isMuted = true
        } catch (e: Exception) {
            Log.e(TAG, "Mute failed: ${e.message}")
        }
    }

    private fun unmuteSystem() {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            if (audioManager.ringerMode != AudioManager.RINGER_MODE_NORMAL) {
                // If phone is in vibration or silent mode, respect it and do not modify volumes!
                return
            }
            if (!isMuted) return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                audioManager.adjustStreamVolume(AudioManager.STREAM_SYSTEM, AudioManager.ADJUST_UNMUTE, 0)
                audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, 0)
            } else {
                @Suppress("DEPRECATION")
                audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, false)
                @Suppress("DEPRECATION")
                audioManager.setStreamMute(AudioManager.STREAM_NOTIFICATION, false)
            }
            isMuted = false
        } catch (e: Exception) {
            Log.e(TAG, "Unmute failed: ${e.message}")
        }
    }

    private fun initializeRecognizer() {
        try {
            if (speechRecognizer != null) {
                speechRecognizer?.setRecognitionListener(null)
                speechRecognizer?.destroy()
                speechRecognizer = null
            }
            if (SpeechRecognizer.isRecognitionAvailable(this)) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && SpeechRecognizer.isOnDeviceRecognitionAvailable(this)) {
                    speechRecognizer = SpeechRecognizer.createOnDeviceSpeechRecognizer(this)
                } else {
                    speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
                }
            } else {
                speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
            }
        } catch (e: Exception) {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        }

        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                Log.d(TAG, "onReadyForSpeech | State: $serviceState")
                isListening = true
                
                // Speech session started. Delay unmute slightly to fully silence start beep
                mainHandler.postDelayed({
                    unmuteSystem()
                }, 500)
            }
            override fun onBeginningOfSpeech() {
                Log.d(TAG, "onBeginningOfSpeech")
                if (serviceState == ServiceState.COMMAND_WAITING) {
                    // Cancel the 4-second cutoff timer since the user has started speaking!
                    mainHandler.removeCallbacks(commandTimeoutRunnable)
                }
            }
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {
                Log.d(TAG, "onEndOfSpeech")
                muteSystem() // Mute immediately to silence shutdown beep
            }
            override fun onError(error: Int) {
                isListening = false
                muteSystem() // Mute immediately to silence error beep
                
                if (error == SpeechRecognizer.ERROR_NO_MATCH || error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT) {
                    Log.d(TAG, "Standby status: waiting silently for wake word...")
                } else if (error == SpeechRecognizer.ERROR_RECOGNIZER_BUSY) {
                    Log.d(TAG, "Speech engine busy. Performing clean restart...")
                    try {
                        speechRecognizer?.setRecognitionListener(null)
                        speechRecognizer?.destroy()
                        speechRecognizer = null
                    } catch (e: Exception) {}
                    
                    mainHandler.postDelayed({
                        startRecognizer()
                    }, 2000)
                    return
                } else {
                    Log.d(TAG, "System voice callback: status code $error")
                }
                
                if (serviceState == ServiceState.COMMAND_WAITING) {
                    // Dismiss the assistant overlay on silence/error timeout
                    dismissOverlay()
                    return
                }
                restartListening()
            }
            override fun onResults(results: Bundle?) {
                Log.d(TAG, "onResults")
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                isListening = false
                muteSystem() // Mute immediately to silence success beep
                
                if (matches != null && matches.isNotEmpty()) {
                    val heardText = matches.first().lowercase(Locale.getDefault()).trim()
                    Log.d(TAG, "Heard text: $heardText")
                    
                    if (serviceState == ServiceState.IDLE_WAITING) {
                        if (isWakeWord(heardText)) {
                            val commandPart = cleanWakeWord(heardText)
                            if (commandPart.isNotEmpty() && isCommand(commandPart)) {
                                Log.d(TAG, "Single-shot command matched: $commandPart")
                                val executed = executeCommandBackground(commandPart)
                                if (executed) {
                                    vibrate(longArrayOf(0, 300))
                                } else {
                                    vibrate(longArrayOf(0, 80))
                                }
                                restartListening()
                                return
                            }
                            
                            Log.d(TAG, "Wake word matched! Displaying Overlay UI.")
                            vibrate(longArrayOf(0, 100, 80, 100))
                            mainHandler.post { showOverlay() }
                            return
                        }
                    } else if (serviceState == ServiceState.COMMAND_WAITING) {
                        mainHandler.removeCallbacks(commandTimeoutRunnable)
                        overlayTextView?.text = heardText
                        
                        val executed = executeCommandBackground(heardText)
                        if (executed) {
                            vibrate(longArrayOf(0, 300))
                        } else {
                            vibrate(longArrayOf(0, 80))
                        }
                        
                        mainHandler.postDelayed({
                            dismissOverlay()
                        }, 1200)
                        return
                    }
                }
                
                if (serviceState == ServiceState.COMMAND_WAITING) {
                    // Restart listening for the command, setting a fresh 4-second timeout
                    mainHandler.removeCallbacks(commandTimeoutRunnable)
                    mainHandler.postDelayed(commandTimeoutRunnable, 4000)
                    startRecognizer()
                } else {
                    restartListening()
                }
            }
            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (matches != null && matches.isNotEmpty()) {
                    val heardText = matches.first().lowercase(Locale.getDefault()).trim()
                    if (serviceState == ServiceState.IDLE_WAITING) {
                        if (isWakeWord(heardText)) {
                            Log.d(TAG, "Wake word matched in partial results! Displaying Overlay UI.")
                            
                            speechRecognizer?.setRecognitionListener(null)
                            speechRecognizer?.cancel()
                            isListening = false
                            muteSystem()
                            
                            vibrate(longArrayOf(0, 100, 80, 100))
                            mainHandler.post { showOverlay() }
                        }
                    } else if (serviceState == ServiceState.COMMAND_WAITING) {
                        overlayTextView?.text = heardText
                        // Remove timeout while user is actively outputting partial words
                        mainHandler.removeCallbacks(commandTimeoutRunnable)
                    }
                }
            }
            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra("android.speech.extra.DICTATION_MODE", true)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 100000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 100000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 100000L)
        }
        
        startRecognizer()
    }

    private fun startRecognizer() {
        try {
            if (speechRecognizer == null) {
                initializeRecognizer()
                return
            }
            if (!isListening) {
                // Mute system streams to suppress beep sounds
                muteSystem()

                speechRecognizer?.startListening(recognizerIntent)
                isListening = true
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting recognizer: ${e.message}")
            restartListening()
        }
    }

    private fun restartListening() {
        if (speechRecognizer != null) {
            // Unbind listener before cancelling to prevent callback recursions during session transitions
            speechRecognizer?.setRecognitionListener(null)
            speechRecognizer?.cancel()
            
            // Re-initialize to completely reset the native SpeechRecognizer framework bindings
            speechRecognizer = null
            
            mainHandler.postDelayed({
                startRecognizer()
            }, 1200) // Pause for 1.2s between active windows to avoid system speech service collisions
        }
    }

    private fun vibrate(pattern: LongArray) {
        try {
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createWaveform(pattern, -1))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(pattern, -1)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Vibration failed: ${e.message}")
        }
    }

    private fun showOverlay() {
        if (overlayView != null) return
        
        serviceState = ServiceState.COMMAND_WAITING
        
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            
            val bg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(24).toFloat()
                setColor(Color.parseColor("#EE1A1A1A"))
                setStroke(dpToPx(1), Color.parseColor("#33FFFFFF"))
            }
            background = bg
            
            val pad = dpToPx(24)
            setPadding(pad, pad, pad, pad)
        }

        val handle = View(this).apply {
            val bgHandle = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dpToPx(2).toFloat()
                setColor(Color.parseColor("#44FFFFFF"))
            }
            background = bgHandle
            
            val hParams = LinearLayout.LayoutParams(dpToPx(40), dpToPx(4)).apply {
                bottomMargin = dpToPx(16)
            }
            layoutParams = hParams
        }
        container.addView(handle)

        overlayTextView = TextView(this).apply {
            text = "Listening..."
            setTextColor(Color.WHITE)
            textSize = 18f
            gravity = Gravity.CENTER
        }
        container.addView(overlayTextView)

        val dotsLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            
            val dParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = dpToPx(20)
            }
            layoutParams = dParams
        }

        val colors = intArrayOf(
            Color.parseColor("#4285F4"),
            Color.parseColor("#EA4335"),
            Color.parseColor("#FBBC05"),
            Color.parseColor("#34A853")
        )
        for (i in 0 until colors.size) {
            val dot = View(this).apply {
                val bgDot = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(colors[i])
                }
                background = bgDot
                
                val dParams = LinearLayout.LayoutParams(dpToPx(12), dpToPx(12)).apply {
                    leftMargin = dpToPx(6)
                    rightMargin = dpToPx(6)
                }
                layoutParams = dParams
            }
            dotsLayout.addView(dot)

            val scaleX = ObjectAnimator.ofFloat(dot, "scaleX", 0.7f, 1.3f).apply {
                duration = 350
                repeatCount = ValueAnimator.INFINITE
                repeatMode = ValueAnimator.REVERSE
                startDelay = (i * 120).toLong()
            }
            val scaleY = ObjectAnimator.ofFloat(dot, "scaleY", 0.7f, 1.3f).apply {
                duration = 350
                repeatCount = ValueAnimator.INFINITE
                repeatMode = ValueAnimator.REVERSE
                startDelay = (i * 120).toLong()
            }
            scaleX.start()
            scaleY.start()
        }
        container.addView(dotsLayout)

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM
            y = dpToPx(16)
        }

        try {
            windowManager?.addView(container, params)
            overlayView = container
        } catch (e: Exception) {
            Log.e(TAG, "Failed to mount window overlay: ${e.message}")
        }

        mainHandler.removeCallbacks(commandTimeoutRunnable)
        mainHandler.postDelayed(commandTimeoutRunnable, 4000)
        
        restartListening()
    }

    private fun dismissOverlay() {
        if (overlayView != null) {
            try {
                windowManager?.removeView(overlayView)
            } catch (e: Exception) {}
            overlayView = null
            overlayTextView = null
        }
        
        mainHandler.removeCallbacks(commandTimeoutRunnable)
        serviceState = ServiceState.IDLE_WAITING
        restartListening()
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    private fun executeCommandBackground(text: String): Boolean {
        Log.d(TAG, "Attempting background command execution for: $text")
        
        if (text.contains("lock")) {
            return try {
                val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                val adminComponent = ComponentName(applicationContext, MyDeviceAdminReceiver::class.java)
                if (dpm.isAdminActive(adminComponent)) {
                    dpm.lockNow()
                    true
                } else {
                    wakeUpApp()
                    false
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to lock phone: ${e.message}")
                false
            }
        }
        
        if (text.contains("flashlight") || text.contains("torch")) {
            return try {
                val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
                val cameraId = cameraManager.cameraIdList[0]
                val turnOn = !text.contains("off")
                cameraManager.setTorchMode(cameraId, turnOn)
                true
            } catch (e: Exception) {
                false
            }
        }
        
        if (text.contains("volume")) {
            return try {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                
                if (text.contains("increase") || text.contains("up") || text.contains("louder")) {
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, (current + 2).coerceAtMost(max), AudioManager.FLAG_SHOW_UI)
                    true
                } else if (text.contains("decrease") || text.contains("down") || text.contains("quieter") || text.contains("lower")) {
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, (current - 2).coerceAtLeast(0), AudioManager.FLAG_SHOW_UI)
                    true
                } else if (text.contains("mute")) {
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, AudioManager.FLAG_SHOW_UI)
                    true
                } else {
                    false
                }
            } catch (e: Exception) {
                false
            }
        }



        if (text.contains("timer")) {
            var seconds = 300 // default 5 minutes
            val durationRegex = """(\d+)\s*(min|minute|sec|second)s?""".toRegex(RegexOption.IGNORE_CASE)
            val durationMatch = durationRegex.find(text)
            if (durationMatch != null) {
                val value = durationMatch.groupValues[1].toInt()
                val unit = durationMatch.groupValues[2].lowercase()
                seconds = if (unit.startsWith("sec")) value else value * 60
            }

            val intent = Intent(android.provider.AlarmClock.ACTION_SET_TIMER).apply {
                putExtra(android.provider.AlarmClock.EXTRA_LENGTH, seconds)
                putExtra(android.provider.AlarmClock.EXTRA_SKIP_UI, false)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            return try {
                startActivity(intent)
                true
            } catch (e: Exception) {
                false
            }
        }

        if (text.contains("alarm")) {
            var hour = 8
            var minute = 0
            
            // Check for relative duration, e.g. "for 5 mins", "in 10 minutes"
            val durationRegex = """(?:in|for)?\s*(\d+)\s*(min|minute)s?""".toRegex(RegexOption.IGNORE_CASE)
            val durationMatch = durationRegex.find(text)
            if (durationMatch != null) {
                val value = durationMatch.groupValues[1].toInt()
                val calendar = java.util.Calendar.getInstance()
                calendar.add(java.util.Calendar.MINUTE, value)
                hour = calendar.get(java.util.Calendar.HOUR_OF_DAY)
                minute = calendar.get(java.util.Calendar.MINUTE)
            } else {
                // Check for absolute time "5:30pm" or "5:30 pm"
                val timeRegex = """(\d{1,2}):(\d{2})\s*([ap]\.?m\.?)?""".toRegex(RegexOption.IGNORE_CASE)
                val timeMatch = timeRegex.find(text)
                if (timeMatch != null) {
                    hour = timeMatch.groupValues[1].toInt()
                    minute = timeMatch.groupValues[2].toInt()
                    val ampm = timeMatch.groupValues[3].lowercase()
                    if (ampm.contains("p") && hour < 12) {
                        hour += 12
                    } else if (ampm.contains("a") && hour == 12) {
                        hour = 0
                    }
                } else {
                    // Check for hour only, e.g. "for 5 pm" or "5pm" or "at 5"
                    val hourOnlyRegex = """(?:at|for)?\s*(\d{1,2})\s*([ap]\.?m\.?)""".toRegex(RegexOption.IGNORE_CASE)
                    val hourMatch = hourOnlyRegex.find(text)
                    if (hourMatch != null) {
                        hour = hourMatch.groupValues[1].toInt()
                        val ampm = hourMatch.groupValues[2].lowercase()
                        if (ampm.contains("p") && hour < 12) {
                            hour += 12
                        } else if (ampm.contains("a") && hour == 12) {
                            hour = 0
                        }
                    }
                }
            }

            val intent = Intent(android.provider.AlarmClock.ACTION_SET_ALARM).apply {
                putExtra(android.provider.AlarmClock.EXTRA_HOUR, hour)
                putExtra(android.provider.AlarmClock.EXTRA_MINUTES, minute)
                putExtra(android.provider.AlarmClock.EXTRA_SKIP_UI, false)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            return try {
                startActivity(intent)
                true
            } catch (e: Exception) {
                false
            }
        }
        
        if (text.contains("open") || text.contains("launch")) {
            val intent = when {
                text.contains("camera") -> Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE)
                text.contains("settings") -> Intent(Settings.ACTION_SETTINGS)
                text.contains("clock") -> Intent(android.provider.AlarmClock.ACTION_SHOW_ALARMS)
                text.contains("calendar") -> Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_APP_CALENDAR)
                else -> null
            }
            if (intent != null) {
                return try {
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    true
                } catch (e: Exception) {
                    false
                }
            }
        }
        
        wakeUpApp()
        return true
    }

    private fun wakeUpApp() {
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("trigger_voice_ui", true)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch MainActivity: ${e.message}")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand")
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "WakeWordService Destroyed")
        dismissOverlay()
        unmuteSystem()
        isListening = false
        try {
            unregisterReceiver(commandReceiver)
        } catch (e: Exception) {}
        speechRecognizer?.setRecognitionListener(null)
        speechRecognizer?.destroy()
        speechRecognizer = null
    }
}
