import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/global_player_instance_controller.dart';
import 'package:music_player/presentation/controllers/library_controller.dart';
import 'package:music_player/presentation/controllers/online_audio_controller.dart';
import 'package:music_player/presentation/controllers/online_music_controller.dart';
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
    Get.lazyPut(()=>OnlineMusicController(),fenix: true);
    Get.lazyPut(()=>OnlineAudioController(),fenix: true);
    Get.lazyPut(()=>GlobalPlayerController(),fenix: true);
  }
}
