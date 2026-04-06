import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/team_provider.dart';
import '../../core/constants/colors.dart';
import '../../models/team_model.dart';

class TeamDetailScreen extends StatefulWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  List<dynamic> _squad = [];
  bool _loadingSquad = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final provider = context.read<TeamProvider>();
    final squad = await provider.fetchTeamPlayers(widget.teamId);
    if (mounted) {
      setState(() {
        _squad = squad;
        _loadingSquad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = context.watch<TeamProvider>().teams.firstWhere(
          (t) => t.id == widget.teamId,
          orElse: () => TeamModel(
            id: widget.teamId,
            name: 'Loading...',
            code: '...',
            logo: '',
            description: '',
            squad: [],
          ),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                team.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (team.logo.isNotEmpty)
                    Center(
                      child: Opacity(
                        opacity: 0.2,
                        child: CachedNetworkImage(
                          imageUrl: team.logo,
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  FadeInLeft(
                    child: const Text(
                      'SQUAD',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingSquad)
                    const Center(child: CircularProgressIndicator())
                  else if (_squad.isEmpty)
                    const Center(child: Text('No squad data available', style: TextStyle(color: AppColors.textMuted)))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _squad.length,
                      itemBuilder: (context, index) {
                        final player = _squad[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 50 * index),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              backgroundImage: player['faceImageId'] != null
                                  ? CachedNetworkImageProvider('https://static.cricbuzz.com/a/img/v1/i1/c${player['faceImageId']}/i.jpg')
                                  : null,
                              child: player['faceImageId'] == null
                                  ? Text(
                                      player['name']?[0] ?? 'P',
                                      style: const TextStyle(color: AppColors.primary),
                                    )
                                  : null,
                            ),
                            title: Text(
                              player['name'] ?? 'Unknown Player',
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              player['role'] ?? 'Role not available',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            onTap: () {
                              final id = player['id']?.toString() ?? player['playerId']?.toString();
                              if (id != null) {
                                context.push('/player/$id');
                              }
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

