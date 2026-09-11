import '../models/license_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  static const String ADMIN_PASSWORD = 'poiiu';

  static Future<AuthResult> loginWithLicense(String key) async {
    key = key.trim().toUpperCase();

    if (key.isEmpty) {
      return AuthResult.fail('لطفاً کلید لایسنس را وارد کنید');
    }

    final licenses = await StorageService.loadLicenses();
    License? found;
    for (final l in licenses) {
      if (l.key.toUpperCase() == key) {
        found = l;
        break;
      }
    }

    if (found == null) {
      return AuthResult.fail('کلید لایسنس نامعتبر است');
    }

    if (found.isExpired) {
      return AuthResult.fail('این کلید منقضی شده است');
    }

    if (!found.isActive) {
      return AuthResult.fail('این کلید غیرفعال شده است');
    }

    await StorageService.saveCurrentLicenseKey(found.key);
    final user = AppUser.withLicense(found.key, found.expiresAt);
    return AuthResult.success(user);
  }

  static Future<AuthResult> loginAsAdmin(String password) async {
    if (password != ADMIN_PASSWORD) {
      return AuthResult.fail('رمز مدیر اشتباه است');
    }
    await StorageService.setAdminLoggedIn(true);
    return AuthResult.success(AppUser.admin());
  }

  static Future<AppUser?> checkAutoLogin() async {
    try {
      final isAdmin = await StorageService.isAdminLoggedIn();
      if (isAdmin) {
        return AppUser.admin();
      }

      final key = await StorageService.loadCurrentLicenseKey();
      if (key == null) return null;

      final licenses = await StorageService.loadLicenses();
      for (final l in licenses) {
        if (l.key == key && l.isValid) {
          return AppUser.withLicense(l.key, l.expiresAt);
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    await StorageService.saveCurrentLicenseKey(null);
    await StorageService.setAdminLoggedIn(false);
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final AppUser? user;

  AuthResult({
    required this.success,
    this.error,
    this.user,
  });

  factory AuthResult.success(AppUser user) =>
      AuthResult(success: true, user: user);

  factory AuthResult.fail(String error) =>
      AuthResult(success: false, error: error);
}
