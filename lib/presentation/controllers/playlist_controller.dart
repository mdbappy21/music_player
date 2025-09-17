import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:music_player/data/models/playlist.dart';

class PlaylistController extends GetxController {
  final playlists = <Playlist>[].obs;
  late Box<Playlist> _box;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box<Playlist>('playlists');

    playlists.assignAll(_box.values.toList());

    if (playlists.where((p) => p.id == 'favorite').isEmpty) {
      final favorite = Playlist(id: 'favorite', name: 'Favorite', trackIds: []);
      playlists.insert(0, favorite);
      _box.put(favorite.id, favorite);
    }
  }

  void createPlaylist(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final pl = Playlist(id: id, name: name, trackIds: []);
    playlists.add(pl);
    _box.put(pl.id, pl);
  }

  void addToPlaylist(String playlistId, int trackId) {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;

    if (!playlists[idx].trackIds.contains(trackId)) {
      playlists[idx].trackIds.add(trackId);
      playlists[idx] = Playlist(
        id: playlists[idx].id,
        name: playlists[idx].name,
        trackIds: List.from(playlists[idx].trackIds),
      );
      playlists.refresh();
      _box.put(playlists[idx].id, playlists[idx]);
    }
  }

  bool isInPlaylist(String playlistId, int trackId) {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return false;
    return playlists[idx].trackIds.contains(trackId);
  }

  void removeFromPlaylist(String playlistId, int trackId) {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;

    if (playlists[idx].trackIds.contains(trackId)) {
      playlists[idx].trackIds.remove(trackId);
      playlists[idx] = Playlist(
        id: playlists[idx].id,
        name: playlists[idx].name,
        trackIds: List.from(playlists[idx].trackIds),
      );
      playlists.refresh();
      _box.put(playlists[idx].id, playlists[idx]);
    }
  }

  void deletePlaylist(String playlistId) {
    if (playlistId == 'favorite') return;

    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;

    final pl = playlists[idx];
    playlists.removeAt(idx);
    _box.delete(pl.id);
  }

  void updatePlaylistName(String playlistId, String newName) {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;

    final updatedPlaylist = Playlist(
      id: playlists[idx].id,
      name: newName,
      trackIds: List.from(playlists[idx].trackIds),
    );

    playlists[idx] = updatedPlaylist;
    playlists.refresh();

    _box.put(updatedPlaylist.id, updatedPlaylist);
  }

}
