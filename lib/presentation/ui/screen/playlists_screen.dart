import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/player_controller.dart';
import 'package:music_player/presentation/controllers/playlist_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'playlist_details_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final PlayerController playerController = Get.find<PlayerController>();
  final OnAudioQuery audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();

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
              trailing: Obx(() {
                final isCurrentPlaylistPlaying = playerController.currentPlaylistName.value == playlist.name &&
                    playerController.isPlaying.value;
                return IconButton(
                  onPressed: () => _onTapPlayButton(playlist, playlist.name, index),
                  icon: Icon(isCurrentPlaylistPlaying ? Icons.pause : Icons.play_arrow),
                );
              }),
              onTap: () {
                Get.to(() => PlaylistDetailsScreen(playlist: playlist));
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () => _onTapFAB(playlistController),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<void> _onTapPlayButton(playlist, String playlistName, int index) async {
    final allSongs = await audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final playlistSongs = allSongs.where((song) => playlist.trackIds.contains(song.id)).toList();
    if (playlistSongs.isEmpty) return;

    final isCurrentPlaylist = playerController.currentPlaylistName.value == playlistName;

    if (isCurrentPlaylist && playerController.isPlaying.value) {
      playerController.pauseSong();
    } else {
      await playerController.playSong(
        playlistSongs.first,
        playlistSongs,
        playlistName: playlistName,
        playlistIndex: index,
      );
    }
  }

  void _onTapFAB(PlaylistController playlistController) {
    final TextEditingController nameController = TextEditingController();
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
              onPressed: () => _onTapCreatePlaylist(playlistController, nameController),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Create", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _onTapCreatePlaylist(PlaylistController playlistController, TextEditingController nameController) {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar("Error", "Enter playlist name");
      return;
    }
    playlistController.createPlaylist(name);
    nameController.clear();
    Get.back();
    Get.snackbar("Playlist", "Created \"$name\"");
  }
}
