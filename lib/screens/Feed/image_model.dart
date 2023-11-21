class ImageModel {
  final String id;
  final String uploaderID;
  final String imageUrl;
  final DateTime timestamp;
  final int likesCount;

  ImageModel({
    required this.id,
    required this.uploaderID,
    required this.imageUrl,
    required this.timestamp,
    required this.likesCount,
  });
}
