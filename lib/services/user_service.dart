import 'dart:convert';
import 'package:http/http.dart' as http;

class Logger {
  static void error(String message) {
    print('[ERROR] ${DateTime.now()}: $message');
  }

  static void info(String message) {
    print('[INFO] ${DateTime.now()}: $message');
  }
}

class UserService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Map<String, dynamic>>?> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users'));
      if (response.statusCode == 200) {
        Logger.info('Users fetched successfully');
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      Logger.error('Failed to fetch users: ${response.statusCode}');
      return null;
    } catch (e) {
      Logger.error('Exception fetching users: $e');
      return null;
    }
  }
}
