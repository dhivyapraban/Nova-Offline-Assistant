/// Audio recording service for voice input
/// Uses the `record` package for microphone recording
/// Output audio is PCM/WAV format for speech recognition processing
abstract class AudioService {
  /// Start recording audio from microphone
  Future<void> startRecording();

  /// Stop recording and return the file path
  Future<String?> stopRecording();

  /// Check if currently recording
  bool get isRecording;

  /// Get audio stream for real-time processing
  Stream<List<int>>? get audioStream;

  /// Dispose resources
  Future<void> dispose();
}

/// Placeholder implementation using the record package
class AudioServiceImpl implements AudioService {
  bool _isRecording = false;

  @override
  bool get isRecording => _isRecording;

  @override
  Stream<List<int>>? get audioStream => null;

  @override
  Future<void> startRecording() async {
    // Will be implemented with `record` package
    // final recorder = AudioRecorder();
    // await recorder.start(const RecordConfig(), path: filePath);
    _isRecording = true;
  }

  @override
  Future<String?> stopRecording() async {
    _isRecording = false;
    // Will return the recorded file path
    return null;
  }

  @override
  Future<void> dispose() async {
    _isRecording = false;
  }
}
