import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../widgets/vpn_logo.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _licenseCtrl = TextEditingController();
  final _adminCtrl = TextEditingController();

  bool _showAdminField = false;
  bool _loading = false;
  bool _obscureAdmin = true;
  String? _error;

  Future<void> _loginWithLicense() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthService.loginWithLicense(_licenseCtrl.text);
      if (!mounted) return;
      setState(() => _loading = false);

      if (result.success && result.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: result.user!)),
        );
      } else {
        setState(() => _error = result.error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'خطای غیرمنتظره';
      });
    }
  }

  Future<void> _loginAsAdmin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthService.loginAsAdmin(_adminCtrl.text);
      if (!mounted) return;
      setState(() => _loading = false);

      if (result.success && result.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: result.user!)),
        );
      } else {
        setState(() => _error = result.error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'خطای غیرمنتظره';
      });
    }
  }

  @override
  void dispose() {
    _licenseCtrl.dispose();
    _adminCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                _buildHeader(),
                const SizedBox(height: 40),
                if (_error != null) _buildError(),
                _buildLicenseField(),
                const SizedBox(height: 16),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildAdminToggle(),
                if (_showAdminField) ...[
                  const SizedBox(height: 16),
                  _buildAdminField(),
                  const SizedBox(height: 16),
                  _buildAdminLoginButton(),
                ],
                const SizedBox(height: 30),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const VpnLogo(size: 100),
        const SizedBox(height: 20),
        const Text(
          'ورود به پارسا VPN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'برای ادامه، کلید لایسنس خود را وارد کنید',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error ?? '',
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'کلید لایسنس',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _licenseCtrl,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            color: AppColors.neon,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          decoration: const InputDecoration(
            hintText: 'XXXX-XXXX-XXXX-XXXX',
            hintStyle: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              letterSpacing: 2,
            ),
            prefixIcon: Icon(
              Icons.vpn_key_outlined,
              color: AppColors.neon,
              size: 20,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _loginWithLicense,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
          : const Text(
              'ورود',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
    );
  }

  Widget _buildAdminToggle() {
    return TextButton(
      onPressed: () => setState(() => _showAdminField = !_showAdminField),
      child: Text(
        _showAdminField ? '─ بستن ورود مدیران ─' : '─ ورود مدیران ─',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
  }

  Widget _buildAdminField() {
    return TextField(
      controller: _adminCtrl,
      textAlign: TextAlign.center,
      obscureText: _obscureAdmin,
      style: const TextStyle(
        color: AppColors.neon,
        fontSize: 14,
        letterSpacing: 2,
      ),
      decoration: InputDecoration(
        hintText: '••••••',
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: const Icon(
          Icons.admin_panel_settings_outlined,
          color: AppColors.neon,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureAdmin ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMuted,
            size: 18,
          ),
          onPressed: () => setState(() => _obscureAdmin = !_obscureAdmin),
        ),
      ),
    );
  }

  Widget _buildAdminLoginButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _loginAsAdmin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.neon,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.neon),
        ),
        elevation: 0,
      ),
      child: const Text(
        'ورود مدیر',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'Parsa VPN v2.0.0',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textDisabled,
        fontSize: 10,
        letterSpacing: 2,
      ),
    );
  }
}
