import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../controllers/player_controller.dart';

class MusicDetailsScreen extends StatefulWidget {
  final SongModel song;
  final List<SongModel> songs;

  const MusicDetailsScreen({
    super.key,
    required this.song,
    required this.songs,
  });

  @override
  State<MusicDetailsScreen> createState() => _MusicDetailsScreenState();
}

class _MusicDetailsScreenState extends State<MusicDetailsScreen> {
  final PlayerController playerController = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    // Play song if not already
    if (!playerController.isPlayingSong(widget.song)) {
      playerController.playSingle(widget.song, widget.songs);
    }

    // Listen to audioPlayer streams for position and duration updates
    playerController.audioPlayer.positionStream.listen((pos) {
      playerController.position.value = pos;
    });
    playerController.audioPlayer.durationStream.listen((dur) {
      playerController.duration.value = dur ?? Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final currentSong = playerController.currentSong.value ?? widget.song;
          return Text(currentSong.title);
        }),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.album, size: 150),
          const SizedBox(height: 20),
          Obx(() {
            final currentSong = playerController.currentSong.value ?? widget.song;
            return Column(
              children: [
                Text(
                  currentSong.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  currentSong.artist ?? "Unknown Artist",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }),
          const Spacer(),

          // Mini-player controls
          Obx(() {
            final currentSong = playerController.currentSong.value ?? widget.song;
            final isCurrent = playerController.isPlayingSong(currentSong);
            final currentPos = playerController.position.value;
            final totalDuration = playerController.duration.value;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Slider
                Slider(
                  value: playerController.position.value.inSeconds.clamp(0, playerController.duration.value.inSeconds).toDouble(),
                  max: playerController.duration.value.inSeconds.toDouble() > 0
                      ? playerController.duration.value.inSeconds.toDouble()
                      : 1,
                  onChanged: (value) {
                    playerController.audioPlayer.seek(Duration(seconds: value.toInt())); // use correct audioPlayer
                  },
                ),


                // Position / Duration
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(playerController.formatDuration(currentPos)),
                      Text(playerController.formatDuration(totalDuration)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 40),
                      onPressed: playerController.playPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        isCurrent ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        size: 70,
                      ),
                      onPressed: () {
                        final loadedSong = playerController.currentSong.value;

                        if (loadedSong?.id == currentSong.id) {
                          if (playerController.isPlaying.value) {
                            playerController.pauseSong();
                          } else {
                            playerController.resumeSong(); // resume instead of playSingle
                          }
                        } else {
                          // switch to a new song
                          playerController.playSingle(currentSong, widget.songs);
                        }
                      },

                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 40),
                      onPressed: playerController.playNext,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }
}
