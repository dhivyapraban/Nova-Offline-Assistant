cmake_minimum_required(VERSION 3.22.1)
project("nova_llama")

# Force release optimizations for all native targets to ensure numerical stability and disable assertions
add_compile_options(-O3)
add_definitions(-DNDEBUG)

# ─── llama.cpp settings ───────────────────────────────────────────────────────
set(LLAMA_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER   OFF CACHE BOOL "" FORCE)
set(LLAMA_NATIVE         OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS    OFF CACHE BOOL "" FORCE)

# Android-specific optimisations
set(GGML_OPENMP  OFF CACHE BOOL "" FORCE)  # no OpenMP on Android
set(GGML_BLAS    OFF CACHE BOOL "" FORCE)
set(GGML_CUDA    OFF CACHE BOOL "" FORCE)
set(GGML_METAL   OFF CACHE BOOL "" FORCE)

# Enable ARM NEON for arm64-v8a (huge speed boost on your phone)
if(ANDROID_ABI STREQUAL "arm64-v8a")
    set(GGML_NEON ON CACHE BOOL "" FORCE)
endif()

# ─── Add llama.cpp source ─────────────────────────────────────────────────────
set(LLAMA_DIR "${CMAKE_SOURCE_DIR}/../llama.cpp")
add_subdirectory(${LLAMA_DIR} llama_build)

# ─── JNI wrapper shared library ──────────────────────────────────────────────
add_library(nova_llama SHARED
    src/main/cpp/nova_llama_jni.cpp
)

target_compile_features(nova_llama PRIVATE cxx_std_17)

target_include_directories(nova_llama PRIVATE
    ${LLAMA_DIR}/include
    ${LLAMA_DIR}/ggml/include
)

target_link_libraries(nova_llama
    llama
    ggml
    android
    log
)
