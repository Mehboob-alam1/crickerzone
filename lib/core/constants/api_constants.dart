class ApiConstants {
  static const String baseUrl = 'https://cricbuzz-cricket.p.rapidapi.com';
  static const String apiKey = '7aa658c82cmsh5360f908009ba0ep14fcfajsn25001f01d67b';
  static const String apiHost = 'cricbuzz-cricket.p.rapidapi.com';

  static Map<String, String> get headers => {
    'X-Rapidapi-Key': apiKey,
    'X-Rapidapi-Host': apiHost,
    'Content-Type': 'application/json',
  };
}
