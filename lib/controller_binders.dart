import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/library_controller.dart';
import 'package:music_player/presentation/controllers/online_music_controller.dart';
import 'package:music_player/presentation/controllers/playlist_controller.dart';
import 'package:music_player/presentation/controllers/settings_controller.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>PlaylistController(),fenix: true);
    Get.lazyPut(()=>SettingsController(),fenix: true);
    Get.lazyPut(()=>LibraryController(),fenix: true);
    Get.lazyPut(()=>OnlineMusicController(),fenix: true);
    Get.lazyPut(()=>UnifiedPlayerController(),fenix: true);
  }
}
