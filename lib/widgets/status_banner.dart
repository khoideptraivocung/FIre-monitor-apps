import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  final String status; // 'SAFE', 'WARNING', 'DANGER'
  final String title;
  final String message;

  const StatusBanner({
    super.key,
    required this.status,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'DANGER':
        cardColor = const Color(0xFFF44336); // Danger red
        textColor = Colors.white;
        icon = Icons.local_fire_department_rounded;
        break;
      case 'WARNING':
        cardColor = const Color(0xFFFF9800); // Warning orange
        textColor = Colors.white;
        icon = Icons.warning_amber_rounded;
        break;
      case 'SAFE':
      default:
        cardColor = const Color(0xFF4CAF50); // Success green
        textColor = Colors.white;
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColor.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Graphic watermark icon
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              icon,
              size: 140,
              color: Colors.white.withAlpha(30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Row(
              children: [
                // Highlight icon block
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          color: textColor.withAlpha(220),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
