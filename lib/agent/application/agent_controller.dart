import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:record/record.dart' as rec;
import '../apis/transcript_service.dart';
import '../apis/did_api.dart';
import '../../auth/apis/auth_api.dart';

class AgentController extends ChangeNotifier {
  final String agentId;
  final TextEditingController textController = TextEditingController();

  late RTCVideoRenderer video;
  RTCPeerConnection? peerConnection;
  late final TranscriptService transcriptService;
  final rec.AudioRecorder recorder = rec.AudioRecorder();

  bool isRecording = false;
  bool initialHelloSent = false;
  bool isLoading = true;
  String? error;
  String? avatarUrl;

  String? chatId, streamId, sessionId;
  List<Map<String, dynamic>> ice = [];

  // Default avatar URL
  static const defaultAvatarUrl =
      'https://studio.d-id.com/agents-assets/avatars/anna_square.png';

  AgentController(this.agentId) {
    transcriptService = TranscriptService(onTranscript: _onTranscript);
    video = RTCVideoRenderer();
  }

  Future<void> initialize() async {
    try {
      await video.initialize();
      await transcriptService.connect();
      await _initAgentAndBootstrap();

      video.onFirstFrameRendered = () => debugPrint('✅ first video frame');
      video.onResize = () => notifyListeners();
    } catch (e) {
      error = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  Future<void> _onTranscript(String text) async {
    if (text.trim().isEmpty || chatId == null) return;
    try {
      await DidApi.sendMessage(agentId, chatId!, streamId!, sessionId!, text);
    } catch (_) {
      // UI already shows send errors
    }
  }

  Future<void> _initAgentAndBootstrap() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Fetch agent info to get avatar
      final agentsMap = await DidApi.fetchAgents();
      final allAgents = agentsMap['all'] ?? [];
      final mineAgents = agentsMap['mine'] ?? [];
      final allCombined = [...allAgents, ...mineAgents];
      final agent = allCombined.firstWhere(
        (a) => a['id'] == agentId,
        orElse: () => {},
      );
      avatarUrl = agent.isNotEmpty && agent['preview_thumbnail'] != null
          ? agent['preview_thumbnail'] as String
          : defaultAvatarUrl;
      await _bootstrap();
    } catch (e) {
      error = 'Failed to fetch agent info: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _bootstrap() async {
    try {
      // Create chat first
      final chatResponse = await DidApi.createChat(agentId);
      chatId = chatResponse['id'] as String;

      // Create stream with a default source URL
      final streamResponse = await DidApi.createStream(
        agentId,
        'https://example.com/video.mp4',
      );
      streamId = streamResponse['id'] as String;

      // Generate session ID (this might need to come from the API)
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();

      // Use default ICE servers for now
      ice = [
        {'urls': 'stun:stun.l.google.com:19302'},
      ];

      // Create peer connection
      final config = {'iceServers': ice, 'sdpSemantics': 'unified-plan'};

      peerConnection = await createPeerConnection(config, {
        'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
        'optional': [],
      });

      // Set up event handlers
      peerConnection!.onIceCandidate = _onIce;
      peerConnection!.onConnectionState = (state) {
        debugPrint('Connection state: $state');
      };

      // Add video track
      peerConnection!.onTrack = (event) {
        if (event.track.kind == 'video') {
          video.srcObject = event.streams[0];
        }
      };

      // Create offer
      final offer = await peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });

      await peerConnection!.setLocalDescription(offer);

      // Send answer (this is what the API expects)
      await DidApi.sendAnswer(agentId, streamId!, sessionId!, offer.sdp!);

      await _sendInitialHello();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (e is UnauthenticatedException) {
        error = 'Authentication failed';
      } else {
        error = 'WebRTC signaling error: $e';
      }
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _onIce(RTCIceCandidate candidate) async {
    try {
      await DidApi.sendIce(agentId, streamId!, sessionId!, {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    } catch (e) {
      if (e is UnauthenticatedException) {
        error = 'Authentication failed';
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading || error != null) return;

    textController.clear();
    try {
      await DidApi.sendMessage(agentId, chatId!, streamId!, sessionId!, text);
    } catch (e) {
      if (e is UnauthenticatedException) {
        error = 'Authentication failed';
        notifyListeners();
      }
    }
  }

  Future<void> _sendInitialHello() async {
    if (initialHelloSent ||
        chatId == null ||
        streamId == null ||
        sessionId == null) {
      return;
    }
    try {
      await DidApi.sendMessage(
        agentId,
        chatId!,
        streamId!,
        sessionId!,
        'hello',
      );
      initialHelloSent = true;
    } catch (e) {
      debugPrint('Failed to send initial hello: $e');
    }
  }

  Future<void> toggleVoiceRecording() async {
    if (isRecording) {
      await recorder.stop();
      transcriptService.mute();
    } else {
      final stream = await recorder.startStream(
        const rec.RecordConfig(
          encoder: rec.AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      stream.listen(transcriptService.sendAudioChunk);
      transcriptService.unmute();
    }
    isRecording = !isRecording;
    notifyListeners();
  }

  void retry() {
    isLoading = true;
    error = null;
    notifyListeners();
    _bootstrap();
  }

  @override
  void dispose() {
    transcriptService.dispose();
    recorder.dispose();
    DidApi.deleteStream(agentId, streamId ?? '');
    peerConnection?.close();
    video.dispose();
    textController.dispose();
    super.dispose();
  }
}
