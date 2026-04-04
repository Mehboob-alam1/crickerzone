import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../core/constants/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isLive;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.isLive = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          if (isLive) ...[
            const SizedBox(width: 8),
            FadeIn(
              // The 'infinite' parameter is actually 'animate' combined with an infinite loop 
              // but in some versions of animate_do, 'infinite' is not a direct parameter of FadeIn.
              // To achieve a blink/pulse effect reliably across versions:
              duration: const Duration(seconds: 1),
              child: _PulseCircle(),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: onViewAll ?? () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'VIEW ALL',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseCircle extends StatefulWidget {
  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
