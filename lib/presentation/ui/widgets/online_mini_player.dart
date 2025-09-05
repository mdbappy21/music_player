import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/online_audio_controller.dart';

class OnlineMiniPlayer extends StatelessWidget {
  const OnlineMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineAudioController>();

    return Obx(() {
      if (!controller.isPlaying.value) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black26,
        child: Row(
          children: [
            Image.network(
              controller.currentThumbnail.value,
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.currentTitle.value,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                color: Colors.orange,
              ),
              onPressed: () {
                controller.isPlaying.value
                    ? controller.pause()
                    : controller.resume();
              },
            ),
          ],
        ),
      );
    });
  }
}
