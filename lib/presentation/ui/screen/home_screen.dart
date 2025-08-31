import 'package:flutter/material.dart';
import 'package:music_player/presentation/ui/screen/all_music_screen.dart';
import 'package:music_player/presentation/ui/screen/playlists_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Music Player"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllMusicScreen(),
            PlaylistsScreen(),
          ],
        ),
      ),
    );
  }
}
