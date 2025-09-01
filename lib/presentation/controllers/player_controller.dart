import 'dart:math';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum PlayMode { shuffle, loopOne, loopAll, stop }

class PlayerController extends GetxController {
  final audioPlayer = AudioPlayer();
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  var currentSong = Rxn<SongModel>();
  var isPlaying = false.obs;
  var currentIndex = (-1).obs;
  var playMode = PlayMode.loopAll.obs;

  List<SongModel> allSongs = [];
  List<SongModel> currentPlaylist = [];

  bool get isPlaylistMode => currentPlaylist.isNotEmpty;

  final _random = Random();

  @override
  void onInit() {
    super.onInit();

    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    audioPlayer.positionStream.listen((pos) {
      position.value = pos;
    });
    audioPlayer.durationStream.listen((dur) {
      duration.value = dur ?? Duration.zero;
    });

    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongEnd();
      }
    });
  }

  Future<void> playSong(SongModel song, List<SongModel> sourceList) async {
    currentSong.value = song;
    currentIndex.value = sourceList.indexOf(song);

    if (sourceList != allSongs) {
      currentPlaylist = sourceList;
    } else {
      currentPlaylist = [];
    }

    await audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    await audioPlayer.play();
  }

  void pauseSong() => audioPlayer.pause();
  void resumeSong() => audioPlayer.play();

  Future<void> playSingle(SongModel song, List<SongModel> songList) async {
    await playSong(song, songList);
  }

  void playNext() {
    final list = isPlaylistMode ? currentPlaylist : allSongs;
    if (list.isEmpty) return;

    int nextIndex = (currentIndex.value + 1) % list.length;
    playSong(list[nextIndex], list);
  }

  void playPrevious() {
    final list = isPlaylistMode ? currentPlaylist : allSongs;
    if (list.isEmpty) return;

    int prevIndex = (currentIndex.value - 1 + list.length) % list.length;
    playSong(list[prevIndex], list);
  }

  void _playRandomSong() {
    final list = isPlaylistMode ? currentPlaylist : allSongs;
    if (list.isEmpty) return;

    int nextIndex = _random.nextInt(list.length);
    playSong(list[nextIndex], list);
  }

  void _handleSongEnd() {
    switch (playMode.value) {
      case PlayMode.shuffle:
        _playRandomSong();
        break;
      case PlayMode.loopOne:
        playSong(currentSong.value!, isPlaylistMode ? currentPlaylist : allSongs);
        break;
      case PlayMode.loopAll:
        playNext();
        break;
      case PlayMode.stop:
        pauseSong();
        break;
    }
  }

  void togglePlayMode() {
    switch (playMode.value) {
      case PlayMode.loopAll:
        playMode.value = PlayMode.shuffle;
        break;
      case PlayMode.shuffle:
        playMode.value = PlayMode.loopOne;
        break;
      case PlayMode.loopOne:
        playMode.value = PlayMode.stop;
        break;
      case PlayMode.stop:
        playMode.value = PlayMode.loopAll;
        break;
    }
  }

  String formatDuration(Duration? d) {
    if (d == null) return "0:00";
    final m = d.inMinutes.toString();
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool isPlayingSong(SongModel song) {
    return currentSong.value?.id == song.id;
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }
}
