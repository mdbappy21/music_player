class Track {
  final int id;
  final String uri;
  final String title;
  final String artist;
  final String? album;
  final int durationMs;

  Track({
    required this.id,
    required this.uri,
    required this.title,
    required this.artist,
    this.album,
    required this.durationMs,
  });
}
