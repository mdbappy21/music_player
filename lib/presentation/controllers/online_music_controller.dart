import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:music_player/presentation/ui/app_constants.dart';

class OnlineMusicController extends GetxController {
  var searchQuery = ''.obs;
  var videos = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final String apiKey = AppConstants.apiKey;

  @override
  void onInit() {
    super.onInit();
    loadLastSearch(); // Load last search when controller initializes
  }

  Future<void> loadLastSearch() async {
    var box = await Hive.openBox('lastSearchBox');
    final cached = box.get('lastSearch'); // JSON string

    if (cached != null) {
      final data = json.decode(cached);
      videos.value = List<Map<String, dynamic>>.from(data);
    }
  }

  void searchVideos(String query) async {
    if (query.isEmpty) return;

    isLoading.value = true;
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
          '?part=snippet'
          '&q=$query'
          '&type=video'
          '&maxResults=20'
          '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      videos.value = List<Map<String, dynamic>>.from(data['items']);

      // Save last search in Hive as JSON string
      var box = await Hive.openBox('lastSearchBox');
      await box.put('lastSearch', json.encode(videos.value));
    } else {
      Get.snackbar('Error', 'Failed to fetch videos');
    }

    isLoading.value = false;
  }
}
