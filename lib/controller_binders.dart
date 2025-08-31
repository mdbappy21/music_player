import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/library_controller.dart';
import 'package:music_player/presentation/controllers/player_controller.dart';
import 'package:music_player/presentation/controllers/playlist_controller.dart';
import 'package:music_player/presentation/controllers/settings_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(()=>PlayerController(),fenix: true);
    Get.lazyPut(()=>PlaylistController(),fenix: true);
    Get.lazyPut(()=>SettingsController(),fenix: true);
    Get.lazyPut(()=>LibraryController(),fenix: true);
  }
}
