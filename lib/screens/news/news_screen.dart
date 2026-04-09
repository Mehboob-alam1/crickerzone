import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../providers/news_provider.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<NewsProvider>();
      p.fetchCategories();
      p.fetchNews();
    });
  }

  void _showCategorySheet(NewsProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Categorie',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Tutte le news', style: TextStyle(color: AppColors.textPrimary)),
                leading: const Icon(Icons.list_alt, color: AppColors.primary),
                onTap: () {
                  Navigator.pop(ctx);
                  provider.fetchNews();
                },
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.55,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.categories.length,
                  itemBuilder: (context, i) {
                    final c = provider.categories[i];
                    final id = c['id'];
                    final name = c['name']?.toString() ?? '';
                    if (id == null) return const SizedBox.shrink();
                    final cid = id is int ? id : (id as num).toInt();
                    return ListTile(
                      title: Text(name, style: const TextStyle(color: AppColors.textPrimary)),
                      onTap: () {
                        Navigator.pop(ctx);
                        provider.fetchNewsByCategory(cid);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LATEST NEWS'),
        actions: [
          Consumer<NewsProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: provider.categories.isEmpty ? null : () => _showCategorySheet(provider),
                tooltip: 'Categoria',
              );
            },
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.newsList.isEmpty) {
            return const Center(child: Text('Nessuna news', style: TextStyle(color: AppColors.textMuted)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.newsList.length,
            itemBuilder: (context, index) {
              final news = provider.newsList[index];

              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/news/article/${news.id}'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: news.image.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: news.image,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 180,
                                      color: Colors.grey[800],
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: 180,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  )
                                : Container(
                                    height: 120,
                                    width: double.infinity,
                                    color: AppColors.surface,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.article_outlined, color: AppColors.textMuted, size: 48),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    news.category.isNotEmpty ? news.category : 'News',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  news.headline,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (news.intro.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    news.intro,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  news.pubTime,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
