// lib/presentation/ui/sheets/add_to_playlist_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/playlist_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

void showAddToPlaylistSheet(BuildContext context, SongModel song) {
  final playlistController = Get.find<PlaylistController>();
  final TextEditingController nameController = TextEditingController();

  Get.bottomSheet(
    Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          const Text('Add to Playlist', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Song: ', style: TextStyle(color: Colors.grey.shade300)),
          Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),

          // create new playlist
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'New playlist name (press create)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    Get.snackbar('Error', 'Enter playlist name');
                    return;
                  }
                  playlistController.createPlaylist(name);
                  // find newly created and add
                  final newId = playlistController.playlists.last.id;
                  playlistController.addToPlaylist(newId, song.id);
                  Get.back();
                  Get.snackbar('Playlist', 'Added to "$name"');
                },
                child: const Text('Create'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          Expanded(
            child: Obx(() {
              final lists = playlistController.playlists;
              return ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, idx) {
                  final pl = lists[idx];
                  return ListTile(
                    title: Text(pl.name),
                    subtitle: Text('${pl.trackIds.length} songs'),
                    onTap: () {
                      playlistController.addToPlaylist(pl.id, song.id);
                      Get.back();
                      Get.snackbar('Playlist', 'Added to "${pl.name}"');
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
