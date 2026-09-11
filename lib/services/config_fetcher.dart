import 'package:http/http.dart' as http;
import '../models/config_model.dart';

class ConfigFetcher {
  static const List<String> sources = [
    'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/vless_configs.txt',
    'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/vmess_configs.txt',
    'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/ss_configs.txt',
    'https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/refs/heads/main/Protocols/vless.txt',
    'https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/refs/heads/main/Protocols/trojan.txt',
    'https://raw.githubusercontent.com/SoliSpirit/v2ray-configs/refs/heads/main/all_configs.txt',
    'https://raw.githubusercontent.com/mahdibland/V2RayAggregator/master/sub/sub_merge.txt',
    'https://raw.githubusercontent.com/barry-far/V2ray-Configs/main/All_Configs_Sub.txt',
  ];

  static Future<List<V2RayConfig>> fetchAll({
    void Function(int done, int total)? onProgress,
  }) async {
    final List<V2RayConfig> result = [];
    final Set<String> seen = {};
    int completed = 0;

    for (final url in sources) {
      try {
        final res = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 12));
        if (res.statusCode == 200) {
          for (final line in res.body.split('\n')) {
            final trimmed = line.trim();
            if (trimmed.isEmpty || seen.contains(trimmed)) continue;
            final cfg = V2RayConfig.fromRaw(trimmed);
            if (cfg != null) {
              seen.add(trimmed);
              result.add(cfg);
            }
          }
        }
      } catch (_) {}
      completed++;
      onProgress?.call(completed, sources.length);
    }

    return result;
  }
}
