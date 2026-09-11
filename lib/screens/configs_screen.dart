import 'package:flutter/material.dart';
import '../models/config_model.dart';
import '../theme/colors.dart';

class ConfigsScreen extends StatefulWidget {
  final List<V2RayConfig> configs;
  final V2RayConfig? selected;
  final Function(V2RayConfig) onSelect;

  const ConfigsScreen({
    super.key,
    required this.configs,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends State<ConfigsScreen> {
  Color _protocolColor(String p) {
    switch (p) {
      case 'VLESS':
        return AppColors.vless;
      case 'VMess':
        return AppColors.vmess;
      case 'Trojan':
        return AppColors.trojan;
      case 'Shadowsocks':
        return AppColors.shadowsocks;
      default:
        return Colors.grey;
    }
  }

  Color _pingColor(int? ping) {
    if (ping == null) return AppColors.danger;
    if (ping < 200) return AppColors.success;
    if (ping < 500) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('کانفیگ‌های Parsa VIP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.configs.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.configs.length,
              itemBuilder: (_, i) => _buildTile(widget.configs[i]),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.dns_outlined,
              color: AppColors.textDisabled, size: 60),
          const SizedBox(height: 12),
          const Text(
            'هنوز کانفیگی نداری',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'از صفحه اصلی «جستجوی VIP» رو بزن',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(V2RayConfig c) {
    final isSelected = widget.selected?.raw == c.raw;
    final ping = c.bestPing;

    return GestureDetector(
      onTap: () {
        widget.onSelect(c);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neon.withOpacity(0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.neon : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neon.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _protocolColor(c.protocol).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  c.protocolShort,
                  style: TextStyle(
                    color: _protocolColor(c.protocol),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.protocol,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ping == null ? '✕' : '$ping',
                  style: TextStyle(
                    color: _pingColor(ping),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'ms',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle,
                    color: AppColors.neon, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
