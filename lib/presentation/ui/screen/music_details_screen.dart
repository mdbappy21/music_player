import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/presentation/controllers/player_controller.dart';

class MusicDetailsScreen extends StatefulWidget {
  final SongModel song;
  final List<SongModel> songs;

  const MusicDetailsScreen({super.key, required this.song, required this.songs});

  @override
  State<MusicDetailsScreen> createState() => _MusicDetailsScreenState();
}

class _MusicDetailsScreenState extends State<MusicDetailsScreen> {
  final PlayerController playerController = Get.find<PlayerController>();

  late Rx<SongModel> selectedSong;

  @override
  void initState() {
    super.initState();
    selectedSong = widget.song.obs;
  }

  void playSelected() {
    final current = playerController.currentSong.value;
    if (current == null || current.id != selectedSong.value.id) {
      playerController.playSingle(selectedSong.value, widget.songs);
    } else {
      if (playerController.isPlaying.value) {
        playerController.pauseSong();
      } else {
        playerController.resumeSong();
      }
    }
  }

  void playNext() {
    final idx = widget.songs.indexWhere((s) => s.id == selectedSong.value.id);
    if (idx != -1 && idx < widget.songs.length - 1) {
      selectedSong.value = widget.songs[idx + 1];
      playerController.playSingle(selectedSong.value, widget.songs);
    }
  }

  void playPrevious() {
    final idx = widget.songs.indexWhere((s) => s.id == selectedSong.value.id);
    if (idx > 0) {
      selectedSong.value = widget.songs[idx - 1];
      playerController.playSingle(selectedSong.value, widget.songs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Now Playing")),
      body: Obx(() {
        final currentSong = playerController.currentSong.value;
        final isPlaying = playerController.isPlaying.value;
        final pos = playerController.position.value;
        final dur = playerController.duration.value;

        final song = selectedSong.value;

        final isThisPlaying = (currentSong != null && currentSong.id == song.id);
        final sliderPos = isThisPlaying ? pos.inSeconds : 0;
        final sliderMax = isThisPlaying ? dur.inSeconds : song.duration! ~/ 1000;

        return Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.album, size: 150),
            const SizedBox(height: 20),

            Text(song.title,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),

            const SizedBox(height: 8),

            Text(song.artist ?? "Unknown Artist",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center),

            const Spacer(),

            Slider(
              value: sliderPos.clamp(0, sliderMax).toDouble(),
              max: sliderMax > 0 ? sliderMax.toDouble() : 1,
              onChanged: (value) {
                if (isThisPlaying) {
                  playerController.audioPlayer
                      .seek(Duration(seconds: value.toInt()));
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(playerController.formatDuration(
                      Duration(seconds: sliderPos))),
                  Text(playerController.formatDuration(
                      Duration(seconds: sliderMax))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40),
                  onPressed: playPrevious,
                ),
                IconButton(
                  icon: Icon(
                    (isThisPlaying && isPlaying)
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    size: 70,
                  ),
                  onPressed: playSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  onPressed: playNext,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}
