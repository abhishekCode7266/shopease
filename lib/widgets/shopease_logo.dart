import 'package:flutter/material.dart';

class ShopEaseLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const ShopEaseLogo({
    super.key,
    this.size = 36,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Vector Bag + Lightning Logo Symbol
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: size * 0.58,
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.28),
          RichText(
            text: TextSpan(
              text: 'Shop',
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              children: [
                TextSpan(
                  text: 'Ease',
                  style: TextStyle(
                    fontSize: size * 0.6,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
