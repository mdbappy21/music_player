import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/player_controller.dart';
import 'package:music_player/presentation/ui/sheets/mini_player_actions_sheet.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.find<PlayerController>();

    return Obx(() {
      if (controller.currentSong.value == null) {
        return const SizedBox.shrink();
      }

      final song = controller.currentSong.value!;
      final isPlaying = controller.isPlaying.value;

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.music_note, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist ?? "Unknown Artist",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed:  (){
                    showMiniPlayerActionsSheet(context, song);
                  }
                ),
              ],
            ),

            StreamBuilder<Duration>(
              stream: controller.audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final total = controller.audioPlayer.duration ?? Duration.zero;

                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds.toDouble(),
                      max: total.inSeconds.toDouble() > 0 ? total.inSeconds.toDouble() : 1.0,
                      onChanged: (value) {
                        controller.audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.orange,
                      inactiveColor: Colors.white24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position),
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(_formatDuration(total),
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                  onPressed: controller.playPrevious,
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.orange,
                    size: 48,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      controller.pauseSong();
                    } else {
                      controller.resumeSong();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
                  onPressed: controller.playNext,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
