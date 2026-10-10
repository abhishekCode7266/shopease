import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../screens/product/product_detail_screen.dart';

class CameraSearchModal extends StatefulWidget {
  const CameraSearchModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CameraSearchModal(),
    );
  }

  @override
  State<CameraSearchModal> createState() => _CameraSearchModalState();
}

class _CameraSearchModalState extends State<CameraSearchModal>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = false;
  String _statusText = 'Point camera at any product or barcode';
  late AnimationController _animController;

  final List<Map<String, String>> _sampleImages = [
    {
      'title': 'Headphones',
      'query': 'headphones',
      'category': 'Electronics',
      'icon': '🎧',
    },
    {
      'title': 'Sneakers',
      'query': 'sneakers',
      'category': 'Fashion',
      'icon': '👟',
    },
    {
      'title': 'Smart Watch',
      'query': 'watch',
      'category': 'Electronics',
      'icon': '⌚',
    },
    {
      'title': 'Desk Lamp',
      'query': 'lamp',
      'category': 'Home & Living',
      'icon': '💡',
    },
    {
      'title': 'Backpack',
      'query': 'backpack',
      'category': 'Fashion',
      'icon': '🎒',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _runAiVisionMatch(String query, String category) async {
    setState(() {
      _isAnalyzing = true;
      _statusText = 'StarShop Vision AI: Extracting visual embeddings...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final prodProv = context.read<ProductProvider>();
    prodProv.setSearchQuery(query);
    prodProv.selectCategory(category);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Vision AI Matched: "$query" in $category (Confidence: 99.2%)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Color(0xFF4F46E5), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Camera Visual Search',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Instant product detection & barcode lookup',
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

          // Simulated Viewfinder Frame
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Viewfinder Box
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF4F46E5),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                // Camera Simulation Graphic
                                Center(
                                  child: Opacity(
                                    opacity: 0.15,
                                    child: Icon(
                                      Icons.center_focus_strong,
                                      size: 160,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Reticle Corners
                                Positioned(
                                  top: 24,
                                  left: 24,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                        left: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 24,
                                  right: 24,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                        right: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 24,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                        left: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  right: 24,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                        right: BorderSide(
                                            color: Color(0xFF6366F1), width: 3),
                                      ),
                                    ),
                                  ),
                                ),
                                // Animated Scan Laser
                                AnimatedBuilder(
                                  animation: _animController,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 30 +
                                          (_animController.value *
                                              (MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.26)),
                                      left: 24,
                                      right: 24,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF6366F1)
                                                  .withOpacity(0.8),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Color(0xFF818CF8),
                                              Color(0xFF6366F1),
                                              Color(0xFF818CF8),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Status Pill
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (_isAnalyzing)
                                          const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        else
                                          const Icon(Icons.flash_on_rounded,
                                              color: Colors.amber, size: 16),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            _statusText,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Capture & Gallery Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Upload Photo'),
                          onPressed: () {
                            _runAiVisionMatch('headphones', 'Electronics');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('Take Snap'),
                          onPressed: () {
                            _runAiVisionMatch('sneakers', 'Fashion');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sample Items Quick Matcher
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Or Test with Sample Images:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sampleImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final s = _sampleImages[i];
                        return ActionChip(
                          avatar: Text(s['icon']!,
                              style: const TextStyle(fontSize: 16)),
                          label: Text(s['title']!),
                          onPressed: () {
                            _runAiVisionMatch(s['query']!, s['category']!);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
