import 'package:get/get.dart';
import 'package:music_player/presentation/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final RxInt _currentIndex = (-1).obs;
  final RxBool _isPlaying = false.obs;

  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    requestPermission();

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying.value = false;
        _currentIndex.value = -1;
      }
    });
  }

  Future<void> requestPermission() async {
    if (!await Permission.audio.isGranted) {
      await Permission.audio.request();
    }
    setState(() {});
  }

  Future<void> _playSongAtIndex(int index) async {
    if (_songs.isEmpty || index < 0 || index >= _songs.length) return;

    final song = _songs[index];
    try {
      _currentIndex.value = index;
      _isPlaying.value = true;

      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
      await _audioPlayer.play();
    } catch (e) {
      _isPlaying.value = false;
      _currentIndex.value = -1;
    }
  }

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
    _isPlaying.value = false;
  }

  void _playNextSong() {
    if (_songs.isEmpty) return;

    int nextIndex = _currentIndex.value + 1;
    if (nextIndex >= _songs.length) {
      nextIndex = 0; // loop to first
    }
    _playSongAtIndex(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Music Player")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FutureBuilder<List<SongModel>>(
                future: _audioQuery.querySongs(
                  sortType: SongSortType.TITLE,
                  orderType: OrderType.ASC_OR_SMALLER,
                  uriType: UriType.EXTERNAL,
                  ignoreCase: true,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CenteredCircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No music found"));
                  }

                  if (_songs.isEmpty) {
                    _songs = snapshot.data!;
                  }

                  return ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        color: const Color.fromARGB(115, 108, 34, 23),
                        child: SizedBox(
                          height: 96,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 48,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [Colors.orange, Colors.deepOrange, Colors.orange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(Icons.music_note, color: Colors.black),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        song.title,
                                        softWrap: true,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        song.artist ?? "Unknown Artist",
                                        softWrap: true,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: Obx(() {
                                  final isCurrent = (_currentIndex.value == index) && _isPlaying.value;
                                  return IconButton(
                                    onPressed: () {
                                      if (isCurrent) {
                                        _pauseSong();
                                      } else {
                                        _playSongAtIndex(index);
                                      }
                                    },
                                    icon: Icon(isCurrent ? Icons.pause : Icons.play_arrow),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 60,
            child: Obx(() {
              final isPlaying = _isPlaying.value;
              final currentIndex = _currentIndex.value;

              final title = (currentIndex >= 0 && currentIndex < _songs.length)
                  ? _songs[currentIndex].title
                  : "No song playing";

              return Row(
                children: [
                  const SizedBox(
                    height: 40,
                    width: 40,
                    child: Icon(Icons.music_note, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        _pauseSong();
                      } else {
                        if (currentIndex == -1 && _songs.isNotEmpty) {
                          _playSongAtIndex(0);
                        } else if (currentIndex >= 0) {
                          _playSongAtIndex(currentIndex);
                        }
                      }
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: _playNextSong,
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                  ),
                  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.list, color: Colors.white, size: 30),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
