// lib/presentation/ui/sheets/mini_player_actions_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'sleep_timer_sheet.dart';
import 'add_to_playlist_sheet.dart';
import 'song_details_sheet.dart';

/// Show a bottom sheet with three actions: Sleep time, Add to playlist, Song details
void showMiniPlayerActionsSheet(BuildContext context, SongModel song) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Sleep timer'),
            onTap: () {
              Get.back(); // close this sheet then show the timer sheet (override)
              Future.delayed(const Duration(milliseconds: 120), () {
                showSleepTimerSheet(context);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to playlist'),
            onTap: () {
              Get.back();
              Future.delayed(const Duration(milliseconds: 120), () {
                showAddToPlaylistSheet(context, song);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Song details'),
            onTap: () {
              Get.back();
              Future.delayed(const Duration(milliseconds: 120), () {
                showSongDetailsSheet(context, song);
              });
            },
          ),
        ],
      ),
    ),
    isScrollControlled: false,
  );
}
