import 'package:edu_track/utils/app_config.dart';
import 'package:http/http.dart' as http;

class CleanHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.headers.containsKey('X-Supabase-Client-Platform-Version')) {
      request.headers['X-Supabase-Client-Platform-Version'] =
          AppConfig.supabaseClientVersion;
    }
    return _inner.send(request);
  }
}
