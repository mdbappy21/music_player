import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerController extends GetxController {
  final audioPlayer = AudioPlayer();
  final AudioPlayer _player = AudioPlayer();
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  var currentSong = Rxn<SongModel>();
  var isPlaying = false.obs;
  var currentIndex = (-1).obs;


  List<SongModel> allSongs = [];
  List<SongModel> currentPlaylist = [];

  bool get isPlaylistMode => currentPlaylist.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
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

  Future<void> pause() async {
    await _player.pause();
    isPlaying.value = false;
  }

  Future<void> playSingle(SongModel song, List<SongModel>songList) async {
    await playSong(song, songList);
  }
  String formatDuration(Duration? d) {
    if (d == null) return "0:00";
    final m = d.inMinutes.toString();
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool isPlayingSong(SongModel song) {
    return currentSong.value?.id == song.id && isPlaying.value;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
}
