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
        title:
