import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/data/services/equalizer_service.dart';
import 'package:path_provider/path_provider.dart';

enum PlayMode { shuffle, loopOne, loopAll, stop }

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool _stopArmed = false;
  bool _stopTriggered = false;

  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rxn<SongModel> currentSong = Rxn<SongModel>();
  final RxBool isPlaying = false.obs;
  final RxInt currentIndex = (-1).obs;
  final Rx<PlayMode> playMode = PlayMode.loopAll.obs;

  List<SongModel> allSongs = [];
  List<SongModel> currentPlaylist = [];
  List<int> _lastSourceIds = [];

  bool get isPlaylistMode => currentPlaylist.isNotEmpty;
  List<SongModel> get _activeList => isPlaylistMode ? currentPlaylist : allSongs;

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();

    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    audioPlayer.positionStream.listen((pos) {
      position.value = pos;

      if (_stopArmed) {
        final d = audioPlayer.duration;
        if (!_stopTriggered &&
            d != null &&
            pos >= d - const Duration(milliseconds: 200)) {
          _stopTriggered = true;
          audioPlayer.stop();
        }
      }
    });

    audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        final list = _activeList;
        if (index >= 0 && index < list.length) {
          currentIndex.value = index;
          currentSong.value = list[index];
          _stopTriggered = false;
        }
      }
    });

    audioPlayer.durationStream.listen((dur) {
      duration.value = dur ?? Duration.zero;
    });

    audioPlayer.androidAudioSessionIdStream.listen((sessionId) {
      if (sessionId != null) {
        try {
          EqualizerService.init(sessionId);
        } catch (_) {
          EqualizerService.init(sessionId);
        }
      }
    });

    // ✅ Handle Stop mode reliably
    audioPlayer.processingStateStream.listen((state) async {
      if (playMode.value == PlayMode.stop &&
          state == ProcessingState.completed) {
        await audioPlayer.stop();
      }
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<Uri> _assetImageUri() async {
    final byteData = await rootBundle.load('assets/images/musicLogo.png');
    final file = File('${(await getTemporaryDirectory()).path}/musicLogo.png');
    if (!await file.exists()) {
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    return Uri.file(file.path);
  }

  Future<Uri?> _artUriForSong(SongModel song) async {
    try {
      final albumId = (song as dynamic).albumId;
      if (albumId == null || (albumId is int && albumId <= 0)) {
        return await _assetImageUri();
      }
      return await _assetImageUri();
    } catch (_) {
      return await _assetImageUri();
    }
  }

  Future<List<AudioSource>> _buildAudioSources(List<SongModel> list) async {
    final List<AudioSource> sources = [];
    for (final s in list) {
      final artUri = await _artUriForSong(s);
      sources.add(
        AudioSource.uri(
          Uri.parse(s.uri!),
          tag: MediaItem(
            id: s.id.toString(),
            album: s.album ?? '',
            title: s.title,
            artist: s.artist ?? 'Unknown Artist',
            artUri: artUri,
            duration: Duration(milliseconds: s.duration ?? 0),
          ),
        ),
      );
    }
    return sources;
  }

  bool _sameSourceAs(List<SongModel> list) {
    if (_lastSourceIds.length != list.length) return false;
    for (var i = 0; i < list.length; i++) {
      if (_lastSourceIds[i] != list[i].id) return false;
    }
    return true;
  }

  Future<void> _setPlaylistSource(List<SongModel> list,
      {int initialIndex = 0}) async {
    final ids = list.map((e) => e.id).toList();
    if (!_sameSourceAs(list)) {
      final sources = await _buildAudioSources(list);
      _lastSourceIds = ids;
      await audioPlayer.setAudioSources(
        sources,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
    } else {
      await audioPlayer.seek(Duration.zero, index: initialIndex);
    }
  }

  Future<void> playSong(SongModel song, List<SongModel> sourceList) async {
    try {
      currentPlaylist = sourceList != allSongs ? sourceList : [];
      final list = _activeList;

      final index = list.indexWhere((s) => s.id == song.id);
      if (index < 0) return;

      currentSong.value = song;
      currentIndex.value = index;

      await _setPlaylistSource(list, initialIndex: index);
      await _applyPlayMode();
      await audioPlayer.play();
    } catch (e) {
      await audioPlayer.play();
    }
  }

  Future<void> playSingle(SongModel song, List<SongModel> songList) async {
    await playSong(song, songList);
  }

  void pauseSong() => audioPlayer.pause();
  void resumeSong() => audioPlayer.play();

  Future<void> seek(Duration pos) async {
    _stopTriggered = false;
    await audioPlayer.seek(pos);
  }

  Future<void> playNext() async {
    if (playMode.value == PlayMode.stop) return;
    if (audioPlayer.sequence.isNotEmpty) {
      await audioPlayer.seekToNext();
      await audioPlayer.play();
    } else {
      final list = _activeList;
      if (list.isEmpty) return;
      final nextIndex = (currentIndex.value + 1) % list.length;
      await playSong(list[nextIndex], list);
    }
  }

  Future<void> playPrevious() async {
    if (playMode.value == PlayMode.stop) return;
    if (audioPlayer.sequence.isNotEmpty) {
      await audioPlayer.seekToPrevious();
      await audioPlayer.play();
    } else {
      final list = _activeList;
      if (list.isEmpty) return;
      final prevIndex = (currentIndex.value - 1 + list.length) % list.length;
      await playSong(list[prevIndex], list);
    }
  }

  Future<void> _applyPlayMode() async {
    switch (playMode.value) {
      case PlayMode.shuffle:
        _stopArmed = false;
        _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(true);
        await audioPlayer.shuffle();
        await audioPlayer.setLoopMode(LoopMode.all);
        break;

      case PlayMode.loopOne:
        _stopArmed = false;
        _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(false);
        await audioPlayer.setLoopMode(LoopMode.one);
        break;

      case PlayMode.loopAll:
        _stopArmed = false;
        _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(false);
        await audioPlayer.setLoopMode(LoopMode.all);
        break;

      case PlayMode.stop:
        _stopArmed = true;
        _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(false);
        await audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  Future<void> togglePlayMode() async {
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
    await _applyPlayMode();
  }

  String formatDuration(Duration? d) {
    if (d == null) return "0:00";
    final minutes = d.inMinutes.toString();
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool isPlayingSong(SongModel song) => currentSong.value?.id == song.id;
}
