enum UserRole { guest, user, admin }

class AppUser {
  final String id;
  final UserRole role;
  final String? licenseKey;
  final DateTime? licenseExpiresAt;

  AppUser({
    required this.id,
    required this.role,
    this.licenseKey,
    this.licenseExpiresAt,
  });

  bool get isAdmin => role == UserRole.admin;

  int get remainingDays {
    if (isAdmin) return 999999;
    if (licenseExpiresAt == null) return 0;
    final diff = licenseExpiresAt!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String get roleName {
    switch (role) {
      case UserRole.admin:
        return 'مدیر';
      case UserRole.user:
        return 'کاربر';
      default:
        return 'مهمان';
    }
  }

  static AppUser admin() => AppUser(id: 'admin', role: UserRole.admin);

  static AppUser withLicense(String key, DateTime expires) => AppUser(
        id: key,
        role: UserRole.user,
        licenseKey: key,
        licenseExpiresAt: expires,
      );
}
