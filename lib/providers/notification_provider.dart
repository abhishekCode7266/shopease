import 'package:flutter/foundation.dart';
import '../models/notification_item_model.dart';
import '../utils/sample_data.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItemModel> _notifications = [];

  NotificationProvider() {
    _notifications = List.from(SampleData.sampleNotifications);
  }

  List<NotificationItemModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItemModel> getNotificationsByType(String type) {
    if (type.toLowerCase() == 'all' || type.isEmpty) {
      return notifications;
    }
    return _notifications
        .where((n) => n.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void addNotification(NotificationItemModel item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  void addNotificationMessage({
    required String title,
    required String message,
    required String type,
  }) {
    _notifications.insert(
      0,
      NotificationItemModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
