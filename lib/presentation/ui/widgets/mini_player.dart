import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';
import 'package:music_player/presentation/ui/sheets/equalizer_sheet.dart';
import 'package:music_player/presentation/ui/sheets/mini_player_actions_sheet.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final UnifiedPlayerController controller = Get.find<UnifiedPlayerController>();

    return Obx(() {
      // Hide only when nothing is playing at all
      if (controller.currentTitle.value.isEmpty) return const SizedBox.shrink();

      final isPlaying = controller.isPlaying.value;
      final playMode = controller.playMode.value;

      IconData getPlayModeIcon() {
        switch (playMode) {
          case PlayMode.shuffle:
            return Icons.shuffle;
          case PlayMode.loopOne:
            return Icons.repeat_one;
          case PlayMode.loopAll:
            return Icons.repeat;
          case PlayMode.stop:
            return Icons.stop_circle;
        }
      }

      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black26,
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
                      Text(controller.currentTitle.value,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(controller.currentArtist.value,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Only show actions sheet for local songs
                    if (controller.currentSong.value != null) {
                      showMiniPlayerActionsSheet(
                          context, controller.currentSong.value!);
                    }
                  },
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
                      value: position.inSeconds
                          .toDouble()
                          .clamp(0, total.inSeconds.toDouble()),
                      max: total.inSeconds > 0
                          ? total.inSeconds.toDouble()
                          : 1.0,
                      onChanged: (value) {
                        controller.audioPlayer
                            .seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.orange,
                      inactiveColor: Colors.white24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(controller.formatDuration(position),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        Text(controller.formatDuration(total),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
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
                  icon: Icon(
                    getPlayModeIcon(),
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: controller.togglePlayMode,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous,
                      color: Colors.white, size: 32),
                  onPressed: controller.playPrevious,
                ),
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.orange,
                    size: 48,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      // Decide pause based on active source
                      if (controller.activeSource.value ==
                          PlayerSource.online) {
                        controller.pauseOnline();
                      } else {
                        controller.pauseSong();
                      }
                    } else {
                      if (controller.activeSource.value ==
                          PlayerSource.online) {
                        controller.resumeOnline();
                      } else {
                        controller.resumeSong();
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next,
                      color: Colors.white, size: 32),
                  onPressed: controller.playNext,
                ),
                IconButton(
                  icon: const Icon(Icons.equalizer, color: Colors.white),
                  onPressed: () => showEqualizerSheet(),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
