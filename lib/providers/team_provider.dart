import 'package:flutter/material.dart';
import '../models/team_model.dart';

class TeamProvider with ChangeNotifier {
  List<TeamModel> _teams = [];
  bool _isLoading = false;

  List<TeamModel> get teams => _teams;
  bool get isLoading => _isLoading;

  Future<void> fetchTeams() async {
    if (_teams.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    // Simulated API delay
    await Future.delayed(const Duration(milliseconds: 800));

    _teams = [
      TeamModel(
        id: '1',
        name: 'India',
        code: 'IND',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313128.logo.png',
        description: 'The Indian Men\'s Cricket Team, also known as Team India and Men in Blue.',
        squad: ['Rohit Sharma', 'Virat Kohli', 'Jasprit Bumrah', 'KL Rahul'],
      ),
      TeamModel(
        id: '2',
        name: 'Pakistan',
        code: 'PAK',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313129.logo.png',
        description: 'The Pakistan National Cricket Team, also known as the Shaheens.',
        squad: ['Babar Azam', 'Shaheen Afridi', 'Mohammad Rizwan', 'Naseem Shah'],
      ),
      TeamModel(
        id: '3',
        name: 'Australia',
        code: 'AUS',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313114.logo.png',
        description: 'The Australian Men\'s Cricket Team representing Australia in international cricket.',
        squad: ['Pat Cummins', 'Steve Smith', 'Travis Head', 'Mitchell Starc'],
      ),
      TeamModel(
        id: '4',
        name: 'England',
        code: 'ENG',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313125.logo.png',
        description: 'England and Wales Cricket Board representing England.',
        squad: ['Jos Buttler', 'Joe Root', 'Ben Stokes', 'Mark Wood'],
      ),
      TeamModel(
        id: '5',
        name: 'South Africa',
        code: 'SA',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313137.logo.png',
        description: 'The Proteas representing South Africa.',
        squad: ['Aiden Markram', 'Kagiso Rabada', 'David Miller', 'Quinton de Kock'],
      ),
      TeamModel(
        id: '6',
        name: 'New Zealand',
        code: 'NZ',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313134.logo.png',
        description: 'The Black Caps representing New Zealand.',
        squad: ['Kane Williamson', 'Trent Boult', 'Daryl Mitchell', 'Rachin Ravindra'],
      ),
      TeamModel(
        id: '7',
        name: 'Sri Lanka',
        code: 'SL',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313149.logo.png',
        description: 'The Lions representing Sri Lanka.',
        squad: ['Kusal Mendis', 'Pathum Nissanka', 'Wanindu Hasaranga'],
      ),
      TeamModel(
        id: '8',
        name: 'Bangladesh',
        code: 'BAN',
        logo: 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313143.logo.png',
        description: 'The Tigers representing Bangladesh.',
        squad: ['Shakib Al Hasan', 'Litton Das', 'Najmul Hossain Shanto'],
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
