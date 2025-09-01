import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LibraryController extends GetxController {
  final OnAudioQuery audioQuery = OnAudioQuery();

  Future<List<SongModel>> loadSongs() async {
    bool hasPermission = await audioQuery.permissionsStatus();
    if (!hasPermission) {
      hasPermission = await audioQuery.permissionsRequest();
    }

    if (!hasPermission) {
      Get.snackbar('Permission Denied', 'Give Music and audio Permission');
      Get.snackbar('Where to give Permission', 'App info => permissions => Allow Permission',duration: Duration(seconds: 5));
      return [];
    }

    final songs = await audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songs;
  }
}
