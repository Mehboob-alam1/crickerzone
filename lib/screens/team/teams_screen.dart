import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/team_provider.dart';
import '../../models/team_model.dart';
import '../../core/constants/colors.dart';
import '../../widgets/team_card.dart';
import 'team_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<TeamProvider>().fetchTeams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(child: const Text('CRICKET TEAMS')),
        actions: [
          FadeInRight(
              child: IconButton(
                  onPressed: () {}, icon: const Icon(Icons.filter_list_rounded))),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.teams.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!provider.isLoading && provider.teams.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<TeamProvider>().fetchTeams(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No teams available',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pull to refresh or try again later.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search teams...',
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<TeamProvider>().fetchTeams(forceRefresh: true),
                  child: _TeamListWithSections(teams: provider.teams),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TeamListWithSections extends StatelessWidget {
  final List<TeamModel> teams;

  const _TeamListWithSections({required this.teams});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    var chunk = <TeamModel>[];
    var gridIndex = 0;

    void flushChunk() {
      if (chunk.isEmpty) return;
      // Snapshot: itemBuilder runs after chunk is cleared for the next section;
      // without a copy, chunk[i] throws RangeError.
      final tiles = List<TeamModel>.from(chunk);
      final baseIndex = gridIndex;
      gridIndex += tiles.length;
      chunk = [];
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: tiles.length,
            itemBuilder: (context, i) {
              final team = tiles[i];
              final idx = baseIndex + i;
              return TeamCard(
                team: team,
                index: idx,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamDetailScreen(teamId: team.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }

    for (final t in teams) {
      if (t.isSectionHeader) {
        flushChunk();
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
            child: Text(
              t.name.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      } else if (t.id.isNotEmpty) {
        chunk.add(t);
      }
    }
    flushChunk();

    if (children.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.filter_list_off_outlined, size: 56, color: AppColors.textMuted),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No teams in this list',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }
}
