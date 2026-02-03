class GalleryItem {
  final int id;
  final int eventId;
  final String title;
  final String? description;
  final String fileType;
  final String fileUrl;
  final String thumbnailUrl;
  int order;
  final bool isFeatured;
  final bool isImage;
  final bool isVideo;

  GalleryItem({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.fileType,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.order,
    required this.isFeatured,
    required this.isImage,
    required this.isVideo,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'],
      eventId: json['event_id'],
      title: json['title'] ?? '',
      description: json['description'],
      fileType: json['file_type'],
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      order: json['order'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      isImage: json['is_image'] ?? false,
      isVideo: json['is_video'] ?? false,
    );
  }
}