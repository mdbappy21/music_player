import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/library_controller.dart';
import 'package:music_player/presentation/controllers/player_controller.dart';
import 'package:music_player/presentation/ui/widgets/mini_player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'music_details_screen.dart';

class AllMusicScreen extends StatelessWidget {
  const AllMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryController = Get.find<LibraryController>();
    final playerController = Get.find<PlayerController>();

    return Scaffold(
      body: FutureBuilder<List<SongModel>>(
        future: libraryController.loadSongs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data!;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => MusicDetailsScreen(song: song,songs: songs,));
                },
                child: Card(
                  color: Colors.orange.shade200.withValues(alpha: 0.3),
                  child: ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(song.title),
                    subtitle: Text(song.artist ?? "Unknown"),
                    trailing: Obx(() {
                      final isCurrent = playerController.currentSong.value?.id == song.id;
                      final isPlaying = playerController.isPlaying.value;

                      return IconButton(
                        icon: Icon(
                          isCurrent ? (isPlaying ? Icons.pause : Icons.play_arrow) : Icons.play_arrow,
                        ),
                        onPressed: () {
                          if (isCurrent) {
                            if (isPlaying) {
                              playerController.pauseSong();
                            } else {
                              playerController.resumeSong();
                            }
                          } else {
                            playerController.playSingle(song,songs);
                          }
                        },
                      );
                    }),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Obx(() {
        return playerController.currentSong.value == null
            ? const SizedBox.shrink()
            : const MiniPlayer();
      }),
    );
  }
}
