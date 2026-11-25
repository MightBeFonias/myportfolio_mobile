import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportfolio_mobile/config.dart';
import 'package:myportfolio_mobile/models/award.dart';
import 'package:myportfolio_mobile/models/experience.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'HTTP $statusCode';
}

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  static const _experience = '/api/v1/experience/';
  static const _awards = '/api/v1/awards/';
  static const _timeout = Duration(seconds: 15);
  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse(baseUrl).resolve(path);

  Future<List<Experience>> getExperiences() =>
      _getList(_experience, Experience.fromJson);

  Future<List<Award>> getAwards() => _getList(_awards, Award.fromJson);

  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) async {
    final response = await _post(
      _experience,
      body: experience.toJson(),
      token: token,
    );
    return Experience.fromJson(_decodeObject(response));
  }

  Future<Award> createAward(Award award, {required String token}) async {
    final response = await _post(_awards, body: award.toJson(), token: token);
    return Award.fromJson(_decodeObject(response));
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _client
        .get(_uri(path), headers: const {'Accept': 'application/json'})
        .timeout(_timeout);
    _checkStatus(response);
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _post(
      '/api/v1/auth/token/',
      body: {'username': username, 'password': password},
    );
    final token = _decodeObject(response)['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Token tidak tersedia.');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    await _post('/api/v1/auth/logout/', token: token);
  }

  Future<http.Response> _post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _client
        .post(
          _uri(path),
          headers: {
            'Accept': 'application/json',
            if (body != null) 'Content-Type': 'application/json; charset=UTF-8',
            if (token != null) 'Authorization': 'Token $token',
          },
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    _checkStatus(response);
    return response;
  }

  Map<String, dynamic> _decodeObject(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode);
    }
  }

  void close() => _client.close();
}
