import '../models/license_model.dart';
import 'storage_service.dart';

class LicenseService {
  static Future<License> generateLicense({required int days}) async {
    final license = License.create(days: days);
    await StorageService.addLicense(license);
    return license;
  }

  static Future<List<License>> getAll() async {
    return await StorageService.loadLicenses();
  }

  static Future<void> deleteLicense(String key) async {
    await StorageService.removeLicense(key);
  }

  static Future<LicenseStats> getStats() async {
    final list = await StorageService.loadLicenses();
    int active = 0;
    int expired = 0;
    for (final l in list) {
      if (l.isValid) {
        active++;
      } else {
        expired++;
      }
    }
    return LicenseStats(
      total: list.length,
      active: active,
      expired: expired,
    );
  }
}

class LicenseStats {
  final int total;
  final int active;
  final int expired;

  LicenseStats({
    required this.total,
    required this.active,
    required this.expired,
  });
}
