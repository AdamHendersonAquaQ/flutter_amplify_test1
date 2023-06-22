import 'package:http/http.dart' as http;

class NewClient {
  static http.Client? client;

  static void configureClient() {
    client = http.Client();
  }

  static void dispose() {
    client!.close();
  }
}
