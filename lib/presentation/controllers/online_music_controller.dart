import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:music_player/presentation/ui/app_constants.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class OnlineMusicController extends GetxController {
  var searchQuery = ''.obs;
  var videos = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final RxMap<String, Duration?> onlineDurations = <String, Duration?>{}.obs;
  final YoutubeExplode yt = YoutubeExplode();

  final String apiKey = AppConstants.apiKey;

  @override
  void onInit() {
    super.onInit();
    loadLastSearch(); // Load last search when controller initializes
  }

  Future<void> loadLastSearch() async {
    try {
      var box = await Hive.openBox('lastSearchBox');
      final cached = box.get('lastSearch'); // JSON string
      if (cached != null) {
        final data = json.decode(cached);
        if (data is List) {
          videos.value = List<Map<String, dynamic>>.from(
              data.map((e) => Map<String, dynamic>.from(e)));

          // 🔥 Re-fetch durations for cached videos
          onlineDurations.clear();
          for (final it in videos) {
            final videoId = it['id']?['videoId'];
            if (videoId != null) {
              fetchDurationFromApi(videoId).then((d) {
                onlineDurations[videoId] = d;
              });
            }
          }
        }
      }
    } catch (e, st) {
      print('loadLastSearch error: $e\n$st');
      try {
        var box = await Hive.openBox('lastSearchBox');
        await box.delete('lastSearch');
      } catch (_) {}
    }
  }


  void searchVideos(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;

    final safeItems = <Map<String, dynamic>>[]; // moved here

    try {
      final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'maxResults': '20',
        'key': apiKey,
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'];
        if (items is List) {
          for (final it in items) {
            try {
              final Map<String, dynamic> m = Map<String, dynamic>.from(it);
              final id = m['id'];
              final snippet = m['snippet'];
              if (id is Map && id['videoId'] != null && snippet is Map) {
                safeItems.add(m);
              }
            } catch (_) {
              continue;
            }
          }
          videos.value = safeItems;
        } else {
          videos.clear();
        }

        // Save in Hive
        try {
          var box = await Hive.openBox('lastSearchBox');
          await box.put('lastSearch', json.encode(videos.value));
        } catch (e) {
          print('Hive save failed: $e');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch videos: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch videos: $e');
    } finally {
      isLoading.value = false;
    }

    // clear & fetch durations
    onlineDurations.clear();
    for (final it in safeItems) {
      final videoId = it['id']['videoId'];
      if (videoId != null) {
        fetchDurationFromApi(videoId).then((d) {
          onlineDurations[videoId] = d;
        });
      }
    }

  }
  Future<Duration?> fetchDurationFromApi(String videoId) async {
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'contentDetails',
      'id': videoId,
      'key': apiKey,
    });

    final response = await http.get(uri);
    print("Duration API raw response: ${response.body}"); // 👈 add this

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        final durationIso = data['items'][0]['contentDetails']['duration'];
        print("VideoId $videoId -> $durationIso"); // 👈 check this
        return parseIso8601Duration(durationIso);
      }
    }
    return null;
  }


  Duration parseIso8601Duration(String input) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(input);
    if (match == null) return Duration.zero;
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }


}
