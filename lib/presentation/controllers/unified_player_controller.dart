import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/data/services/equalizer_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum PlayMode { shuffle, loopOne, loopAll, stop }
enum PlayerSource { local, online }

class UnifiedPlayerController extends GetxController {
  // IMPORTANT: Make sure this is the ONLY AudioPlayer in the app.
  final AudioPlayer audioPlayer = AudioPlayer();
  final YoutubeExplode yt = YoutubeExplode();

  // Which source is active now
  final Rx<PlayerSource?> activeSource = Rx<PlayerSource?>(null);

  // Local state
  List<SongModel> allSongs = [];
  List<SongModel> currentPlaylist = [];
  List<int> _lastSourceIds = [];
  final Rxn<String> currentPlaylistName = Rxn<String>();
  final RxInt currentIndex = (-1).obs;

  // Display state (used by MiniPlayer/UI)
  final RxString currentTitle = ''.obs;
  final RxString currentArtist = ''.obs;
  final RxString currentThumbnail = ''.obs;

  // Common state
  final Rxn<SongModel> currentSong = Rxn<SongModel>(); // only for local
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxBool isPlaying = false.obs;
  final Rx<PlayMode> playMode = PlayMode.loopAll.obs;

  bool _stopArmed = false;
  bool _stopTriggered = false;

  bool get isPlaylistMode => currentPlaylist.isNotEmpty;
  List<SongModel> get _activeList => isPlaylistMode ? currentPlaylist : allSongs;

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();

    // keep play/pause
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // progress
    audioPlayer.positionStream.listen((pos) {
      position.value = pos;

      if (_stopArmed) {
        final d = audioPlayer.duration;
        if (!_stopTriggered && d != null && pos >= d - const Duration(milliseconds: 200)) {
          _stopTriggered = true;
          audioPlayer.stop();
        }
      }
    });

    // update when the current index changes (LOCAL)
    audioPlayer.currentIndexStream.listen((index) {
      if (index == null) return;
      final list = _activeList;
      if (index >= 0 && index < list.length && activeSource.value == PlayerSource.local) {
        currentIndex.value = index;
        final s = list[index];
        currentSong.value = s;
        _updateDisplayFromLocalSong(s); // << keep UI in sync
        _stopTriggered = false;
      }
    });

    // track total duration
    audioPlayer.durationStream.listen((dur) {
      duration.value = dur ?? Duration.zero;
    });

    // eq init
    audioPlayer.androidAudioSessionIdStream.listen((sessionId) async {
      if (sessionId != null) {
        try {
          EqualizerService.init(sessionId);
          await _restoreEqualizer();
        } catch (_) {
          EqualizerService.init(sessionId);
        }
      }
    });

