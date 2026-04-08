import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../core/constants/colors.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int index;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      delay: Duration(milliseconds: 100 * index),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 70, // Added fixed width to help with text alignment and bounds
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
