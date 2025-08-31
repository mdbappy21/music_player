import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 0)
class Playlist {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<int> trackIds;

  Playlist({
    required this.id,
    required this.name,
    required this.trackIds,
  });
}
