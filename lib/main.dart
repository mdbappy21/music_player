import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/data/models/playlist.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(PlaylistAdapter());
  await Hive.openBox<Playlist>('playlists');

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.music_player.channel.audio',
    androidNotificationChannelName: 'Music Playback',
    androidNotificationOngoing: true,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MusicPlayerApp());
}

