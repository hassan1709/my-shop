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
      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      if (responseBody != null) {
        if (responseBody.containsKey('error')) {
          if (responseBody['error'].toString().contains('message')) {
            throw HttpException(responseBody['error']['message']);
          } else {
            throw HttpException(responseBody['error']);
          }
        } else {
          throw HttpException('There was a problem with the server.');
        }
      } else {
        throw HttpException('There was a problem with the server.');
      }
    }
  }
}
