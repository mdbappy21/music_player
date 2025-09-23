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
                  // Extract safely:
                  String? videoId;
                  String title = 'Unknown';
                  String thumbnail = '';

                  try {
                    final idObj = video['id'];
                    if (idObj is Map && idObj['videoId'] != null) {
                      videoId = idObj['videoId'].toString();
                    } else if (idObj is String) {
                      videoId = idObj;
                    }
                    final snippet = video['snippet'];
                    if (snippet is Map) {
                      title = snippet['title']?.toString() ?? title;
                      thumbnail = (snippet['thumbnails'] is Map && snippet['thumbnails']['default'] is Map) ? snippet['thumbnails']['default']['url']?.toString() ?? '' : '';
                    }
                  } catch (_) {
                    // ignore, will show minimal UI
                  }

                  if (videoId == null) {
                    return const SizedBox.shrink(); // skip invalid entry
                  }
                  return Card(
                    elevation: 2,
                    color: Colors.black45,
                    child: ListTile(
                      leading: thumbnail.isNotEmpty ? Image.network(thumbnail) : const Icon(Icons.music_note),
                      title: Text(title),
                      subtitle: Obx(() {
                        final d = controller.onlineDurations[videoId];
                        if (d == null) return const Text("Live / Unknown");
                        final minutes = d.inMinutes;
                        final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
                        return Text("Duration: $minutes:$seconds");
                      }),

                      trailing: Obx(() {
                        final isPlayingNow = audioController.activeSource.value ==
                            PlayerSource.online &&
                            audioController.currentTitle.value == title &&
                            audioController.isPlaying.value;

                        return IconButton(
                          icon: Icon(
                              isPlayingNow ? Icons.pause_circle_filled : Icons
                                  .play_circle_fill,
                              color: Colors.orange),
                          onPressed: () {
                            if (isPlayingNow) {
                              audioController.pauseOnline();
                            } else {
                              audioController.playOnlineAudio(
                                  videoId!, title, thumbnail);
                            }
                          },
                        );
                      }),
                      onTap: () {
                        Get.to(() => YoutubePlayerPage(videoId: videoId!));
                      },
                    ),
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
