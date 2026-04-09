import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/player_provider.dart';
import '../../core/constants/colors.dart';
import '../../models/player_model.dart';

class PlayerProfileScreen extends StatefulWidget {
  final String playerId;
  const PlayerProfileScreen({super.key, required this.playerId});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<PlayerProvider>().fetchPlayerDetails(widget.playerId);
      }
    });
  }

  static String _plainBio(String? html) {
    if (html == null || html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PlayerProvider>(
        builder: (context, provider, child) {
          final player = provider.currentPlayer;

          if (provider.isLoading && player == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (player == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Player')),
              body: const Center(
                child: Text(
                  'Profilo non disponibile',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(player),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfo(player),
                      const SizedBox(height: 28),
                      _buildBioSection(player),
                      const SizedBox(height: 32),
                      _buildSectionTitle('BATTING CAREER'),
                      const SizedBox(height: 12),
                      _buildStatsTable(provider.playerBatting),
                      const SizedBox(height: 28),
                      _buildSectionTitle('BOWLING CAREER'),
                      const SizedBox(height: 12),
                      _buildStatsTable(provider.playerBowling),
                      const SizedBox(height: 28),
                      _buildSectionTitle('FORMATI & DEBUT'),
                      const SizedBox(height: 12),
                      _buildCareerFormats(provider.playerCareer),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildAppBar(PlayerModel player) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (player.image.isNotEmpty)
              CachedNetworkImage(
                imageUrl: player.image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, size: 80, color: AppColors.textMuted),
                ),
              )
            else
              Container(
                color: AppColors.surface,
                alignment: Alignment.center,
                child: const Icon(Icons.person, size: 80, color: AppColors.textMuted),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(PlayerModel player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (player.nickName != null && player.nickName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '"${player.nickName}"',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    player.role,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (player.team != null && player.team!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  player.team!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Born', player.dob ?? 'N/A'),
        _buildInfoRow('Birth Place', player.birthPlace ?? 'N/A'),
        _buildInfoRow('Height', player.height ?? 'N/A'),
        _buildInfoRow('Batting Style', player.batStyle ?? 'N/A'),
        _buildInfoRow('Bowling Style', player.bowlStyle ?? 'N/A'),
        if (player.teamsClubs != null && player.teamsClubs!.isNotEmpty)
          _buildInfoRowMultiline('Teams', player.teamsClubs!),
      ],
    );
  }

  Widget _buildBioSection(PlayerModel player) {
    final text = _plainBio(player.bio);
    if (text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('BIO'),
        const SizedBox(height: 12),
        SelectableText(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowMultiline(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTable(Map<String, dynamic>? data) {
    if (data == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final headers = (data['headers'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final rows = (data['values'] as List?) ?? [];

    if (headers.isEmpty || rows.isEmpty) {
      return const Text(
        'Nessun dato',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: AppColors.surface),
            children: headers
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      h,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          ...rows.map((row) {
            final vals = (row is Map && row['values'] is List)
                ? (row['values'] as List).map((e) => e.toString()).toList()
                : <String>[];
            return TableRow(
              children: vals
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        v,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCareerFormats(List<dynamic>? career) {
    if (career == null) {
      return const Text(
        'Caricamento…',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }
    if (career.isEmpty) {
      return const Text(
        'Dati carriera non disponibili',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }

    return Column(
      children: career.map((raw) {
        if (raw is! Map) return const SizedBox.shrink();
        final m = Map<String, dynamic>.from(raw);
        final name = (m['name'] ?? '').toString().toUpperCase();
        final debut = (m['debut'] ?? '').toString();
        final last = (m['lastPlayed'] ?? '').toString();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Debut: $debut',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Last: $last',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
