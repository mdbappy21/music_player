import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/presentation/controllers/unified_player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';


void showSongDetailsSheet(SongModel song) {
  final UnifiedPlayerController playerController = Get.find<UnifiedPlayerController>();

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(song.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Artist'),
            subtitle: Text(song.artist ?? 'Unknown'),
          ),
          ListTile(
            title: const Text('Album'),
            subtitle: Text(song.album ?? 'Unknown'),
          ),
          ListTile(
            title: const Text('Duration'),
            subtitle: Text(playerController.formatDuration(Duration(milliseconds: song.duration ?? 0))),
          ),
          ListTile(
            title: const Text('URI / Path'),
            subtitle: Text(song.data ??song.uri ??'', maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
    isScrollControlled: false,
  );
}
