import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../data/models/playlist.dart';

class PlaylistController extends GetxController {
  final playlists = <Playlist>[].obs;
  late Box<Playlist> _box;

  @override
  void onInit() {
    super.onInit();
    _box = Hive.box<Playlist>('playlists');

    // load saved playlists
    playlists.assignAll(_box.values.toList());

    // ensure default "Favorite" playlist exists
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
}
