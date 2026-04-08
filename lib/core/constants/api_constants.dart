class ApiConstants {
  static const String baseUrl = 'https://cricbuzz-cricket.p.rapidapi.com';
  static const String apiKey = '4fe6932e3fmsh06018939df7de54p17d603jsn691454312c4';
  static const String apiHost = 'cricbuzz-cricket.p.rapidapi.com';

  static Map<String, String> get headers => {
    'X-Rapidapi-Key': apiKey,
    'X-Rapidapi-Host': apiHost,
    'Content-Type': 'application/json',
  };
}
