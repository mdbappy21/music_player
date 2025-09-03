import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/settings_controller.dart';

void showSleepTimerSheet() {
  final settingsController = Get.find<SettingsController>();
  final RxInt minutes = RxInt((settingsController.sleepTimerSeconds.value / 60).round());

  Get.bottomSheet(
    StatefulBuilder(builder: (context, setState) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            const Text('Set Sleep Timer (minutes)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Obx(() {
              final remaining = settingsController.sleepTimerSeconds.value;
              if (remaining > 0) {
                final remMin = (remaining / 60).floor();
                return Text('Remaining: $remMin minute(s)');
              } else {
                return const Text('No timer set');
              }
            }),
            const SizedBox(height: 12),
            Obx(() {
              return Column(
                children: [
                  Slider(
                    activeColor: Colors.orange,
                    min: 0,
                    max: 60,
                    divisions: 60,
                    value: minutes.value.toDouble(),
                    onChanged: (v) {
                      minutes.value = v.toInt();
                      setState(() {});
                    },
                  ),
                  Text('${minutes.value} minute(s)'),
                ],
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Set Timer'),
                    onPressed: () {
                      settingsController.setSleepTimerMinutes(minutes.value);
                      Get.back();
                      Get.snackbar('Sleep Timer', 'Set for ${minutes.value} minute(s)');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    child: const Text('Remove Timer',style: TextStyle(color: Colors.black),),
                    onPressed: () {
                      settingsController.removeSleepTimer();
                      Get.back();
                      Get.snackbar('Sleep Timer', 'Removed');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    }),
    isScrollControlled: false,
  );
}
