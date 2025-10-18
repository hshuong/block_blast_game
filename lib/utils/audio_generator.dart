import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
//import 'dart:typed_data';

/// Tạo và phát âm thanh cho game
class AudioGenerator {
  static final AudioGenerator _instance = AudioGenerator._internal();
  
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;

  factory AudioGenerator() {
    return _instance;
  }

  AudioGenerator._internal() {
    _audioPlayer = AudioPlayer();
  }

  /// Khởi tạo
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Phát âm thanh đặt khối (3 nốt lên)
  Future<void> playPlaceBlockSound() async {
    try {
      List<int> audioData = _generatePlaceBlockTone();
      await _playAudioFromBytes(audioData);
    } catch (e) {
      print('Error playing place block sound: $e');
    }
  }

  /// Phát âm thanh xóa hàng (cao, sắc)
  Future<void> playClearLineSound() async {
    try {
      List<int> audioData = _generateClearLineTone();
      await _playAudioFromBytes(audioData);
    } catch (e) {
      print('Error playing clear line sound: $e');
    }
  }

  /// Phát âm thanh game over (thấp, sâu)
  Future<void> playGameOverSound() async {
    try {
      List<int> audioData = _generateGameOverTone();
      await _playAudioFromBytes(audioData);
    } catch (e) {
      print('Error playing game over sound: $e');
    }
  }

  /// Phát âm thanh không thể đặt (bummer)
  Future<void> playInvalidPlaceSound() async {
    try {
      List<int> audioData = _generateInvalidTone();
      await _playAudioFromBytes(audioData);
    } catch (e) {
      print('Error playing invalid sound: $e');
    }
  }

  /// Phát âm thanh level up
  Future<void> playLevelUpSound() async {
    try {
      List<int> audioData = _generateLevelUpTone();
      await _playAudioFromBytes(audioData);
    } catch (e) {
      print('Error playing level up sound: $e');
    }
  }

  /// Sinh âm thanh đặt khối (C5 → E5 → G5)
  List<int> _generatePlaceBlockTone() {
    const int sampleRate = 44100;
    //const double duration = 0.5; // 500ms
    final List<int> samples = [];

    // Phần 1: C5 (523 Hz) - 80ms
    _addTone(samples, 523, 80, sampleRate, 1.0);
    
    // Phần 2: E5 (659 Hz) - 80ms
    _addTone(samples, 659, 80, sampleRate, 1.0);
    
    // Phần 3: G5 (784 Hz) - 200ms
    _addTone(samples, 784, 200, sampleRate, 1.0);

    return _convertToWAV(samples, sampleRate);
  }

  /// Sinh âm thanh xóa hàng (A5 → B5 - cao, sắc)
  List<int> _generateClearLineTone() {
    const int sampleRate = 44100;
    final List<int> samples = [];

    // Phần 1: A5 (880 Hz) - 100ms
    _addTone(samples, 880, 100, sampleRate, 1.0);
    
    // Phần 2: B5 (988 Hz) - 200ms
    _addTone(samples, 988, 200, sampleRate, 1.0);

    return _convertToWAV(samples, sampleRate);
  }

  /// Sinh âm thanh game over (C4 → A3 - thấp, sâu)
  List<int> _generateGameOverTone() {
    const int sampleRate = 44100;
    final List<int> samples = [];

    // Phần 1: C4 (262 Hz) - 150ms
    _addTone(samples, 262, 150, sampleRate, 0.8);
    
    // Phần 2: A3 (220 Hz) - 300ms
    _addTone(samples, 220, 300, sampleRate, 0.8);

    return _convertToWAV(samples, sampleRate);
  }

  /// Sinh âm thanh lỗi (F4 2 lần - bummer)
  List<int> _generateInvalidTone() {
    const int sampleRate = 44100;
    final List<int> samples = [];

    // Phần 1: F4 (349 Hz) - 100ms
    _addTone(samples, 349, 100, sampleRate, 0.7);
    
    // Silence - 100ms
    _addSilence(samples, 100, sampleRate);
    
    // Phần 2: F4 (349 Hz) - 100ms
    _addTone(samples, 349, 100, sampleRate, 0.7);

    return _convertToWAV(samples, sampleRate);
  }

