class ApiConstants {
  static const String baseUrl = 'https://cricbuzz-cricket.p.rapidapi.com';
  static const String apiKey = '8add5b416bmsh302335908d6f4b6p1b5533jsn22c31496663f';
  static const String apiHost = 'cricbuzz-cricket.p.rapidapi.com';

  static Map<String, String> get headers => {
    'X-Rapidapi-Key': apiKey,
    'X-Rapidapi-Host': apiHost,
    'Content-Type': 'application/json',
  };
}
