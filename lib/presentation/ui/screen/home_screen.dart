import 'package:flutter/material.dart';
import 'package:music_player/presentation/ui/screen/all_music_screen.dart';
import 'package:music_player/presentation/ui/screen/playlists_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black45,
          title:Text('Music Player'),
          centerTitle: true,
          // Row(
          //   children: [
          //     Expanded(
          //       child: TextButton(
          //         onPressed: () {},
          //         child: const Text(
          //           'Music Player',
          //           style: TextStyle(color: Colors.white),
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       child: TextButton(
          //         onPressed: () {},
          //         child: const Text(
          //           'Video Player',
          //           style: TextStyle(color: Colors.white),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Playlists'),
              Tab(text: 'Download'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllMusicScreen(),
            PlaylistsScreen(),
            Center(child: Text('Coming soon'))
          ],
        ),
        drawer: Drawer(),
      ),
    );
  }
}
