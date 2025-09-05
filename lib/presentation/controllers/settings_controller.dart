import 'dart:async';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';

class SettingsController extends GetxController {
  final RxInt sleepTimerSeconds = 0.obs;

  Timer? _countdownTimer;

  void setSleepTimerMinutes(int minutes) {
    _countdownTimer?.cancel();
    if (minutes <= 0) {
      sleepTimerSeconds.value = 0;
      return;
    }

    sleepTimerSeconds.value = minutes * 60;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sleepTimerSeconds.value <= 0) {
        timer.cancel();
        sleepTimerSeconds.value = 0;
        try {
          final player = Get.find<UnifiedPlayerController>();
          player.pauseSong();
        } catch (e) {
          sleepTimerSeconds.value = sleepTimerSeconds.value - 1;
        }
      } else {
        sleepTimerSeconds.value = sleepTimerSeconds.value - 1;
      }
    });
  }

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
