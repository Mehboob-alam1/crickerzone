import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/team_provider.dart';
import '../../core/constants/colors.dart';
import '../../widgets/team_card.dart';

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
          FadeInRight(child: IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded))),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.teams.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
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
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: provider.teams.length,
                  itemBuilder: (context, index) {
                    return TeamCard(
                      team: provider.teams[index],
                      index: index,
                      onTap: () {
                        // Navigate to team details
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
