import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/online_music_controller.dart';
import 'package:music_player/presentation/controllers/online_audio_controller.dart';
import 'package:music_player/presentation/ui/screen/youtube_player_page.dart';
import 'package:music_player/presentation/ui/widgets/online_mini_player.dart';

class OnlineMusicScreen extends StatelessWidget {
  OnlineMusicScreen({super.key});

  final OnlineMusicController controller = Get.find<OnlineMusicController>();
  final OnlineAudioController audioController = Get.find<OnlineAudioController>();

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
                    trailing: IconButton(
                      icon: const Icon(Icons.audiotrack),
                      onPressed: () {
                        audioController.playAudio(videoId, title, thumbnail);
                      },
                    ),
                    onTap: () {
                      Get.to(() => YoutubePlayerPage(videoId: videoId));
                    },
                  );
                },
              );
            }),
          ),

          // Mini audio player (always reactive)
          // Obx(() {
          //   final isPlaying = audioController.isPlaying.value;
          //   final title = audioController.currentTitle.value;
          //   final thumbnail = audioController.currentThumbnail.value;
          //
          //   if (!isPlaying && title.isEmpty) return const SizedBox.shrink();
          //
          //   return Container(
          //     color: Colors.black87,
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          //     child: Row(
          //       children: [
          //         if (thumbnail.isNotEmpty)
          //           Image.network(
          //             thumbnail,
          //             width: 50,
          //             height: 50,
          //           ),
          //         const SizedBox(width: 8),
          //         Expanded(
          //           child: Text(
          //             title,
          //             style: const TextStyle(color: Colors.white),
          //             maxLines: 1,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //         ),
          //         IconButton(
          //           icon: Icon(
          //             isPlaying ? Icons.pause : Icons.play_arrow,
          //             color: Colors.white,
          //           ),
          //           onPressed: () {
          //             if (isPlaying) {
          //               audioController.pause();
          //             } else {
          //               audioController.resume();
          //             }
          //           },
          //         ),
          //       ],
          //     ),
          //   );
          // }),
          OnlineMiniPlayer()
        ],
      ),
    );
  }
}
