import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/online_music_controller.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';
import 'package:music_player/presentation/ui/screen/youtube_player_page.dart';
import 'package:music_player/presentation/ui/widgets/mini_player.dart';

class OnlineMusicScreen extends StatelessWidget {
  OnlineMusicScreen({super.key});

  final OnlineMusicController controller = Get.find<OnlineMusicController>();
  final UnifiedPlayerController audioController = Get.find<UnifiedPlayerController>();

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search YouTube music...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.searchVideos(searchController.text);
                  },
                ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.videos.isEmpty) {
                return const Center(child: Text('No results'));
              }

              return ListView.builder(
                itemCount: controller.videos.length,
                itemBuilder: (context, index) {
                  final video = controller.videos[index];
                  final videoId = video['id']['videoId'];
                  final title = video['snippet']['title'];
                  final thumbnail = video['snippet']['thumbnails']['default']['url'];

                  return ListTile(
                    leading: Image.network(thumbnail),
                    title: Text(title),
                    trailing: Obx(() {
                      final isThisPlaying = audioController.currentSong.value?.id == videoId &&
                          audioController.isPlaying.value;

                      return IconButton(
                        icon: Icon(
                          isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          if (isThisPlaying) {
                            audioController.pauseSong();
                          } else {
                            audioController.playOnlineAudio(videoId, title, thumbnail);
                          }
                        },
                      );
                    }),

                    onTap: () {
                      Get.to(() => YoutubePlayerPage(videoId: videoId));
                    },
                  );
                },
              );
            }),
          ),
          MiniPlayer()
        ],
      ),
    );
  }
}
