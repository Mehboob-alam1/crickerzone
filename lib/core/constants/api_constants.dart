class ApiConstants {
  static const String baseUrl = 'https://cricbuzz-cricket.p.rapidapi.com';
  static const String apiKey = '74e5a6ea8bmsh423aac0c12c5241p19f51ajsn6c0a15568509';
  static const String apiHost = 'cricbuzz-cricket.p.rapidapi.com';

  static Map<String, String> get headers => {
    'X-Rapidapi-Key': apiKey,
    'X-Rapidapi-Host': apiHost,
    'Content-Type': 'application/json',
  };
}