    // stop mode
    audioPlayer.processingStateStream.listen((state) async {
      if (playMode.value == PlayMode.stop && state == ProcessingState.completed) {
        await audioPlayer.stop();
      }
    });
  }

  Future<void> _restoreEqualizer() async {
    final settings = await EqualizerService.loadSettings();

    if (settings['enabled'] == true) {
      await EqualizerService.setEnabled(true);

      // Restore band levels
      final levels = settings['levels'] as List<int>;
      for (int i = 0; i < levels.length; i++) {
        await EqualizerService.setBandLevel(i, levels[i]);
      }

      // Restore bass boost
      final bass = await EqualizerService.getBassBoost();
      await EqualizerService.setBassBoost(bass);
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  // ---------- helpers ----------
  Future<void> _stopAndReset() async {
    // stop player and clear all state that can conflict across modes
    try { await audioPlayer.stop(); } catch (_) {}
    _stopArmed = false;
    _stopTriggered = false;
    await audioPlayer.setShuffleModeEnabled(false);
    await audioPlayer.setLoopMode(LoopMode.off);
  }

  void _clearLocalState() {
    currentPlaylist = [];
    _lastSourceIds = [];
    currentSong.value = null;
    currentPlaylistName.value = null;
    currentIndex.value = -1;
  }

  void _clearDisplay() {
    currentTitle.value = '';
    currentArtist.value = '';
    currentThumbnail.value = '';
  }

  void _updateDisplayFromLocalSong(SongModel s) {
    currentTitle.value = s.title;
    currentArtist.value = s.artist ?? 'Unknown Artist';
    currentThumbnail.value = ''; // Provide default/local artwork if you have
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
      if (albumId == null || (albumId is int && albumId <= 0)) return await _assetImageUri();
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

  Future<void> _setPlaylistSource(List<SongModel> list, {int initialIndex = 0}) async {
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

  Future<void> _applyPlayMode() async {
    switch (playMode.value) {
      case PlayMode.shuffle:
        _stopArmed = false; _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(true);
        await audioPlayer.shuffle();
        await audioPlayer.setLoopMode(LoopMode.all);
        break;
      case PlayMode.loopOne:
        _stopArmed = false; _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(false);
        await audioPlayer.setLoopMode(LoopMode.one);
        break;
      case PlayMode.loopAll:
        _stopArmed = false; _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(false);
        await audioPlayer.setLoopMode(LoopMode.all);
        break;
      case PlayMode.stop:
        _stopArmed = true; _stopTriggered = false;
        await audioPlayer.setShuffleModeEnabled(false);
        await audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  // ---------- LOCAL ----------
  Future<void> playSong(
      SongModel song,
      List<SongModel> sourceList, {
        String? playlistName,
        int? playlistIndex,
      }) async {
    // if switching from online → local, reset first
    if (activeSource.value == PlayerSource.online) {
      await _stopAndReset();
      _clearLocalState();
      _clearDisplay();
    }

    activeSource.value = PlayerSource.local;
    currentPlaylist = sourceList != allSongs ? sourceList : [];
    if (playlistName != null) currentPlaylistName.value = playlistName;

    final list = _activeList;
    final index = list.indexWhere((s) => s.id == song.id);
    if (index < 0) return;

    currentSong.value = song;
    currentIndex.value = index;
    _updateDisplayFromLocalSong(song);

    await _setPlaylistSource(list, initialIndex: index);
    await _applyPlayMode();
    await audioPlayer.play();
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

  // ---------- ONLINE ----------
  final Map<String, String> _onlineAudioUrlCache = {};
  Future<void> playOnlineAudio(String videoId, String title, String thumbnail) async {
    // if switching from local → online, reset first
    if (activeSource.value == PlayerSource.local) {
      await _stopAndReset();
      _clearLocalState();
    }

    activeSource.value = PlayerSource.online;

    try {
      String audioUrl;

      // Check cache first
      if (_onlineAudioUrlCache.containsKey(videoId)) {
        audioUrl = _onlineAudioUrlCache[videoId]!;
      } else {
        // fetch manifest with timeout
        final manifest = await yt.videos.streamsClient.getManifest(videoId)
            .timeout(const Duration(seconds: 12));
        final audioStream = manifest.audioOnly.withHighestBitrate();
        audioUrl = audioStream.url.toString();

        // Cache it (beware: URLs may expire after some time; choose cache expiration policy if needed)
        _onlineAudioUrlCache[videoId] = audioUrl;
      }

      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: videoId,
            album: 'YouTube',
            title: title,
            artist: 'YouTube',
            artUri: Uri.parse(thumbnail),
          ),
        ),
      );

      // Display fields for online
      currentSong.value = null; // not a local song
      currentTitle.value = title;
      currentArtist.value = 'YouTube';
      currentThumbnail.value = thumbnail;

      await audioPlayer.play();
    } on TimeoutException {
      Get.snackbar('Timeout', 'Failed to fetch audio stream (timeout). Try again.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void pauseOnline() => audioPlayer.pause();
  void resumeOnline() => audioPlayer.play();

  // ---------- Play mode ----------
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

  // ---------- Utils ----------
  String formatDuration(Duration? d) {
    if (d == null) return "0:00";
    final minutes = d.inMinutes.toString();
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool isPlayingSong(SongModel song) => currentSong.value?.id == song.id;

  @override
  void onClose() {
    audioPlayer.dispose();
    yt.close();
    super.onClose();
  }
}
