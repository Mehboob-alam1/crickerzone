import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../providers/match_provider.dart';
import '../../models/match_model.dart';
import '../../widgets/win_prediction.dart';
import '../../widgets/overs_timeline.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() {
      if (mounted) {
        final provider = context.read<MatchProvider>();
        provider.clearMatchDetails();
        provider.fetchMatchDetails(widget.matchId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    
    // Find the match in the list or use a placeholder if not loaded yet
    MatchModel? match;
    try {
      match = matchProvider.matches.firstWhere((m) => m.id == widget.matchId);
    } catch (e) {
      // If matches aren't loaded in provider yet, we might need to fetch them
      // but usually they are loaded from the home screen.
    }

    if (match == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
              FadeInLeft(
                child: const Text('Back', style: TextStyle(color: AppColors.primary, fontSize: 16)),
              ),
            ],
          ),
        ),
        title: FadeInDown(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(match.teamA, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(match.scoreA, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(match.oversA, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('vs', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Column(
                children: [
                  Text(match.teamB, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(match.scoreB == '-' ? '0/0' : match.scoreB, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(match.oversB == '-' ? '0.0' : match.oversB, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTopTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiveView(match, matchProvider),
                _buildScorecardView(matchProvider),
                _buildCommentaryView(matchProvider),
                _buildSquadsView(matchProvider),
                _buildInfoView(matchProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'LIVE'),
          Tab(text: 'SCORECARD'),
          Tab(text: 'COMMENTARY'),
          Tab(text: 'SQUADS'),
          Tab(text: 'INFO'),
        ],
      ),
    );
  }

  Widget _buildLiveView(MatchModel match, MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          FadeInDown(child: _buildLiveStatsRow(provider)),
          FadeInDown(delay: const Duration(milliseconds: 100), child: _buildStatusMessage(match)),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: WinPredictionWidget(
              teamA: match.teamA,
              teamB: match.teamB,
              percentageA: 60, // Ideally from API
              percentageB: 40,
            ),
          ),
          FadeInUp(delay: const Duration(milliseconds: 400), child: _buildBowlerTable(provider)),
          FadeInUp(delay: const Duration(milliseconds: 500), child: _buildOnCreaseSection(provider)),
          FadeInUp(delay: const Duration(milliseconds: 600), child: _buildLargeScoreDisplay(match)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScorecardView(MatchProvider provider) {
    if (provider.isLoading && provider.matchScorecard == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final scorecard = provider.matchScorecard;
    if (scorecard == null || scorecard['scoreCard'] == null) {
      return const Center(child: Text("Scorecard not available", style: TextStyle(color: Colors.white)));
    }

    final innings = scorecard['scoreCard'] as List;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: innings.length,
      itemBuilder: (context, index) {
        final inning = innings[index];
        final teamName = inning['batTeamName'] ?? 'Team';
        final score = "${inning['runs']}/${inning['wickets']} (${inning['overs']})";
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInLeft(child: _buildTeamScorecardHeader(teamName, score)),
            const SizedBox(height: 8),
            // You can iterate over battingTable here if you want full details
            const Text("Detailed scorecard available in full version", style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildCommentaryView(MatchProvider provider) {
    if (provider.isLoading && provider.matchCommentary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final commData = provider.matchCommentary;
    if (commData == null || commData['commentaryList'] == null) {
      return const Center(child: Text("Commentary not available", style: TextStyle(color: Colors.white)));
    }

    final commentaryList = commData['commentaryList'] as List;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: commentaryList.length,
      itemBuilder: (context, index) {
        final item = commentaryList[index];
        final over = item['overNumber']?.toString() ?? '';
        final text = item['commText'] ?? '';
        final isWicket = item['wicket'] == true;

        return FadeInRight(
          delay: Duration(milliseconds: 50 * (index % 10)),
          child: _buildCommentaryItem(over, text, isWicket: isWicket),
        );
      },
    );
  }

  Widget _buildSquadsView(MatchProvider provider) {
     if (provider.isLoading && provider.matchInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final info = provider.matchInfo;
    if (info == null || info['team1'] == null) {
      return const Center(child: Text("Squad info not available", style: TextStyle(color: Colors.white)));
    }

    final team1 = info['team1']['teamName'] ?? 'Team 1';
    final team2 = info['team2']['teamName'] ?? 'Team 2';
    // The squads usually come from a different endpoint or deeper in matchInfo
    // For now, let's just show team names if squads aren't easily available
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(child: _buildSquadHeader(team1)),
          const Text("Squad details will appear here", style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          FadeInLeft(delay: const Duration(milliseconds: 200), child: _buildSquadHeader(team2)),
          const Text("Squad details will appear here", style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildInfoView(MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final info = provider.matchInfo;
    if (info == null) return const Center(child: Text("Match info not available"));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: FadeInUp(child: _buildMatchInformation(info)),
    );
  }

  Widget _buildSquadHeader(String team) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Text(team, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildCommentaryItem(String over, String text, {bool isWicket = false}) {
    // Basic HTML tag stripping if needed
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (over.isNotEmpty)
            SizedBox(
              width: 40,
              child: Text(over, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 13)),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWicket)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text('WICKET', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Text(cleanText, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScorecardHeader(String team, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(team, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(score, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLiveStatsRow(MatchProvider provider) {
    // In a real app, extract RR, RRR, Target from matchScore or matchInfo
    return const Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
            children: [
              Text("DATA", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              SizedBox(height: 4),
              Text("LIVE", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(MatchModel match) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        match.status,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBowlerTable(MatchProvider provider) {
    return const SizedBox.shrink(); // Simplified for brevity
  }

  Widget _buildOnCreaseSection(MatchProvider provider) {
    return const SizedBox.shrink(); // Simplified for brevity
  }

  Widget _buildLargeScoreDisplay(MatchModel match) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Match Score', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallTeamLogo(match.teamA, match.teamALogo),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('${match.scoreA}  -  ${match.scoreB == '-' ? '0/0' : match.scoreB}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              _buildSmallTeamLogo(match.teamB, match.teamBLogo),
            ],
          ),
          const Divider(height: 48, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildSmallTeamLogo(String name, String logo) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: logo,
          width: 32,
          height: 32,
          errorWidget: (context, url, error) => const Icon(Icons.sports_cricket, color: AppColors.textMuted, size: 32),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMatchInformation(Map<String, dynamic> info) {
    final matchInfo = info['matchInfo'] ?? info;
    final venueInfo = matchInfo['venueInfo'] ?? {};
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Match Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildInfoRow('Series', matchInfo['seriesName'] ?? 'N/A'),
          _buildInfoRow('Venue', "${venueInfo['ground'] ?? ''}, ${venueInfo['city'] ?? ''}"),
          _buildInfoRow('Format', matchInfo['matchFormat'] ?? 'N/A'),
          _buildInfoRow('Status', matchInfo['status'] ?? 'N/A'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
