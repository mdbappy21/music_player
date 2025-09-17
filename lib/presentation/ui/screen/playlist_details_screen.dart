import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/data/models/playlist.dart';
import 'package:music_player/presentation/controllers/playlist_controller.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';
import 'package:music_player/presentation/ui/screen/home_screen.dart';
import 'package:music_player/presentation/ui/widgets/mini_player.dart';
import 'music_details_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';


class PlaylistDetailsScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistDetailsScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  final UnifiedPlayerController playerController = Get.find<UnifiedPlayerController>();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<SongModel> playlistSongs = [];

  @override
  void initState() {
    super.initState();
    fetchPlaylistSongs();
  }

  Future<void> fetchPlaylistSongs() async {
    final allSongs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    setState(() {
      playlistSongs = allSongs.where((song) => widget.playlist.trackIds.contains(song.id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _onEditPlaylistName(),
          ),
        ],
      ),
      body:  playlistSongs.isEmpty ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "No songs in this playlist",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                _onAddSongsToPlaylist();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Songs"),
            ),
          ],
        ),
      ) : ListView.builder(
        itemCount: playlistSongs.length,
        itemBuilder: (context, index) {
          final song = playlistSongs[index];

          return GestureDetector(
            onTap: (){
              Get.to(()=>MusicDetailsScreen(song: song, songs: playlistSongs));
            },
            onLongPress: () {
              Get.defaultDialog(
                title: "Remove Song",
                middleText: "Remove \"${song.title}\" from this playlist?",
                confirm: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    final playlistController = Get.find<PlaylistController>();
                    playlistController.removeFromPlaylist(widget.playlist.id, song.id);
                    fetchPlaylistSongs(); // refresh the list
                    Get.back();
                    Get.snackbar(
                      "Removed",
                      "\"${song.title}\" removed from ${widget.playlist.name}",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text("Remove", style: TextStyle(color: Colors.white)),
                ),
                cancel: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                color: const Color.fromARGB(115, 108, 34, 23),
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
                            colors: [Colors.orange, Colors.deepOrange, Colors.orange],
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
                          final isCurrent = playerController.isPlayingSong(song);
                          return IconButton(
                            onPressed: () {
                              if (isCurrent) {
                                playerController.pauseSong();
                              } else {
                                playerController.playSong(song, playlistSongs);
                                playerController.currentSong.value = song;
                              }
                            },
                            icon: Icon(isCurrent ? Icons.pause : Icons.play_arrow),
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
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
  void _onEditPlaylistName() {
    final playlistController = Get.find<PlaylistController>();
    final TextEditingController nameController = TextEditingController(text: widget.playlist.name);

    Get.defaultDialog(
      title: "Edit Playlist Name",
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          hintText: "Enter new name",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        onPressed: () {
          final newName = nameController.text.trim();
          if (newName.isEmpty) {
            Get.snackbar("Error", "Name cannot be empty");
            return;
          }

          widget.playlist.name = newName;
          playlistController.playlists.refresh();

          playlistController.updatePlaylistName(widget.playlist.id, newName);
          setState(() {});
          Get.back();
          Get.snackbar("Success", "Playlist renamed to \"$newName\"");
        },
        child: const Text("Save", style: TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  void _onAddSongsToPlaylist() {
    Get.to(()=>HomeScreen());
  }
}
