package com.nova.nova_assistant

import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import io.flutter.plugin.common.MethodChannel

/**
 * Kotlin bridge that loads the nova_llama JNI library and exposes
 * loadModel / runInference / freeModel to the Flutter MethodChannel.
 */
class LlamaService {

    companion object {
        private const val TAG = "LlamaService"

        init {
            try {
                System.loadLibrary("nova_llama")
                Log.i(TAG, "nova_llama native library loaded successfully")
            } catch (e: UnsatisfiedLinkError) {
                Log.e(TAG, "Failed to load nova_llama: ${e.message}")
            }
        }
    }

    // ── Native declarations ─────────────────────────────────────────────────
    private external fun loadModel(modelPath: String, nCtx: Int, nThreads: Int): Boolean
    private external fun runInference(prompt: String, maxNewTokens: Int): String
    private external fun isModelLoaded(): Boolean
    private external fun freeModel()

    // ── MethodChannel handler ───────────────────────────────────────────────
    fun handleCall(
        method: String,
        args: Map<*, *>?,
        result: MethodChannel.Result
    ) {
        when (method) {
            "loadModel" -> {
                val path       = args?.get("path")       as? String ?: return result.error("INVALID", "path required", null)
                val nCtx       = (args["nCtx"]       as? Int) ?: 2048
                val nThreads   = (args["nThreads"]   as? Int) ?: 4
 
                Thread(null, {
                    try {
                        Log.i(TAG, "loadModel called: path=$path nCtx=$nCtx nThreads=$nThreads")
                        val ok = loadModel(path, nCtx, nThreads)
                        android.os.Handler(android.os.Looper.getMainLooper()).post {
                            if (ok) {
                                Log.i(TAG, "Model loaded successfully")
                                result.success(true)
                            } else {
                                Log.e(TAG, "Model load failed")
                                result.error("LOAD_FAILED", "Failed to load model from: $path", null)
                            }
                        }
                    } catch (e: Exception) {
                        android.os.Handler(android.os.Looper.getMainLooper()).post {
                            result.error("LOAD_FAILED", "Failed to load model: ${e.message}", null)
                        }
                    }
                }, "llama-load-thread", 4 * 1024 * 1024).start()
            }
 
            "runInference" -> {
                val prompt       = args?.get("prompt")       as? String ?: return result.error("INVALID", "prompt required", null)
                val maxNewTokens = (args?.get("maxNewTokens") as? Int) ?: 256
 
                if (!isModelLoaded()) {
                    return result.error("NOT_LOADED", "No model loaded", null)
                }
 
                Thread(null, {
                    try {
                        Log.i(TAG, "runInference: maxTokens=$maxNewTokens")
                        val response = runInference(prompt, maxNewTokens)
                        android.os.Handler(android.os.Looper.getMainLooper()).post {
                            result.success(response)
                        }
                    } catch (e: Exception) {
                        android.os.Handler(android.os.Looper.getMainLooper()).post {
                            result.error("INFERENCE_FAILED", "Inference error: ${e.message}", null)
                        }
                    }
                }, "llama-inf-thread", 4 * 1024 * 1024).start()
            }
 
            "isModelLoaded" -> {
                result.success(isModelLoaded())
            }
 
            "freeModel" -> {
                Thread(null, {
                    try {
                        freeModel()
                        android.os.Handler(android.os.Looper.getMainLooper()).post {
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        android.os.Handler(android.os.Looper.getMainLooper()).post {
                            result.error("FREE_FAILED", "Error freeing model: ${e.message}", null)
                        }
                    }
                }, "llama-free-thread", 4 * 1024 * 1024).start()
            }
 
            else -> result.notImplemented()
        }
    }
}
