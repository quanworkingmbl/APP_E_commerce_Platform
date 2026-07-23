class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.read,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String category;
  final bool read;
  final String createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      category: json['category'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
    );
  }
}

class UnreadCountModel {
  const UnreadCountModel({required this.unreadCount});

  final int unreadCount;

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountModel(unreadCount: json['unreadCount'] as int? ?? 0);
  }
}
