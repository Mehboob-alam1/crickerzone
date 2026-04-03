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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (isLive) ...[
            const SizedBox(width: 8),
            Flash(
              infinite: true,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: onViewAll ?? () {},
            child: const Text(
              'View All',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
