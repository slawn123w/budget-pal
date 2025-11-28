import 'package:cloud_functions/cloud_functions.dart';

class MonoCloudFunction {
  static Future<dynamic> exchangeCodeForToken(String code) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('exchangeCodeForToken');
    final result = await callable.call({'code': code});
    return result.data;
  }

  static Future<dynamic> getAccounts(String accessToken) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getAccounts');
    final result = await callable.call({'accessToken': accessToken});
    return result.data;
  }

  static Future<dynamic> getTransactions(String accountId, String accessToken) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getTransactions');
    final result = await callable.call({'accountId': accountId, 'accessToken': accessToken});
    return result.data;
  }
}
