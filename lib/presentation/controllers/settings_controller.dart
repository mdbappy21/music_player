// lib/presentation/controllers/settings_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'player_controller.dart';

class SettingsController extends GetxController {
  // remaining seconds for the sleep timer (0 = off)
  final RxInt sleepTimerSeconds = 0.obs;

  Timer? _countdownTimer;

  /// Set a sleep timer in minutes (0 to disable).
  void setSleepTimerMinutes(int minutes) {
    _countdownTimer?.cancel();
    if (minutes <= 0) {
      sleepTimerSeconds.value = 0;
      return;
    }

    sleepTimerSeconds.value = minutes * 60;

    // countdown every second and pause player when reaches zero
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sleepTimerSeconds.value <= 0) {
        timer.cancel();
        sleepTimerSeconds.value = 0;
        try {
          // pause player when timer finishes
          final player = Get.find<PlayerController>();
          player.pause();
        } catch (e) {
          print('No PlayerController available to pause: $e');
        }
      } else {
        sleepTimerSeconds.value = sleepTimerSeconds.value - 1;
      }
    });
  }

  /// Cancel/remove the sleep timer
  void removeSleepTimer() {
    _countdownTimer?.cancel();
    sleepTimerSeconds.value = 0;
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
