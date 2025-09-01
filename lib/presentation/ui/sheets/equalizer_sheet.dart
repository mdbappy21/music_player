import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/ui/widgets/equalizer_widget.dart';

void showEqualizerSheet() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Equalizer",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 12),
            EqualizerWidget(),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
