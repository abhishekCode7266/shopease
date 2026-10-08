import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/order_card.dart';
import '../home/home_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: orderProv.isLoading
          ? const LoadingView(message: 'Loading your orders...')
          : orderProv.orders.isEmpty
              ? EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Orders Yet',
                  subtitle:
                      'When you place orders on StarShop, they will appear here with real-time tracking.',
                  buttonText: 'Start Shopping',
                  onButtonPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProv.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProv.orders[index];
                    return OrderCard(
                      order: order,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
