import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../screens/profile/addresses_screen.dart';

class DeliveryLocationSheet extends StatefulWidget {
  final String currentPinCode;
  final String currentLocationName;
  final ValueChanged<Map<String, String>> onLocationSelected;

  const DeliveryLocationSheet({
    super.key,
    required this.currentPinCode,
    required this.currentLocationName,
    required this.onLocationSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentPinCode,
    required String currentLocationName,
    required ValueChanged<Map<String, String>> onLocationSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryLocationSheet(
        currentPinCode: currentPinCode,
        currentLocationName: currentLocationName,
        onLocationSelected: onLocationSelected,
      ),
    );
  }

  @override
  State<DeliveryLocationSheet> createState() => _DeliveryLocationSheetState();
}

class _DeliveryLocationSheetState extends State<DeliveryLocationSheet> {
  final TextEditingController _pinController = TextEditingController();
  bool _isCheckingPin = false;
  String? _pinCheckResult;
  bool _isPinValid = false;

  @override
  void initState() {
    super.initState();
    _pinController.text = widget.currentPinCode;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPinCode(String pin) async {
    final cleaned = pin.trim();
    if (cleaned.length < 5) {
      setState(() {
        _pinCheckResult = 'Please enter a valid 6-digit PIN code.';
        _isPinValid = false;
      });
      return;
    }

    setState(() {
      _isCheckingPin = true;
      _pinCheckResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _isCheckingPin = false;
      _isPinValid = true;
      _pinCheckResult =
          'Delivery available to $cleaned: Express Delivery by Tomorrow, 11 AM (Free with Prime)';
    });

    widget.onLocationSelected({
      'pin': cleaned,
      'name': 'PIN $cleaned (Verified)',
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final addresses = auth.savedAddresses;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: Color(0xFF10B981), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose Delivery Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Delivery options & speeds may vary for each address',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Enter PIN Code Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter a Delivery PIN Code',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'e.g. 122002 or 110001',
                            prefixIcon: const Icon(Icons.pin_drop_outlined),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: _verifyPinCode,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isCheckingPin
                            ? null
                            : () => _verifyPinCode(_pinController.text),
                        child: _isCheckingPin
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Apply',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (_pinCheckResult != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isPinValid
                            ? const Color(0xFF10B981).withOpacity(0.12)
                            : const Color(0xFFEF4444).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isPinValid
                              ? const Color(0xFF10B981).withOpacity(0.4)
                              : const Color(0xFFEF4444).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isPinValid
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: _isPinValid
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pinCheckResult!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isPinValid
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Use Current Location GPS Simulation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.my_location_rounded,
                    color: Color(0xFF4F46E5), size: 18),
                label: const Text(
                  'Use Current Device GPS Location',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  widget.onLocationSelected({
                    'pin': '122002',
                    'name': 'DLF Cyber City, Gurugram',
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(height: 28),

            // Saved Addresses Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saved Addresses',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add New'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddressesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'No saved addresses yet. Add one in Addresses screen.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final addr = addresses[idx];
                  final isCurrent = widget.currentPinCode == addr.postalCode;

                  return InkWell(
                    onTap: () {
                      widget.onLocationSelected({
                        'pin': addr.postalCode,
                        'name': '${addr.fullName} - ${addr.city}',
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? (isCurrent
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF0F172A))
                            : (isCurrent
                                ? const Color(0xFFEEF2FF)
                                : Colors.grey[50]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF4F46E5)
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isCurrent
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isCurrent
                                ? const Color(0xFF4F46E5)
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F46E5)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        addr.label.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${addr.street}, ${addr.city}, ${addr.state} - ${addr.postalCode}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Phone: ${addr.phone}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
