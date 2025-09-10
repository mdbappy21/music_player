import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/library_controller.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';
import 'package:music_player/presentation/ui/widgets/mini_player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'music_details_screen.dart';

class AllMusicScreen extends StatelessWidget {
  const AllMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryController = Get.find<LibraryController>();
    final UnifiedPlayerController playerController = Get.find<UnifiedPlayerController>();

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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => MusicDetailsScreen(song: song,songs: songs,));
                  },
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    color: const Color.fromARGB(81, 108, 68, 23),
                    child: SizedBox(
                      height: 96,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.yellow,
                                  // Colors.green,
                                  // Colors.blue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.music_note, color: Colors.black),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    song.title,
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    song.artist ?? "Unknown Artist",
                                    softWrap: true,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 18.0),
                            child: Obx(() {
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
                                    playerController.playSong(song,songs);
                                  }
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const MiniPlayer()
    );
  }
}
