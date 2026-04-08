import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: AppColors.surface),
            SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(color: AppColors.textMuted, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Add teams and players to see them here',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
