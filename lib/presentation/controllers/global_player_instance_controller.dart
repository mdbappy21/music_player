import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class GlobalPlayerController extends GetxController {
  final player = AudioPlayer();

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
