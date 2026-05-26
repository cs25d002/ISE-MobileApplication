import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  final int currentIndex; // 0-based
  final int total;
  final ValueChanged<int>? onTap;

  const ProgressStepper({
    super.key,
    required this.currentIndex,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentIndex;
        return GestureDetector(
          onTap: onTap != null ? () => onTap!(i) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1D9E75)
                  : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }
}
