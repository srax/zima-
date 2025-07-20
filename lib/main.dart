import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:deepfake/did_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgentApp());
}

class AgentApp extends StatelessWidget {
  const AgentApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'D-ID Agent',
    theme: ThemeData(colorSchemeSeed: Colors.blue),
    home: const AgentPage(),
    debugShowCheckedModeBanner: false,
  );
}

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

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

  // Avatar (square) image URL of your D-ID agent
  static const _avatarUrl =
      'https://studio.d-id.com/agents-assets/avatars/anna_square.png';

  @override
  void initState() {
    super.initState();
    _video = RTCVideoRenderer();
    _video.initialize().then((_) => _bootstrap());
  }

  /* ─────────────────────────  bootstrap  ───────────────────────── */
  Future<void> _bootstrap() async {
    try {
      _chatId = await DidApi.createChat();

      final s = await DidApi.createStream(_avatarUrl);
      _streamId = s['id'];
      _sessionId = s['session_id'];
      _ice = List<Map<String, dynamic>>.from(s['ice_servers'] ?? []);

      _pc = await createPeerConnection({'iceServers': _ice});
      _pc!.onIceCandidate = _onIce;
      _pc!.onIceConnectionState = (st) => debugPrint('ICE $st');
      _pc!.onTrack = (e) {
        debugPrint('▶︎ got ${e.track.kind} track');
        if (e.streams.isNotEmpty) {
          _video.srcObject = e.streams.first;
          setState(() {}); // repaint
        }
      };

      /* 1️⃣  Apply server’s offer */
      final offerObj = s['offer'];
      final remoteSdp = offerObj is Map
          ? offerObj['sdp'] as String
          : offerObj as String;
      await _pc!.setRemoteDescription(
        RTCSessionDescription(remoteSdp, 'offer'),
      );

      /* 2️⃣  Create / send answer */
      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      await DidApi.sendAnswer(_streamId!, _sessionId!, answer.sdp!);

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  /* ──────────────────────────  ICE  ───────────────────────────── */
  Future<void> _onIce(RTCIceCandidate c) async {
    await DidApi.sendIce(_streamId!, _sessionId!, {
      'candidate': c.candidate,
      'sdpMid': c.sdpMid,
      'sdpMLineIndex': c.sdpMLineIndex,
    });
  }

  /* ─────────────────────────  chat  ───────────────────────────── */
  Future<void> _send() async {
    final text = _txt.text.trim();
    if (text.isEmpty || _loading || _error != null) return;
    _txt.clear();
    await DidApi.sendMessage(_chatId!, _streamId!, _sessionId!, text);
  }

  /* ────────────────────────  cleanup  ─────────────────────────── */
  @override
  void dispose() {
    DidApi.deleteStream(_streamId ?? '');
    _pc?.close();
    _video.dispose();
    _txt.dispose();
    super.dispose();
  }

  /* ─────────────────────────── UI ─────────────────────────────── */
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('D-ID Live Agent')),
    body: Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: RTCVideoView(
                _video,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                filterQuality: FilterQuality.low, // for iOS release rendering
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

        if (_loading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
          ),

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
                    'Failed to load agent.\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _bootstrap();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
