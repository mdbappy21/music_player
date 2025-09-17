import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/playlist_controller.dart';
import 'package:music_player/presentation/ui/sheets/equalizer_sheet.dart';
import 'package:music_player/presentation/ui/sheets/mini_player_actions_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';

class MusicDetailsScreen extends StatefulWidget {
  final SongModel song;
  final List<SongModel> songs;

  const MusicDetailsScreen({super.key, required this.song, required this.songs});

  @override
  State<MusicDetailsScreen> createState() => _MusicDetailsScreenState();
}

class _MusicDetailsScreenState extends State<MusicDetailsScreen> {
  final UnifiedPlayerController playerController = Get.find<UnifiedPlayerController>();
  PlaylistController playlistController =Get.find<PlaylistController>();

  late Rx<SongModel> selectedSong;

  @override
  void initState() {
    super.initState();
    selectedSong = widget.song.obs;
  }

  void playSelected() {
    final current = playerController.currentSong.value;
    if (current == null || current.id != selectedSong.value.id) {
      playerController.playSong(selectedSong.value, widget.songs);
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
      playerController.playSong(selectedSong.value, widget.songs);
    }
  }

  void playPrevious() {
    final idx = widget.songs.indexWhere((s) => s.id == selectedSong.value.id);
    if (idx > 0) {
      selectedSong.value = widget.songs[idx - 1];
      playerController.playSong(selectedSong.value, widget.songs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Player"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Only show actions sheet for local songs
              if (playerController.currentSong.value != null) {
                showMiniPlayerActionsSheet(
                    context, playerController.currentSong.value!);
              }
            },
          ),
        ],
      ),
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
            const SizedBox(height: 24),
            const Icon(Icons.album, size: 250),
            const SizedBox(height: 24),

            Text(song.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 8),
            Text(song.artist ?? "Unknown Artist",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const Spacer(),
            Container(
              color: Colors.black45,
              child: Column(
                children: [
                  Slider(
                    value: sliderPos.clamp(0, sliderMax).toDouble(),
                    max: sliderMax > 0 ? sliderMax.toDouble() : 1,
                    onChanged: (value) {
                      if (isThisPlaying) {
                        playerController.audioPlayer.seek(Duration(seconds: value.toInt()));
                      }
                    },
                    activeColor: Colors.orange,
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
                          onPressed: (){
                            _onTapFavoriteButton();
                          },
                        icon: Obx(() {
                          final isFavorite = playlistController
                              .isInPlaylist('favorite', selectedSong.value.id); // check
                          return Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 32,
                            // color: isFavorite ? Colors.red : Colors.white,
                          );
                        }),
                      ),
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
                      IconButton(
                        icon: const Icon(Icons.equalizer, color: Colors.white),
                        onPressed: () => showEqualizerSheet(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
  void _onTapFavoriteButton() {
    final songId = selectedSong.value.id;
    final isFavorite = playlistController.isInPlaylist('favorite', songId);

    if (isFavorite) {
      playlistController.removeFromPlaylist('favorite', songId);
      Get.snackbar('Playlist', 'Removed from "Favorite"');
    } else {
      playlistController.addToPlaylist('favorite', songId);
      Get.snackbar('Playlist', 'Added to "Favorite"');
    }
  }

}
