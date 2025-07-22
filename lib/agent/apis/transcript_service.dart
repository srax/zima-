import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../app/constants/constant.dart';
import '../../auth/apis/auth_api.dart';

typedef TranscriptCallback = void Function(String text);

class TranscriptService {
  TranscriptService({required this.onTranscript});

  final TranscriptCallback onTranscript;

  late final io.Socket _sock;
  bool _connected = false;
  bool _muted = true;

  Future<void> connect() async {
    _sock = io.io(
      '$kServerUrl/deepfake',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer ${AuthApi.token}'})
          .disableAutoConnect()
          .build(),
    );

    _sock
      ..onConnect((_) {
        _connected = true;
        _sock.emit('start_session');
      })
      ..on('session_started', (_) => _muted = true)
      ..on('transcript', (data) {
        final txt = (data is Map && data['text'] is String)
            ? data['text'] as String
            : data.toString();
        onTranscript(txt);
      })
      ..onDisconnect((_) {
        _connected = false;
      });

    _sock.connect();
  }

  /* ───── Streaming ───── */

  void sendAudioChunk(Uint8List bytes) {
    if (_connected && !_muted) _sock.emit('audio_chunk', bytes);
  }

  void unmute() {
    if (_connected && _muted) {
      _sock.emit('mute', {'muted': false});
      _muted = false;
    }
  }

  void mute() {
    if (_connected && !_muted) {
      _sock.emit('mute', {'muted': true});
      _muted = true;
    }
  }

  /* ───── Cleanup ───── */

  void dispose() {
    if (_connected) _sock.emit('end_session');
    _sock.dispose();
  }
}
