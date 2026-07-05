#include <jni.h>
#include <string>
#include <vector>
#include <android/log.h>
#include "llama.h"

#define TAG "NovaLlama"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

// ─── Global state (one model at a time) ──────────────────────────────────────
static llama_model*   g_model   = nullptr;
static llama_context* g_ctx     = nullptr;
static llama_sampler* g_sampler = nullptr;

// ─── Helpers ─────────────────────────────────────────────────────────────────
static std::string jstring_to_string(JNIEnv* env, jstring js) {
    const char* chars = env->GetStringUTFChars(js, nullptr);
    std::string s(chars);
    env->ReleaseStringUTFChars(js, chars);
    return s;
}

static void free_resources() {
    if (g_sampler) { llama_sampler_free(g_sampler); g_sampler = nullptr; }
    if (g_ctx)     { llama_free(g_ctx);              g_ctx     = nullptr; }
    if (g_model)   { llama_model_free(g_model);      g_model   = nullptr; }
}

// ─── JNI: loadModel ──────────────────────────────────────────────────────────
extern "C" JNIEXPORT jboolean JNICALL
Java_com_nova_nova_1assistant_LlamaService_loadModel(
        JNIEnv* env, jobject /* this */, jstring jModelPath, jint nCtx, jint nThreads) {

    free_resources();
    llama_backend_init();

    std::string modelPath = jstring_to_string(env, jModelPath);
    LOGI("Loading model: %s", modelPath.c_str());

    // Model params
    auto mparams = llama_model_default_params();
    mparams.n_gpu_layers = 0;          // CPU only
    mparams.use_mmap = false;          // Disable mmap to prevent SIGSEGV on Android

    g_model = llama_load_model_from_file(modelPath.c_str(), mparams);
    if (!g_model) {
        LOGE("Failed to load model from: %s", modelPath.c_str());
        return JNI_FALSE;
    }
    LOGI("Model loaded successfully");

    // Context params
    auto cparams = llama_context_default_params();
    cparams.n_ctx      = (uint32_t) nCtx;
    cparams.n_batch    = 512;
    cparams.n_ubatch   = 512;
    cparams.n_threads  = (int32_t) nThreads;
    cparams.n_threads_batch = (int32_t) nThreads;

    g_ctx = llama_new_context_with_model(g_model, cparams);
    if (!g_ctx) {
        LOGE("Failed to create context");
        llama_model_free(g_model); g_model = nullptr;
        return JNI_FALSE;
    }

    // Sampler chain: temperature → top-p → greedy
    auto sparams = llama_sampler_chain_default_params();
    g_sampler = llama_sampler_chain_init(sparams);
    llama_sampler_chain_add(g_sampler, llama_sampler_init_temp(0.7f));
    llama_sampler_chain_add(g_sampler, llama_sampler_init_top_p(0.9f, 1));
    llama_sampler_chain_add(g_sampler, llama_sampler_init_greedy());

    LOGI("Context and sampler ready. n_ctx=%d, n_threads=%d", nCtx, nThreads);
    return JNI_TRUE;
}

// ─── JNI: runInference ───────────────────────────────────────────────────────
extern "C" JNIEXPORT jstring JNICALL
Java_com_nova_nova_1assistant_LlamaService_runInference(
        JNIEnv* env, jobject /* this */, jstring jPrompt, jint maxNewTokens) {

    if (!g_model || !g_ctx || !g_sampler) {
        return env->NewStringUTF("[Error: model not loaded]");
    }

    std::string prompt = jstring_to_string(env, jPrompt);
    LOGI("Running inference on prompt (%zu chars)", prompt.size());

    const llama_vocab* vocab = llama_model_get_vocab(g_model);

    // Tokenise input
    int n_ctx = (int) llama_n_ctx(g_ctx);
    std::vector<llama_token> tokens(n_ctx);
    int n_tokens = llama_tokenize(vocab, prompt.c_str(), (int32_t) prompt.size(),
                                  tokens.data(), n_ctx, /*add_special=*/true, /*parse_special=*/true);
    if (n_tokens < 0) {
        LOGE("Tokenisation failed (n_tokens=%d)", n_tokens);
        return env->NewStringUTF("[Error: tokenisation failed]");
    }
    tokens.resize(n_tokens);
    LOGI("Tokenised: %d tokens", n_tokens);

    // Reset KV cache and decode the prompt in one batch
    llama_memory_clear(llama_get_memory(g_ctx), true);
    llama_sampler_reset(g_sampler);

    {
        llama_batch batch = llama_batch_get_one(tokens.data(), (int32_t) n_tokens);
        if (llama_decode(g_ctx, batch) != 0) {
            LOGE("llama_decode failed for prompt");
            return env->NewStringUTF("[Error: prompt decode failed]");
        }
    }

    // Generate tokens one at a time
    std::string output;
    output.reserve(1024);
    char piece_buf[256];

    for (int i = 0; i < maxNewTokens; ++i) {
        llama_token token = llama_sampler_sample(g_sampler, g_ctx, -1);
        if (llama_vocab_is_eog(vocab, token)) {
            LOGI("Hit EOS after %d tokens", i);
            break;
        }

        int n_piece = llama_token_to_piece(vocab, token, piece_buf, (int32_t) sizeof(piece_buf),
                                           /*lstrip=*/0, /*special=*/false);
        if (n_piece > 0) {
            output.append(piece_buf, (size_t) n_piece);
        }

        // Feed the new token back
        llama_batch next_batch = llama_batch_get_one(&token, 1);
        if (llama_decode(g_ctx, next_batch) != 0) {
            LOGE("llama_decode failed at token %d", i);
            break;
        }
    }

    LOGI("Generated %zu chars", output.size());
    return env->NewStringUTF(output.c_str());
}

// ─── JNI: isModelLoaded ──────────────────────────────────────────────────────
extern "C" JNIEXPORT jboolean JNICALL
Java_com_nova_nova_1assistant_LlamaService_isModelLoaded(JNIEnv*, jobject) {
    return (g_model != nullptr && g_ctx != nullptr) ? JNI_TRUE : JNI_FALSE;
}

// ─── JNI: freeModel ──────────────────────────────────────────────────────────
extern "C" JNIEXPORT void JNICALL
Java_com_nova_nova_1assistant_LlamaService_freeModel(JNIEnv*, jobject) {
    free_resources();
    llama_backend_free();
    LOGI("Model freed");
}
