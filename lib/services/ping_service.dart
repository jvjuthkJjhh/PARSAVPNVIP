import 'dart:io';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import '../models/config_model.dart';

class PingService {
  static final V2ray _v2ray = V2ray(onStatusChanged: (_) {});
  static bool _init = false;

  static Future<void> _ensureInit() async {
    if (_init) return;
    try {
      await _v2ray.initialize(
        notificationIconResourceType: "mipmap",
        notificationIconResourceName: "ic_launcher",
      );
      _init = true;
    } catch (_) {}
  }

  static Future<int?> tcpPing(String host, int port) async {
    if (host.isEmpty || port == 0) return null;
    final sw = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 2),
      );
      socket.destroy();
      sw.stop();
      return sw.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> realPing(V2RayConfig cfg) async {
    try {
      await _ensureInit();
      V2RayURL parser = V2ray.parseFromURL(cfg.raw);
      final config = parser.getFullConfiguration();
      final delay = await _v2ray
          .getServerDelay(config: config)
          .timeout(const Duration(seconds: 5));
      return (delay != null && delay > 0) ? delay : null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<V2RayConfig>> pingAll(
    List<V2RayConfig> configs, {
    int tcpConcurrency = 40,
    void Function(int done, int total)? onProgress,
  }) async {
    final List<V2RayConfig> alive = [];

    for (int i = 0; i < configs.length; i += tcpConcurrency) {
      final chunk = configs.sublist(
        i,
        (i + tcpConcurrency > configs.length)
            ? configs.length
            : i + tcpConcurrency,
      );
      await Future.wait(chunk.map((c) async {
        c.tcpPing = await tcpPing(c.host, c.port);
      }));
      alive.addAll(chunk.where((c) => c.tcpPing != null));
      onProgress?.call(i + chunk.length, configs.length);
    }

    alive.sort((a, b) => a.tcpPing!.compareTo(b.tcpPing!));
    return alive;
  }
}
