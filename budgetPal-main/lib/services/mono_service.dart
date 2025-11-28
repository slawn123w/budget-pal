import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/mono_connect_web.dart';

class MonoApiService {
  static const String backendBaseUrl = 'http://localhost:8080/mono'; // Change to your backend URL

  /// Exchanges the Mono code for an access token via your backend
  static Future<String?> exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('$backendBaseUrl/exchange'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    if (response.statusCode == 200) {
      // Parse the access token from the response body
      final data = jsonDecode(response.body);
      // You may need to adjust this depending on Mono's response structure
      return data['token'] ?? data['id'] ?? response.body;
    }
    return null;
  }

  /// Fetches accounts using the access token
  static Future<dynamic> getAccounts(String accessToken) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/accounts'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  /// Fetches transactions for a given account
  static Future<dynamic> getTransactions(String accountId, String accessToken) async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/transactions/$accountId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}

// Mono Connect Widget (uncommented and ready to use)
class MonoService {
  static const String monoPublicKey = 'test_pk_ix235rf6qosg2hpvl7nn';
  static const String monoConnectUrl =
      'https://connect.withmono.com/?key=$monoPublicKey';

  static void launchMonoConnect(BuildContext context, Function(String code) onSuccess) {
    if (kIsWeb) {
      // On web, show Mono Connect in an iframe dialog and handle code callback
      showDialog(
        context: context,
        builder: (context) => MonoConnectWebDialog(url: monoConnectUrl, onCode: onSuccess),
      );
    } else {
      // On mobile, show a placeholder or info (WebView not supported in this web build)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mono Connect'),
          content: const Text('Mono Connect is only available on mobile devices.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
