import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../providers/series_provider.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<SeriesProvider>().fetchInternationalSeries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRICKET SERIES'),
      ),
      body: Consumer<SeriesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.seriesList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.seriesList.isEmpty) {
            return const Center(child: Text("No series found"));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchInternationalSeries(forceRefresh: true),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.seriesList.length,
              itemBuilder: (context, index) {
                final series = provider.seriesList[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 50 * (index % 10)),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        series.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: series.seriesType.isEmpty
                          ? null
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Type: ${series.seriesType}',
                                style: const TextStyle(color: AppColors.textMuted),
                              ),
                            ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                      ),
                      onTap: () {
                        // Navigate to series detail (matches/squads)
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