  /// Sinh âm thanh level up (tăng dần)
  List<int> _generateLevelUpTone() {
    const int sampleRate = 44100;
    final List<int> samples = [];

    // 3 nốt tăng dần
    List<int> frequencies = [523, 659, 784]; // C5, E5, G5
    
    for (int freq in frequencies) {
      _addTone(samples, freq, 120, sampleRate, 1.0);
    }

    return _convertToWAV(samples, sampleRate);
  }

  /// Thêm tần số vào mảng samples
  void _addTone(List<int> samples, int frequency, int durationMs, 
      int sampleRate, double volume) {
    const double pi = 3.14159265359;
    final int numSamples = (sampleRate * durationMs ~/ 1000);

    for (int i = 0; i < numSamples; i++) {
      // Sóng sin
      double angle = (2 * pi * frequency * i) / sampleRate;
      double sample = sin(angle) * volume;

      // Envelope (fade in/out)
      if (i < sampleRate ~/ 50) {
        // Fade in nhanh
        sample *= i / (sampleRate ~/ 50);
      }
      if (i > numSamples - sampleRate ~/ 50) {
        // Fade out nhanh
        sample *= (numSamples - i) / (sampleRate ~/ 50);
      }

      // Chuyển sang 16-bit PCM
      int pcmValue = (sample * 32767).toInt().clamp(-32768, 32767);
      samples.add(pcmValue & 0xFF);
      samples.add((pcmValue >> 8) & 0xFF);
    }
  }

  /// Thêm silence vào samples
  void _addSilence(List<int> samples, int durationMs, int sampleRate) {
    final int numSamples = (sampleRate * durationMs ~/ 1000) * 2; // 2 bytes per sample
    for (int i = 0; i < numSamples; i++) {
      samples.add(0);
    }
  }

  /// Xấp xỉ hàm sin
  double sin(double x) {
    const double pi = 3.14159265359;
    x = x % (2 * pi);
    
    // Chuỗi Taylor
    double result = x;
    double term = x;
    for (int n = 1; n < 15; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  /// Chuyển sang định dạng WAV
  List<int> _convertToWAV(List<int> pcmData, int sampleRate) {
    //int numSamples = pcmData.length ~/ 2;
    int byteRate = sampleRate * 2 * 16 ~/ 8;
    
    List<int> wav = [];

    // RIFF header
    wav.addAll('RIFF'.codeUnits);
    wav.addAll(_intToBytes(36 + pcmData.length, 4));
    wav.addAll('WAVE'.codeUnits);

    // fmt sub-chunk
    wav.addAll('fmt '.codeUnits);
    wav.addAll(_intToBytes(16, 4)); // Subchunk1Size
    wav.addAll(_intToBytes(1, 2)); // AudioFormat (1 = PCM)
    wav.addAll(_intToBytes(1, 2)); // NumChannels
    wav.addAll(_intToBytes(sampleRate, 4)); // SampleRate
    wav.addAll(_intToBytes(byteRate, 4)); // ByteRate
    wav.addAll(_intToBytes(2, 2)); // BlockAlign
    wav.addAll(_intToBytes(16, 2)); // BitsPerSample

    // data sub-chunk
    wav.addAll('data'.codeUnits);
    wav.addAll(_intToBytes(pcmData.length, 4));
    wav.addAll(pcmData);

    return wav;
  }

  /// Chuyển int thành bytes (little-endian)
  List<int> _intToBytes(int value, int numBytes) {
    List<int> bytes = [];
    for (int i = 0; i < numBytes; i++) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return bytes;
  }

  /// Phát âm thanh từ byte data
  Future<void> _playAudioFromBytes(List<int> audioBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_audio.wav');
      await file.writeAsBytes(audioBytes);
      
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}