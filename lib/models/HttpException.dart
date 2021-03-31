import 'package:http/http.dart';
import 'dart:convert';

class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
  }

  static void validateResponse(Response response) {
    if (response.statusCode >= 400) {
      final errorMsg = json.decode(response.body) as Map<String, dynamic>;

      if (errorMsg != null) {
        throw HttpException(errorMsg['error']);
      }

      throw HttpException('There was a problem with the server.');
    }
  }
}
