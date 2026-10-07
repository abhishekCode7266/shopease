import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';

class InvoiceScreen extends StatelessWidget {
  final OrderModel order;

  const InvoiceScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final invoiceDate = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
    final taxableValue = order.subtotal - order.discount;
    final cgst = order.tax / 2;
    final sgst = order.tax / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Invoice'),
        actions: [
          IconButton(
            tooltip: 'Download Invoice PDF',
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF10B981),
                  content: Text(
                    'Invoice #${order.invoiceNumber}.pdf downloaded to storage',
                  ),
                  action: SnackBarAction(
                    label: 'Open',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Share Invoice',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing invoice link with customer...'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Branding
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shopping_bag,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ShopEase',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ShopEase Retail Pvt Ltd\nCIN: U72200KA2024PTC189211\nGSTIN: 29AABCS1429B1Z8\nBengaluru, Karnataka - 560103',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ORIGINAL TAX INVOICE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: $invoiceDate',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),

              // Billing & Shipping Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BILL TO / SHIP TO:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.address.fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.address.fullAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phone: ${order.address.phone}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ORDER DETAILS:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order ID: #${order.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Payment: ${order.paymentMethod}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tracking: ${order.trackingId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Itemized Table
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Item Description',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Price',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Amount',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${AppConstants.currencySymbol}${item.subtotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tax & Total Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 250,
                    child: Column(
                      children: [
                        _buildSummaryRow(
                            'Gross Subtotal', order.subtotal),
                        if (order.discount > 0)
                          _buildSummaryRow('Discount Coupon', -order.discount,
                              color: const Color(0xFF10B981)),
                        _buildSummaryRow('Taxable Amount', taxableValue),
                        _buildSummaryRow('CGST (9%)', cgst),
                        _buildSummaryRow('SGST (9%)', sgst),
                        _buildSummaryRow('Shipping & Handling', order.deliveryCharge),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${AppConstants.currencySymbol}${order.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Terms & Signature
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined,
                        size: 20, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This is a computer-generated tax invoice and requires no physical signature. Registered under the Indian GST regime.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Print / Download Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download),
                  label: const Text('Download Official PDF'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF10B981),
                        content: Text(
                          'Tax Invoice #${order.invoiceNumber} saved successfully.',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, {Color? color}) {
    final prefix = amount < 0 ? '-' : '';
    final val = amount.abs();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            '$prefix${AppConstants.currencySymbol}${val.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
