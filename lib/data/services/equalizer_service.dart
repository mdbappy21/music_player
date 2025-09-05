import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EqualizerService {
  static const MethodChannel _channel = MethodChannel('music_player_equalizer');

  /// Initialize Equalizer with the sessionId from audio player
  static Future<void> init(int sessionId) async {
    try {
      await _channel.invokeMethod('initEqualizer', {'sessionId': sessionId});
    } catch (e) {
      await _channel.invokeMethod('initEqualizer', {'sessionId': sessionId});
    }
  }

  /// Enable or disable equalizer
  static Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setEnabled', {'enabled': enabled});
    } catch (e) {
      await _channel.invokeMethod('setEnabled', {'enabled': enabled});
    }
    final box = await Hive.openBox('equalizer');
    box.put('enabled', enabled);
  }

  static Future<bool> isEnabled() async {
    final box = await Hive.openBox('equalizer');
    return box.get('enabled', defaultValue: false);
  }

  /// Set a specific band level
  static Future<void> setBandLevel(int band, int level) async {
    try {
      await _channel.invokeMethod('setBandLevel', {'band': band, 'level': level});
    } catch (e) {
      await _channel.invokeMethod('setBandLevel', {'band': band, 'level': level});
    }
    final box = await Hive.openBox('equalizer');
    final levels = List<int>.from(box.get('levels', defaultValue: [0,0,0,0,0]));
    if (band >= 0 && band < levels.length) {
      levels[band] = level;
      box.put('levels', levels);
    }
  }

  /// Get saved band levels
  static Future<List<int>> getBandLevels() async {
    final box = await Hive.openBox('equalizer');
    return List<int>.from(box.get('levels', defaultValue: [0, 0, 0, 0, 0]));
  }

  /// Set preset (Normal, Classical, Dance, Custom, etc.)
  static Future<void> setPreset(String preset, List<int> levels) async {
    final box = await Hive.openBox('equalizer');
    box.put('preset', preset);
    box.put('levels', levels);

    // Apply band levels to native equalizer
    for (int i = 0; i < levels.length; i++) {
      await setBandLevel(i, levels[i]);
    }
  }

  /// Load all saved settings safely
  static Future<Map<String, dynamic>> loadSettings() async {
    final box = await Hive.openBox('equalizer');
    final enabled = box.get('enabled', defaultValue: false) as bool;
    final preset = box.get('preset', defaultValue: 'Normal') as String;
    final levels = List<int>.from(box.get('levels', defaultValue: [0, 0, 0, 0, 0]));

    return {
      'enabled': enabled,
      'preset': preset,
      'levels': levels,
    };
  }

  /// Set bass boost (0 to 1000)
  static Future<void> setBassBoost(int value) async {
    try {
      await _channel.invokeMethod('setBassBoost', {'value': value});
    } catch (e) {
      await _channel.invokeMethod('setBassBoost', {'value': value});
    }
    final box = await Hive.openBox('equalizer');
    box.put('bass', value);
  }

  /// Get saved bass boost
  static Future<int> getBassBoost() async {
    final box = await Hive.openBox('equalizer');
    return box.get('bass', defaultValue: 0) as int;
  }
}
