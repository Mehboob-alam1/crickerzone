import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchProvider with ChangeNotifier {
  List<MatchModel> _matches = [];
  bool _isLoading = false;

  List<MatchModel> get matches => _matches;
  bool get isLoading => _isLoading;

  List<MatchModel> get liveMatches => _matches.where((m) => m.matchType == 'Live').toList();
  List<MatchModel> get upcomingMatches => _matches.where((m) => m.matchType == 'Upcoming').toList();
  List<MatchModel> get recentMatches => _matches.where((m) => m.matchType == 'Recent').toList();

  Future<void> fetchMatches() async {
    if (_matches.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    // Simulated API response delay
    await Future.delayed(const Duration(milliseconds: 1000));

    _matches = [
      MatchModel(
        id: '1',
        teamA: 'IND',
        teamB: 'AUS',
        teamALogo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313128.logo.png',
        teamBLogo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313114.logo.png',
        scoreA: '352/7',
        oversA: '50.0',
        scoreB: '286/10',
        oversB: '44.3',
        status: 'IND won by 66 runs',
        matchType: 'Recent',
        venue: 'Rajkot, India',
        time: 'Ended',
        series: 'Australia tour of India, 2023',
      ),
      MatchModel(
        id: '2',
        teamA: 'PAK',
        teamB: 'SA',
        teamALogo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313129.logo.png',
        teamBLogo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313137.logo.png',
        scoreA: '142/3',
        oversA: '15.2',
        scoreB: '-',
        oversB: '-',
        status: 'PAK chose to bat',
        matchType: 'Live',
        venue: 'Dubai Stadium',
        time: 'LIVE',
        series: 'World Cup 2024',
      ),
      MatchModel(
        id: '3',
        teamA: 'ENG',
        teamB: 'NZ',
        teamALogo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313125.logo.png',
        teamBLogo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313134.logo.png',
        scoreA: '-',
        oversA: '-',
        scoreB: '-',
        oversB: '-',
        status: 'Starts in 2 hours',
        matchType: 'Upcoming',
        venue: 'Lords, London',
        time: '7:30 PM',
        series: 'New Zealand tour of England, 2023',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
