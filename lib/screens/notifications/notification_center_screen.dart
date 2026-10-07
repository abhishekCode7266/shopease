import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_item_model.dart';
import '../../providers/notification_provider.dart';
import '../orders/orders_screen.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifProv = context.watch<NotificationProvider>();

    final List<NotificationItemModel> filteredItems = _selectedFilter == 'all'
        ? notifProv.notifications
        : notifProv.getNotificationsByType(_selectedFilter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifProv.unreadCount > 0)
            TextButton.icon(
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Read All'),
              onPressed: () {
                notifProv.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'clear') {
                notifProv.clearAll();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined,
                        size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('all', 'All (${notifProv.notifications.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('order', 'Orders'),
                const SizedBox(width: 8),
                _buildFilterChip('promo', 'Offers & Promos'),
                const SizedBox(width: 8),
                _buildFilterChip('system', 'System & Security'),
              ],
            ),
          ),
          const Divider(height: 1),

          // List or Empty
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilter == 'all'
                              ? "You're all caught up! Updates will appear here."
                              : 'No notifications in this category.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildNotificationCard(
                          context, item, notifProv, isDark, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filterKey;
          });
        }
      },
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItemModel item,
    NotificationProvider prov,
    bool isDark,
    ThemeData theme,
  ) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (item.type) {
      case 'order':
        icon = Icons.local_shipping_outlined;
        iconColor = const Color(0xFF4F46E5);
        bgColor = const Color(0xFF4F46E5).withOpacity(0.12);
        break;
      case 'promo':
        icon = Icons.local_offer_outlined;
        iconColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withOpacity(0.12);
        break;
      case 'system':
      default:
        icon = Icons.security_rounded;
        iconColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFF59E0B).withOpacity(0.12);
        break;
    }

    final timeAgo = DateFormat('MMM dd, hh:mm a').format(item.createdAt);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        prov.removeNotification(item.id);
      },
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: !item.isRead
                ? const Color(0xFF4F46E5).withOpacity(0.4)
                : (isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0)),
            width: !item.isRead ? 1.5 : 1,
          ),
        ),
        color: !item.isRead
            ? (isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFEEF2FF).withOpacity(0.4))
            : (isDark ? const Color(0xFF0F172A) : Colors.white),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            prov.markAsRead(item.id);
            if (item.type == 'order') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
