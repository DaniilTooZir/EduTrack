import 'package:http/http.dart' as http;

class CleanHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.headers.containsKey('X-Supabase-Client-Platform-Version')) {
      request.headers['X-Supabase-Client-Platform-Version'] =
      'Windows 10 Pro 10.0';
    }
    return _inner.send(request);
  }
}