import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/news_provider.dart';
import '../../core/constants/colors.dart';
import '../../utils/news_detail_parser.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NewsProvider>().fetchNewsDetail(widget.newsId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Article', style: TextStyle(fontSize: 16)),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.detailLoading && provider.newsDetail == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final d = provider.newsDetail;
          if (d == null) {
            return const Center(
              child: Text(
                'Article unavailable',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          final headline =
              d['headline']?.toString() ?? d['hline']?.toString() ?? '';
          final intro = d['intro']?.toString() ?? '';
          final source = d['source']?.toString() ?? 'Cricbuzz';
          final storyType = d['storyType']?.toString() ?? '';
          final contextLabel = d['context']?.toString() ?? '';
          final imageUrl = newsCoverImageUrl(d);
          final paragraphs = parseNewsDetailParagraphs(d);

          return RefreshIndicator(
            onRefresh: () => provider.fetchNewsDetail(widget.newsId, forceRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                if (imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox(height: 120),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contextLabel.isNotEmpty || storyType.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            contextLabel.isNotEmpty
                                ? contextLabel
                                : storyType,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (contextLabel.isNotEmpty || storyType.isNotEmpty)
                        const SizedBox(height: 12),
                      Text(
                        headline,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        source,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (intro.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          intro,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.45,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ...paragraphs.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SelectableText(
                            p,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}
