import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../auth/presentation/screens/login_screen.dart';
import '../apis/did_api.dart';
import '../../auth/apis/auth_api.dart';

class AgentPage extends StatefulWidget {
  final String agentId;
  const AgentPage({super.key, required this.agentId});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  final _txt = TextEditingController();
  late RTCVideoRenderer _video;
  RTCPeerConnection? _pc;

  String? _chatId, _streamId, _sessionId;
  List<Map<String, dynamic>> _ice = [];

  bool _loading = true;
  String? _error;
  String? _avatarUrl;

  // Default avatar URL (can be replaced with agent's avatar if available)
  static const _defaultAvatarUrl =
      'https://studio.d-id.com/agents-assets/avatars/anna_square.png';

  @override
  void initState() {
    super.initState();
    _video = RTCVideoRenderer();
    _video.initialize().then((_) => _initAgentAndBootstrap());
  }

  Future<void> _initAgentAndBootstrap() async {
    setState(() => _loading = true);
    try {
      // Fetch agent info to get avatar
      final agentsMap = await DidApi.fetchAgents();
      final allAgents = agentsMap['all'] ?? [];
      final mineAgents = agentsMap['mine'] ?? [];
      final allCombined = [...allAgents, ...mineAgents];
      final agent = allCombined.firstWhere(
        (a) => a['id'] == widget.agentId,
        orElse: () => {},
      );
      _avatarUrl = agent.isNotEmpty && agent['preview_thumbnail'] != null
          ? agent['preview_thumbnail'] as String
          : 'https://studio.d-id.com/agents-assets/avatars/anna_square.png';
      await _bootstrap();
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch agent info: $e';
        _loading = false;
      });
    }
  }

  /* ───────────────── bootstrap ───────────────── */
  Future<void> _bootstrap() async {
    try {
      debugPrint('Calling createChat for agent: ${widget.agentId}');
      final chatResponse = await DidApi.createChat(widget.agentId);
      debugPrint('createChat response: $chatResponse');
      _chatId = chatResponse['id'] as String?;
      if (_chatId == null || _chatId!.isEmpty) {
        setState(() {
          _error = 'createChat did not return a valid chat id.';
          _loading = false;
        });
        return;
      }

      debugPrint(
        'Calling createStream for agent: ${widget.agentId} with avatar: $_avatarUrl',
      );
      final streamResponse = await DidApi.createStream(
        widget.agentId,
        _avatarUrl!,
      );
      debugPrint('createStream response: $streamResponse');
      if (streamResponse['id'] == null ||
          streamResponse['session_id'] == null ||
          streamResponse['ice_servers'] == null ||
          streamResponse['offer'] == null) {
        setState(() {
          _error =
              'createStream response missing required fields: $streamResponse';
          _loading = false;
        });
        return;
      }
      _streamId = streamResponse['id'];
      _sessionId = streamResponse['session_id'];
      _ice = List<Map<String, dynamic>>.from(
        streamResponse['ice_servers'] ?? [],
      );

      _pc = await createPeerConnection({'iceServers': _ice});
      _pc!
        ..onIceCandidate = _onIce
        ..onIceConnectionState = (st) => debugPrint('ICE $st');
      _pc!.onTrack = (e) {
        if (e.streams.isNotEmpty) {
          _video.srcObject = e.streams.first;
          setState(() {}); // rebuild for first frame
        }
      };

      final offerObj = streamResponse['offer'];
      final remoteSdp = offerObj is Map
          ? offerObj['sdp'] as String
          : offerObj as String;
      await _pc!.setRemoteDescription(
        RTCSessionDescription(remoteSdp, 'offer'),
      );

      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      await DidApi.sendAnswer(
        widget.agentId,
        _streamId!,
        _sessionId!,
        answer.sdp!,
      );

      if (mounted) setState(() => _loading = false);
    } on UnauthenticatedException {
      _kickToLogin();
    } catch (e, st) {
      debugPrint('WebRTC signaling error: $e\n$st');
      if (mounted) setState(() => _error = 'WebRTC signaling error: $e');
    }
  }

  /* ───────────────── ICE ───────────────── */
  Future<void> _onIce(RTCIceCandidate c) async {
    try {
      await DidApi.sendIce(widget.agentId, _streamId!, _sessionId!, {
        'candidate': c.candidate,
        'sdpMid': c.sdpMid,
        'sdpMLineIndex': c.sdpMLineIndex,
      });
    } on UnauthenticatedException {
      _kickToLogin();
    }
  }

  /* ───────────────── chat ───────────────── */
  Future<void> _send() async {
    final text = _txt.text.trim();
    if (text.isEmpty || _loading || _error != null) return;
    _txt.clear();
    try {
      await DidApi.sendMessage(
        widget.agentId,
        _chatId!,
        _streamId!,
        _sessionId!,
        text,
      );
    } on UnauthenticatedException {
      _kickToLogin();
    }
  }

  /* ───────────────── helpers ───────────────── */
  void _kickToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  /* ───────────────── cleanup ───────────────── */
  @override
  void dispose() {
    DidApi.deleteStream(widget.agentId, _streamId ?? '');
    _pc?.close();
    _video.dispose();
    _txt.dispose();
    super.dispose();
  }

  /* ───────────────── UI ───────────────── */
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('D-ID Live Agent (${widget.agentId})'),
      actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
          onPressed: () => _kickToLogin(),
        ),
      ],
    ),
    body: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: RTCVideoView(
                _video,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                filterQuality: FilterQuality.high, // iOS release tweak
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black12,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _txt,
                      enabled: !_loading && _error == null,
                      decoration: const InputDecoration(
                        hintText: 'Say something…',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _loading || _error != null ? null : _send,
                  ),
                ],
              ),
            ),
          ],
        ),

        // loading overlay
        if (_loading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
          ),

        // error overlay
        if (_error != null && !_loading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load agent.\n [39m [22m [49m$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Retry'),
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _bootstrap();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
