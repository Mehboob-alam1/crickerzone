import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/player_provider.dart';
import '../../widgets/player_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    await context.read<PlayerProvider>().searchPlayers(query);
    if (mounted) setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search players...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          onChanged: _onSearchChanged,
        ),
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, provider, child) {
          if (_isSearching) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final results = provider.searchResults;

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 80, color: AppColors.surface),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Search for your favorite cricket stars'
                        : 'No players found for "${_searchController.text}"',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return PlayerCard(
                player: results[index],
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}
