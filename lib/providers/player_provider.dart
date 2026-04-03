import 'package:flutter/material.dart';
import '../models/player_model.dart';

class PlayerProvider with ChangeNotifier {
  PlayerModel? _currentPlayer;
  List<PlayerModel> _trendingPlayers = [];

  PlayerModel? get currentPlayer => _currentPlayer;
  List<PlayerModel> get trendingPlayers => _trendingPlayers;

  void fetchTrendingPlayers() {
    _trendingPlayers = [
      PlayerModel(
        id: '1',
        name: 'Babar Azam',
        role: 'Batter',
        image: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_320,q_50/lsci/db/PICTURES/CMS/320400/320448.png',
        runs: '13,500+',
        average: '50.2',
        strikeRate: '128.5',
        wickets: '0',
      ),
      PlayerModel(
        id: '2',
        name: 'Virat Kohli',
        role: 'Batter',
        image: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_320,q_50/lsci/db/PICTURES/CMS/316600/316605.png',
        runs: '26,000+',
        average: '53.6',
        strikeRate: '130.2',
        wickets: '4',
      ),
      PlayerModel(
        id: '3',
        name: 'Shaheen Afridi',
        role: 'Bowler',
        image: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_320,q_50/lsci/db/PICTURES/CMS/320400/320452.png',
        runs: '800+',
        average: '15.2',
        strikeRate: '110.5',
        wickets: '250+',
      ),
    ];
    notifyListeners();
  }

  void fetchPlayerDetails(String id) {
    _currentPlayer = _trendingPlayers.firstWhere((p) => p.id == id, orElse: () => _trendingPlayers.first);
    notifyListeners();
  }
}
