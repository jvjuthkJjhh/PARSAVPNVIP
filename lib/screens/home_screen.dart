import 'dart:async';
import 'package:flutter/material.dart';

import '../models/config_model.dart';
import '../models/user_model.dart';
import '../services/config_fetcher.dart';
import '../services/ping_service.dart';
import '../services/storage_service.dart';
import '../services/vpn_service.dart';
import '../theme/colors.dart';
import '../widgets/connect_button.dart';
import '../widgets/info_card.dart';
import 'admin_screen.dart';
import 'configs_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _vpn = VpnService.instance;

  List<V2RayConfig> _configs = [];
  V2RayConfig? _selected;

  bool _loading = false;
  bool _connecting = false;
  bool _connected = false;
  String _statusText = 'قطع';
  String _progressText = '';

  int? _downSpeed;
  int? _upSpeed;
  DateTime? _connectTime;
  Timer? _durationTimer;

  late AnimationController _pulse;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);

    _vpn.initialize();
    _listenStatus();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final configs = await StorageService.loadConfigs();
      if (!mounted) return;
      setState(() {
        _configs = configs;
        if (configs.isNotEmpty) _selected = configs.first;
      });
    } catch (_) {}
  }

  void _listenStatus() {
    _statusSub = _vpn.statusStream.listen((status) {
      if (!mounted) return;
      setState(() {
        if (status.state == V2RayStatus.connected) {
          _connected = true;
          _connecting = false;
          _statusText = 'متصل';
          _connectTime ??= DateTime.now();
          _startDurationTimer();
        } else if (status.state == V2RayStatus.disconnected) {
          _connected = false;
          _connecting = false;
          _statusText = 'قطع';
          _downSpeed = null;
          _upSpeed = null;
          _stopDurationTimer();
        } else if (status.state == V2RayStatus.connecting) {
          _connecting = true;
          _statusText = 'در حال اتصال...';
        }
        _downSpeed = status.downloadSpeed;
        _upSpeed = status.uploadSpeed;
      });
    });
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _connectTime = null;
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _pulse.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchConfigs() async {
    setState(() {
      _loading = true;
      _progressText = 'در حال دریافت...';
      _configs.clear();
      _selected = null;
    });

    try {
      final fetched = await ConfigFetcher.fetchAll(
        onProgress: (done, total) {
          if (mounted) {
            setState(() => _progressText = 'دریافت $done/$total');
          }
        },
      );

      if (!mounted) return;

      if (fetched.isEmpty) {
        setState(() {
          _loading = false;
          _progressText = '';
        });
        _snack('هیچ کانفیگی دریافت نشد');
        return;
      }

      setState(() => _progressText = 'پینگ‌گیری...');

      final pinged = await PingService.pingAll(
        fetched,
        onProgress: (done, total) {
          if (mounted) {
            setState(() => _progressText = 'پینگ $done/$total');
          }
        },
      );

      if (!mounted) return;

      final top10 = pinged.take(10).toList();
      final named = <V2RayConfig>[];
      for (int i = 0; i < top10.length; i++) {
        named.add(V2RayConfig(
          raw: top10[i].raw,
          protocol: top10[i].protocol,
          name: 'Parsa VIP ${(i + 1).toString().padLeft(2, '0')}',
          host: top10[i].host,
          port: top10[i].port,
          tcpPing: top10[i].tcpPing,
          realPing: top10[i].realPing,
        ));
      }

      try {
        await StorageService.saveConfigs(named);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _configs = named;
        _loading = false;
        _progressText = '';
        if (named.isNotEmpty) _selected = named.first;
      });

      _snack('۱۰ کانفیگ VIP آماده شد');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _progressText = '';
      });
      _snack('خطا در جستجو');
    }
  }

  Future<void> _toggleConnection() async {
    if (_connecting) return;

    if (_connected) {
      setState(() {
        _connecting = true;
        _statusText = 'در حال قطع...';
      });
      await _vpn.disconnect();
      return;
    }

    if (_selected == null) {
      _snack('اول یک کانفیگ انتخاب کن');
      return;
    }

    setState(() {
      _connecting = true;
      _statusText = 'در حال اتصال...';
    });

    final ok = await _vpn.connect(_selected!);
    if (ok) {
      try {
        await StorageService.saveLastConfig(_selected!.raw);
      } catch (_) {}
    } else {
      setState(() {
        _connecting = false;
        _statusText = 'خطا در اتصال';
      });
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Duration? get _duration {
    if (_connectTime == null) return null;
    return DateTime.now().difference(_connectTime!);
  }

  String _fmtSpeed(int? bps) {
    if (bps == null) return '0';
    final kb = bps / 1024;
    if (kb < 1024) return kb.toStringAsFixed(0);
    return (kb / 1024).toStringAsFixed(1);
  }

  String _fmtDuration(Duration? d) {
    if (d == null) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _openConfigs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfigsScreen(
          configs: _configs,
          selected: _selected,
          onSelect: (cfg) {
            setState(() => _selected = cfg);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Spacer(),
              ConnectButton(
                connected: _connected,
                connecting: _connecting,
                onTap: _toggleConnection,
                pulse: _pulse,
              ),
              const SizedBox(height: 20),
              Text(
                _statusText,
                style: TextStyle(
                  color: _connected ? AppColors.success : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (_selected != null)
                Text(
                  '${_selected!.protocolShort} • ${_selected!.shortName}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              if (_connected) _buildSpeedRow(),
              const SizedBox(height: 12),
              _buildBottomCards(),
              const SizedBox(height: 12),
              if (_loading) _buildProgress(),
              _buildSearchButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'VPN',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parsa VPN',
                  style: TextStyle(
                    color: AppColors.neon,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  widget.user.isAdmin
                      ? widget.user.roleName
                      : '${widget.user.remainingDays} روز باقی‌مانده',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (widget.user.isAdmin)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings,
                  color: AppColors.neon),
            ),
          IconButton(
            onPressed: _openConfigs,
            icon: const Icon(Icons.list, color: AppColors.neon),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: InfoCard(
              icon: Icons.arrow_downward,
              label: 'دانلود',
              value: '${_fmtSpeed(_downSpeed)} KB/s',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InfoCard(
              icon: Icons.arrow_upward,
              label: 'آپلود',
              value: '${_fmtSpeed(_upSpeed)} KB/s',
              color: AppColors.neon,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InfoCard(
              icon: Icons.timer_outlined,
              label: 'زمان',
              value: _fmtDuration(_duration),
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: InfoCard(
              icon: Icons.location_on_outlined,
              label: 'موقعیت شما',
              value: 'ایران',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InfoCard(
              icon: Icons.speed,
              label: 'کانفیگ فعال',
              value: _selected?.name ?? 'هیچ',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Column(
        children: [
          const LinearProgressIndicator(
            backgroundColor: AppColors.card,
            color: AppColors.neon,
            minHeight: 3,
          ),
          const SizedBox(height: 6),
          Text(
            _progressText,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _searchConfigs,
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              )
            : const Icon(Icons.search, size: 18),
        label: Text(
          _loading ? 'در حال جستجو...' : 'جستجوی کانفیگ VIP',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neon,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
