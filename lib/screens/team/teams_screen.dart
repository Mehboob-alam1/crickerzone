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
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!provider.isLoading && provider.teams.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<TeamProvider>().fetchTeams(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Center(
                      child: Text(
                        'Nessuna squadra disponibile',
                        style: TextStyle(color: AppColors.textMuted),
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
            itemCount: chunk.length,
            itemBuilder: (context, i) {
              final team = chunk[i];
              final idx = gridIndex++;
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
      chunk = [];
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nessuna squadra in elenco',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }
}
