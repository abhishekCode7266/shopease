class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'order', 'payment', 'shipping', 'delivery', 'refund', 'promo'
  final DateTime createdAt;
  bool isRead;

  String get body => message;

  NotificationItemModel({
    required this.id,
    required this.title,
    String? message,
    String? body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  }) : message = (message != null && message.isNotEmpty) ? message : (body ?? '');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationItemModel.fromMap(Map<String, dynamic> map) {
    return NotificationItemModel(
      id: map['id'] as String? ?? 'notif_1',
      title: map['title'] as String? ?? 'Notification',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'order',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}
