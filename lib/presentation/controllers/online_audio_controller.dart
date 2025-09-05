import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/presentation/controllers/global_player_instance_controller.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class OnlineAudioController extends GetxController {
  final player = Get.find<GlobalPlayerController>().player;
  final yt = YoutubeExplode();

  RxBool isPlaying = false.obs;
  RxString currentTitle = ''.obs;
  RxString currentThumbnail = ''.obs;

  Future<void> playAudio(String videoId, String title, String thumbnail) async {
    try {
      // Get audio stream URL from YouTube
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();

      // Set audio source with just_audio_background MediaItem
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioStream.url.toString()),
          tag: MediaItem(
            id: videoId,
            album: 'YouTube',
            title: title,
            artUri: Uri.parse(thumbnail),
          ),
        ),
      );

      await player.play();
      isPlaying.value = true;
      currentTitle.value = title;
      currentThumbnail.value = thumbnail;

    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void pause() {
    player.pause();
    isPlaying.value = false;
  }

  void resume() {
    player.play();
    isPlaying.value = true;
  }

  @override
  void onClose() {
    player.dispose();
    yt.close();
    super.onClose();
  }
}
