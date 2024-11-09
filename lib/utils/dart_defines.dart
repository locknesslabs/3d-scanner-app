import 'package:flutter_dotenv/flutter_dotenv.dart';

class DartDefines {
  static String projectId = dotenv.env['WALLET_CONNECT_PROJECT_ID'] ?? '';
  static String apiUrl = dotenv.env['API_URL'] ?? '';
  // static const String apiUrl = "http://192.168.0.125:3333";
}
