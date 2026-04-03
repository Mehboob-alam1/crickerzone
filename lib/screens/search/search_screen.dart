import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search players or teams...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          onChanged: (value) {
            // Implement search logic
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: AppColors.surface),
            const SizedBox(height: 16),
            const Text(
              'Search for your favorite cricket stars',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
