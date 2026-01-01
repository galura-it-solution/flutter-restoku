import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:slims/core/utils/secure_storage.dart';

class TablesEventsService extends GetxService {
  final StreamController<String> _eventsController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  HttpClient? _client;
  StreamSubscription<String>? _streamSub;
  Timer? _reconnectTimer;
  bool _connected = false;
  bool _connecting = false;
  int _attempts = 0;

  Stream<String> get events => _eventsController.stream;
  Stream<bool> get connectionChanges => _connectionController.stream;
  bool get isConnected => _connected;

  Future<void> ensureConnected() async {
    if (_connected || _connecting) return;
    await _connect();
  }

  Future<void> _connect() async {
    _connecting = true;
    await _streamSub?.cancel();
    _streamSub = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _client?.close(force: true);
    _client = HttpClient();

    final token = await SecureStorageHelper.getAccessToken() ?? '';
    if (token.isEmpty) {
      _markDisconnected();
      _scheduleReconnect();
      _connecting = false;
      return;
    }

    final uri = Uri.parse(
      '${SecureStorageHelper.generateBaseUrl()}/api/v1/tables/events',
    );

    try {
      final request = await _client!.getUrl(uri);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'text/event-stream');

      final response = await request.close();
      if (response.statusCode != 200) {
        _markDisconnected();
        _scheduleReconnect();
        _connecting = false;
        return;
      }

      _attempts = 0;
      _markConnected();

      _streamSub = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!line.startsWith('data:')) return;
              final payload = line.replaceFirst('data:', '').trim();
              if (payload.isEmpty) return;
              _eventsController.add(payload);
            },
            onError: (_) {
              _markDisconnected();
              _scheduleReconnect();
            },
            onDone: () {
              _markDisconnected();
              _scheduleReconnect();
            },
            cancelOnError: true,
          );
    } catch (_) {
      _markDisconnected();
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _markConnected() {
    if (_connected) return;
    _connected = true;
    _connectionController.add(true);
  }

  void _markDisconnected() {
    if (!_connected && !_connecting) return;
    _connected = false;
    _connectionController.add(false);
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    _attempts = (_attempts + 1).clamp(1, 6);
    final backoff = 2 << (_attempts - 1);
    final delaySeconds = backoff > 30 ? 30 : backoff;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _connect();
    });
  }
}
