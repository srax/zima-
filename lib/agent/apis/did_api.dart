import 'dart:convert';
import 'package:deepfake/app/constants/constant.dart';
import 'package:http/http.dart' as http;
import '../../auth/apis/auth_api.dart';

/// D-ID API client for agent chat, stream, and signaling.
class DidApi {
  /// Fetches all and mine agents from /d-id/agents
  static Future<Map<String, List<Map<String, dynamic>>>> fetchAgents() async {
    final res = await http.get(
      Uri.parse('$kServerUrl/d-id/agents'),
      headers: {
        'Authorization': 'Bearer ${AuthApi.token}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch agents: ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is Map && data['all'] is Map && data['mine'] is Map) {
      final allAgents = List<Map<String, dynamic>>.from(
        data['all']['agents'] ?? [],
      );
      final mineAgents = List<Map<String, dynamic>>.from(
        data['mine']['agents'] ?? [],
      );
      return {'all': allAgents, 'mine': mineAgents};
    } else {
      throw Exception('Unexpected agents response: $data');
    }
  }

  /// POST /d-id/:agentId/chat
  static Future<Map<String, dynamic>> createChat(String agentId) async {
    final res = await http.post(
      Uri.parse('$kServerUrl/d-id/$agentId/chat'),
      headers: {
        'Authorization': 'Bearer ${AuthApi.token}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200 && res.statusCode >= 400) {
      throw Exception('Failed to create chat: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /d-id/:agentId/stream   body: { source_url }
  static Future<Map<String, dynamic>> createStream(
    String agentId,
    String sourceUrl,
  ) async {
    final res = await http.post(
      Uri.parse('$kServerUrl/d-id/$agentId/stream'),
      headers: {
        'Authorization': 'Bearer ${AuthApi.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'source_url': sourceUrl}),
    );
    if (res.statusCode != 200 && res.statusCode >= 400) {
      throw Exception('Failed to create stream: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// POST /d-id/:agentId/stream/:id/sdp   body: { session_id, sdp }
  static Future<void> sendAnswer(
    String agentId,
    String streamId,
    String sessionId,
    String sdp,
  ) async {
    final res = await http.post(
      Uri.parse('$kServerUrl/d-id/$agentId/stream/$streamId/sdp'),
      headers: {
        'Authorization': 'Bearer ${AuthApi.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'session_id': sessionId, 'sdp': sdp}),
    );
    if (res.statusCode != 200 && res.statusCode >= 400) {
      throw Exception('Failed to send answer: ${res.body}');
    }
  }

  /// POST /d-id/:agentId/stream/:id/ice   body: { session_id, ...candidate }
  static Future<void> sendIce(
    String agentId,
    String streamId,
    String sessionId,
    Map<String, dynamic> cand,
  ) async {
    final res = await http.post(
      Uri.parse('$kServerUrl/d-id/$agentId/stream/$streamId/ice'),
      headers: {
        'Authorization': 'Bearer ${AuthApi.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'session_id': sessionId, ...cand}),
    );
    if (res.statusCode != 200 && res.statusCode >= 400) {
      throw Exception('Failed to send ICE: ${res.body}');
    }
  }

  /// POST /d-id/:agentId/chat/:id/message   body: { streamId, sessionId, text }
  static Future<void> sendMessage(
    String agentId,
    String chatId,
    String streamId,
    String sessionId,
    String text,
  ) async {
    final res = await http.post(
      Uri.parse('$kServerUrl/d-id/$agentId/chat/$chatId/message'),
      headers: {
        'Authorization': 'Bearer ${AuthApi.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'streamId': streamId,
        'sessionId': sessionId,
        'text': text,
      }),
    );
    if (res.statusCode != 200 && res.statusCode >= 400) {
      throw Exception('Failed to send message: ${res.body}');
    }
  }

  /// DELETE /d-id/:agentId/stream/:id
  static Future<void> deleteStream(String agentId, String streamId) async {
    final res = await http.delete(
      Uri.parse('$kServerUrl/d-id/$agentId/stream/$streamId'),
      headers: {
        'Authorization': 'Bearer ${AuthApi.token}',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200 && res.statusCode >= 400) {
      throw Exception('Failed to delete stream: ${res.body}');
    }
  }
}
