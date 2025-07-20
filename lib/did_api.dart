import 'dart:convert';
import 'package:http/http.dart' as http;

/// Minimal wrapper for the few D-ID endpoints we use.
class DidApi {
  /* ─────────―― Credentials ――───────── */
  static const agentId = 'v2_agt_01BTArCA';

  /// **Must** be the ready-made base-64 key shown in D-ID console
  /// (no colon).  Replace if necessary.
  static const _apiKeyB64 = 'Z3JrYXNoYW5pQGdtYWlsLmNvbQ:eZOBLc9TH5Jyz6mxabfb9';

  static Map<String, String> get _jsonHeaders => {
    'Authorization': 'Basic $_apiKeyB64',
    'Content-Type': 'application/json',
  };

  /* ─────────―― Chat & Stream helpers ――──────── */

  static Future<String> createChat() async {
    final r = await http
        .post(
          Uri.https('api.d-id.com', '/agents/$agentId/chat'),
          headers: _jsonHeaders,
        )
        .then(_checked);
    return jsonDecode(r.body)['id'] as String;
  }

  /// Returns: id, session_id, offer, ice_servers …
  static Future<Map<String, dynamic>> createStream(String avatarUrl) async {
    final r = await http
        .post(
          Uri.https('api.d-id.com', '/agents/$agentId/streams'),
          headers: _jsonHeaders,
          body: jsonEncode({'source_url': avatarUrl}),
        )
        .then(_checked);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<void> sendAnswer(
    String streamId,
    String sessionId,
    String sdp,
  ) => http
      .post(
        Uri.https('api.d-id.com', '/agents/$agentId/streams/$streamId/sdp'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'answer': {'type': 'answer', 'sdp': sdp},
          'session_id': sessionId,
        }),
      )
      .then(_checked);

  static Future<void> sendIce(
    String streamId,
    String sessionId,
    Map<String, dynamic> candidate,
  ) => http.post(
    Uri.https('api.d-id.com', '/agents/$agentId/streams/$streamId/ice'),
    headers: _jsonHeaders,
    body: jsonEncode({...candidate, 'session_id': sessionId}),
  );

  static Future<void> sendMessage(
    String chatId,
    String streamId,
    String sessionId,
    String text,
  ) => http
      .post(
        Uri.https('api.d-id.com', '/agents/$agentId/chat/$chatId'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'streamId': streamId,
          'sessionId': sessionId,
          'messages': [
            {
              'role': 'user',
              'type': 'text',
              'content': text,
              'created_at': DateTime.now().toUtc().toIso8601String(),
            },
          ],
        }),
      )
      .then(_checked);

  static Future<void> deleteStream(String streamId) => http.delete(
    Uri.https('api.d-id.com', '/agents/$agentId/streams/$streamId'),
    headers: _jsonHeaders,
  );

  /* ─────────―― plumbing ――──────── */
  static Future<http.Response> _checked(http.Response r) {
    if (r.statusCode >= 400) {
      throw Exception('D-ID ${r.request?.url} → ${r.statusCode}: ${r.body}');
    }
    return Future.value(r);
  }
}
