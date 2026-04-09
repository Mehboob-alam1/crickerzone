class ApiConstants {
  static const String baseUrl = 'https://cricbuzz-cricket.p.rapidapi.com';
  static const String apiKey = '23b0c640a3msh9ec262a1ae9a3aep1a6acejsnb87c775f94d4';
  static const String apiHost = 'cricbuzz-cricket.p.rapidapi.com';

  static Map<String, String> get headers => {
    'X-Rapidapi-Key': apiKey,
    'X-Rapidapi-Host': apiHost,
    'Content-Type': 'application/json',
  };
}
