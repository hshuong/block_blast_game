import 'package:flutter/services.dart';

/// Quản lý âm thanh trong game
/// Tạo các âm thanh bằng cách kết hợp các tần số khác nhau
class SoundManager {
  static const platform = MethodChannel('com.blockblast/audio');

  /// Phát âm thanh khi đặt khối thành công
  /// Tần số: 523 Hz (C5) → 659 Hz (E5) → 784 Hz (G5)
  static Future<void> playPlaceBlockSound() async {
    try {
      await platform.invokeMethod('playTone', {
        'frequency': 523,
        'duration': 80,
      });
      await Future.delayed(Duration(milliseconds: 80));
      
      await platform.invokeMethod('playTone', {
        'frequency': 659,
        'duration': 80,
      });
      await Future.delayed(Duration(milliseconds: 80));
      
      await platform.invokeMethod('playTone', {
        'frequency': 784,
        'duration': 160,
      });
    } catch (e) {
      print('Error playing place block sound: $e');
      // Không làm gì nếu lỗi (có thể thiết bị không hỗ trợ)
    }
  }

  /// Âm thanh khi xóa hàng/cột
  /// Tần số cao: 880 Hz (A5) → 988 Hz (B5)
  static Future<void> playClearLineSound() async {
    try {
      await platform.invokeMethod('playTone', {
        'frequency': 880,
        'duration': 100,
      });
      await Future.delayed(Duration(milliseconds: 100));
      
      await platform.invokeMethod('playTone', {
        'frequency': 988,
        'duration': 200,
      });
    } catch (e) {
      print('Error playing clear line sound: $e');
    }
  }

  /// Âm thanh game over
  /// Tần số thấp: 262 Hz (C4) → 220 Hz (A3)
  static Future<void> playGameOverSound() async {
    try {
      await platform.invokeMethod('playTone', {
        'frequency': 262,
        'duration': 150,
      });
      await Future.delayed(Duration(milliseconds: 150));
      
      await platform.invokeMethod('playTone', {
        'frequency': 220,
        'duration': 300,
      });
    } catch (e) {
      print('Error playing game over sound: $e');
    }
  }

  /// Âm thanh khi không thể đặt khối
  /// Tần số: 349 Hz (F4) 2 lần
  static Future<void> playInvalidPlaceSound() async {
    try {
      await platform.invokeMethod('playTone', {
        'frequency': 349,
        'duration': 100,
      });
      await Future.delayed(Duration(milliseconds: 150));
      
      await platform.invokeMethod('playTone', {
        'frequency': 349,
        'duration': 100,
      });
    } catch (e) {
      print('Error playing invalid place sound: $e');
    }
  }

  /// Âm thanh level up
  /// Tần số tăng dần: 523 Hz → 659 Hz → 784 Hz
  static Future<void> playLevelUpSound() async {
    try {
      for (int i = 0; i < 3; i++) {
        int frequency = 523 + (i * 150);
        await platform.invokeMethod('playTone', {
          'frequency': frequency,
          'duration': 120,
        });
        await Future.delayed(Duration(milliseconds: 120));
      }
    } catch (e) {
      print('Error playing level up sound: $e');
    }
  }
}

/// Phiên bản fallback - tạo âm thanh bằng Dart (không cần native code)
/// Sử dụng khi platform channel không hoạt động
class SimpleSoundGenerator {
  /// Tạo byte data cho âm thanh đơn giản
  /// Sử dụng định dạng WAV hoặc thô
  static List<int> generateTone(int frequency, int durationMs) {
    const int sampleRate = 44100;
    final int numSamples = (sampleRate * durationMs ~/ 1000);
    final List<int> samples = [];

    for (int i = 0; i < numSamples; i++) {
      // Tạo sóng sin
      double sample = sin((2 * 3.14159 * frequency * i) / sampleRate);
      
      // Envelope (fade in/out)
      if (i < sampleRate ~/ 100) {
        // Fade in
        sample *= i / (sampleRate ~/ 100);
      } else if (i > numSamples - sampleRate ~/ 100) {
        // Fade out
        sample *= (numSamples - i) / (sampleRate ~/ 100);
      }

      // Chuyển sang 16-bit PCM
      int value = (sample * 32767).toInt().clamp(-32768, 32767);
      samples.add(value & 0xFF);
      samples.add((value >> 8) & 0xFF);
    }

    return samples;
  }

  static double sin(double x) {
    // Xấp xỉ sin bằng Taylor series
    x = x % (2 * 3.14159);
    if (x > 3.14159) x -= 2 * 3.14159;
    
    double result = x;
    double term = x;
    
    for (int n = 1; n < 10; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    
    return result;
  }
}