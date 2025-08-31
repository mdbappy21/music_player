import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/playlist_controller.dart';
import 'playlist_details_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      body: Obx(() {
        final playlists = playlistController.playlists;
        if (playlists.isEmpty) {
          return const Center(child: Text("No Playlists yet"));
        }
        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return ListTile(
              leading: const Icon(Icons.queue_music),
              title: Text(playlist.name),
              subtitle: Text("${playlist.trackIds.length} songs"),
              onTap: () {
                Get.to(() => PlaylistDetailsScreen(playlist: playlist));
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create New Playlist",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Playlist name",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        Get.snackbar("Error", "Enter playlist name");
                        return;
                      }
                      playlistController.createPlaylist(name);
                      nameController.clear();
                      Get.back();
                      Get.snackbar("Playlist", "Created \"$name\"");
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Create"),
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
          );
        },
      ),
    );
  }
}
