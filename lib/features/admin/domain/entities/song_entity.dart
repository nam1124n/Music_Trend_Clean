class SongEntity {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String imageUrl;

  const SongEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.imageUrl,
  });
}
