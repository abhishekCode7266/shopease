import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../orders/orders_screen.dart';
import '../product/product_detail_screen.dart';

class AIMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ProductModel>? recommendedProducts;
  final bool showOrderAction;

  AIMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendedProducts,
    this.showOrderAction = false,
  });
}

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<AIMessage> _messages = [];
  bool _isThinking = false;

  final List<String> _quickPrompts = [
    'Best headphones under ₹5,000?',
    'What running shoes do you recommend?',
    'How do I track my order?',
    'What is the return & refund policy?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      AIMessage(
        text:
            "👋 Hello! I'm your **ShopEase AI Concierge**. How can I assist your shopping journey today? I can help you find products, compare specs, or check your orders.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String input) {
    final query = input.trim();
    if (query.isEmpty) return;

    _textCtrl.clear();
    setState(() {
      _messages.add(
        AIMessage(
          text: query,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isThinking = true;
    });
    _scrollToBottom();

    // Simulate smart response using product & order catalog
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final prodProv = context.read<ProductProvider>();
      final lower = query.toLowerCase();

      String responseText = '';
      List<ProductModel>? recs;
      bool showOrders = false;

      if (lower.contains('headphone') || lower.contains('audio') || lower.contains('earphone')) {
        recs = prodProv.products.where((p) => p.category == 'Electronics' && p.name.toLowerCase().contains('headphone')).toList();
        if (recs.isEmpty) recs = prodProv.products.take(2).toList();
        responseText = "Here are our top-rated audio gadgets with active noise cancellation and deep bass:";
      } else if (lower.contains('shoe') || lower.contains('running') || lower.contains('fashion')) {
        recs = prodProv.products.where((p) => p.category == 'Fashion').toList();
        if (recs.isEmpty) recs = prodProv.products.take(2).toList();
        responseText = "Take a look at these popular picks from our verified fashion merchants:";
      } else if (lower.contains('order') || lower.contains('track') || lower.contains('delivery')) {
        final orderProv = context.read<OrderProvider>();
        if (orderProv.orders.isNotEmpty) {
          final latest = orderProv.orders.first;
          responseText = "You have ${orderProv.orders.length} orders on file. Your latest order #${latest.id} is currently **${latest.status}** with tracking ID `${latest.trackingId}` via ${latest.deliveryPartner}.";
          showOrders = true;
        } else {
          responseText = "You don't have any placed orders yet. Once you place an order, you can track it step-by-step in real time right here.";
        }
      } else if (lower.contains('return') || lower.contains('refund') || lower.contains('policy')) {
        responseText = "✨ **ShopEase Hassle-Free Policy:**\n• **7-Day Returns:** All items can be returned within 7 days of delivery.\n• **Instant Refunds:** Pre-paid orders are refunded back to your UPI/Card within 3-5 business days.\n• **Zero Pickup Fee:** We pick up returns directly from your doorstep.";
      } else {
        // Generic search
        final matched = prodProv.searchProducts(query);
        if (matched.isNotEmpty) {
          recs = matched.take(3).toList();
          responseText = "I found these items matching \"$query\":";
        } else {
          recs = prodProv.products.take(2).toList();
          responseText = "I couldn't find an exact match for \"$query\", but here are some trending bestsellers you might love:";
        }
      }

      setState(() {
        _isThinking = false;
        _messages.add(
          AIMessage(
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
            recommendedProducts: recs,
            showOrderAction: showOrders,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ShopEase AI Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Always online • Powered by DeepMind', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Prompt suggestions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _quickPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.bolt, size: 14, color: Color(0xFF6366F1)),
                    label: Text(prompt, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _handleSend(prompt),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, isDark, theme);
              },
            ),
          ),

          if (_isThinking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ShopEase AI is thinking...',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ask anything about products, orders...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: _handleSend,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF4F46E5)),
                    onPressed: () => _handleSend(_textCtrl.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage msg, bool isDark, ThemeData theme) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: msg.isUser
              ? const Color(0xFF4F46E5)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: !msg.isUser && isDark
              ? Border.all(color: const Color(0xFF334155))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (msg.recommendedProducts != null &&
                msg.recommendedProducts!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children: msg.recommendedProducts!.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            p.imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shopping_bag, size: 30),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${p.price.toStringAsFixed(2)}  •  ★ ${p.rating}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: p),
                              ),
                            );
                          },
                          child: const Text('View', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (msg.showOrderAction) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('View My Orders', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
