import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ConnectButton extends StatelessWidget {
  final bool connected;
  final bool connecting;
  final VoidCallback onTap;
  final Animation<double> pulse;

  const ConnectButton({
    super.key,
    required this.connected,
    required this.connecting,
    required this.onTap,
    required this.pulse,
  });

  Color get _color {
    if (connected) return AppColors.success;
    if (connecting) return AppColors.warning;
    return AppColors.neon;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: connecting ? null : onTap,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (_, __) => Transform.scale(
          scale: connected ? pulse.value : 1.0,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _color.withOpacity(0.25),
                  _color.withOpacity(0.05),
                ],
              ),
              border: Border.all(color: _color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.5),
                  blurRadius: 50,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: _color.withOpacity(0.2),
                  blurRadius: 80,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: Center(
              child: connecting
                  ? const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: 60,
                          color: _color,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          connected ? 'قطع' : 'اتصال',
                          style: TextStyle(
                            color: _color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
