import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deepfake/app/constants/constant.dart';

class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException([this.message = 'Unauthenticated']);
  @override
  String toString() => message;
}

class AuthApi {
  static String? _token;
  static String? get token => _token;
  static void setToken(String? t) => _token = t;

  static const _base = kServerUrl;

  static Map<String, String> _hdr() => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<String> register(String email, String pass) async {
    final res = await http
        .post(
          Uri.parse('$_base/auth/register'),
          headers: _hdr(),
          body: jsonEncode({'email': email, 'password': pass}),
        )
        .then(_checked);
    final tok = jsonDecode(res.body)['access_token'] as String;
    setToken(tok);
    return tok;
  }

  static Future<String> login(String email, String pass) async {
    final res = await http
        .post(
          Uri.parse('$_base/auth/login'),
          headers: _hdr(),
          body: jsonEncode({'email': email, 'password': pass}),
        )
        .then(_checked);
    final tok = jsonDecode(res.body)['access_token'] as String;
    setToken(tok);
    return tok;
  }

  static Future<bool> verify() async {
    if (_token == null) return false;
    final res = await http
        .get(Uri.parse('$_base/auth/verify'), headers: _hdr())
        .then(_checked);
    return jsonDecode(res.body)['valid'] == true;
  }

  static Future<http.Response> _checked(http.Response r) async {
    if (r.statusCode == 401) throw UnauthenticatedException();
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
    return r;
  }
}
