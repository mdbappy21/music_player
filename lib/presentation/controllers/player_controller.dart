import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/data/services/equalizer_service.dart';

enum PlayMode { shuffle, loopOne, loopAll, stop }

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rxn<SongModel> currentSong = Rxn<SongModel>();
  final RxBool isPlaying = false.obs;
  final RxInt currentIndex = (-1).obs;
  final Rx<PlayMode> playMode = PlayMode.loopAll.obs;

  List<SongModel> allSongs = [];
  List<SongModel> currentPlaylist = [];

  final Random _random = Random();

  bool get isPlaylistMode => currentPlaylist.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();

    audioPlayer.playerStateStream.listen((state) => isPlaying.value = state.playing);
    audioPlayer.positionStream.listen((pos) => position.value = pos);
    audioPlayer.durationStream.listen((dur) => duration.value = dur ?? Duration.zero);

    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) _handleSongEnd();
    });

    audioPlayer.androidAudioSessionIdStream.listen((sessionId) {
      if (sessionId != null) {
        try {
          EqualizerService.init(sessionId);
        } catch (e) {
          EqualizerService.init(sessionId);
        }
      }
    });
  }

  /// Initialize Audio Session for Android/iOS
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Uri? _artUriForSong(SongModel song) {
    try {
      final albumId = (song as dynamic).albumId;
      if (albumId == null || (albumId is int && albumId <= 0)) {
        return Uri.parse('https://media.istockphoto.com/id/1175435360/vector/music-note-icon-vector-illustration.jpg?s=612x612&w=0&k=20&c=R7s6RR849L57bv_c7jMIFRW4H87-FjLB8sqZ08mN0OU=');
      }
      return Uri.parse('https://media.istockphoto.com/id/1175435360/vector/music-note-icon-vector-illustration.jpg?s=612x612&w=0&k=20&c=R7s6RR849L57bv_c7jMIFRW4H87-FjLB8sqZ08mN0OU=');
    } catch (e) {
      return Uri.parse('https://media.istockphoto.com/id/1175435360/vector/music-note-icon-vector-illustration.jpg?s=612x612&w=0&k=20&c=R7s6RR849L57bv_c7jMIFRW4H87-FjLB8sqZ08mN0OU=');
    }
  }



  /// Play a song from a list
  Future<void> playSong(SongModel song, List<SongModel> sourceList) async {
    try {
      currentSong.value = song;
      currentIndex.value = sourceList.indexOf(song);

      currentPlaylist = sourceList != allSongs ? sourceList : [];

      // Build MediaItems for all songs in the current list
      final List<AudioSource> audioSources = sourceList.map((s) {
        final artUri = _artUriForSong(s);
        return AudioSource.uri(
          Uri.parse(s.uri!),
          tag: MediaItem(
            id: s.id.toString(),
            album: s.album ?? '',
            title: s.title,
            artist: s.artist ?? 'Unknown Artist',
            artUri: artUri,
            duration: Duration(milliseconds: s.duration ?? 0),
          ),
        );
      }).toList();

      // Use ConcatenatingAudioSource for lock screen previous/next support
      await audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSources),
        initialIndex: currentIndex.value,
      );

      await audioPlayer.play();
    } catch (e) {
      await audioPlayer.play();
    }
  }


  /// Play single song (alias)
  Future<void> playSingle(SongModel song, List<SongModel> songList) async {
    await playSong(song, songList);
  }

  /// Pause playback
  void pauseSong() => audioPlayer.pause();

  /// Resume playback
  void resumeSong() => audioPlayer.play();

  /// Seek to position
  Future<void> seek(Duration pos) async => audioPlayer.seek(pos);

  /// Play next song
  void playNext() {
    final list = isPlaylistMode ? currentPlaylist : allSongs;
    if (list.isEmpty) return;

    int nextIndex = (currentIndex.value + 1) % list.length;
    playSong(list[nextIndex], list);
  }

  /// Play previous song
  void playPrevious() {
    final list = isPlaylistMode ? currentPlaylist : allSongs;
    if (list.isEmpty) return;

    int prevIndex = (currentIndex.value - 1 + list.length) % list.length;
    playSong(list[prevIndex], list);
  }

  /// Play a random song (shuffle)
  void _playRandomSong() {
    final list = isPlaylistMode ? currentPlaylist : allSongs;
    if (list.isEmpty) return;

    int nextIndex = _random.nextInt(list.length);
    playSong(list[nextIndex], list);
  }

  /// Handle end of song based on play mode
  void _handleSongEnd() {
    switch (playMode.value) {
      case PlayMode.shuffle:
        _playRandomSong();
        break;
      case PlayMode.loopOne:
      // replay same song
        if (currentSong.value != null) {
          playSong(currentSong.value!, isPlaylistMode ? currentPlaylist : allSongs);
        }
        break;
      case PlayMode.loopAll:
        playNext();
        break;
      case PlayMode.stop:
        pauseSong();
        break;
    }
  }

  /// Toggle play mode (shuffle -> loopOne -> stop -> loopAll)
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

  /// Format duration for UI
  String formatDuration(Duration? d) {
    if (d == null) return "0:00";
    final minutes = d.inMinutes.toString();
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Check if a song is currently playing
  bool isPlayingSong(SongModel song) => currentSong.value?.id == song.id;
}
