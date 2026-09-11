import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/config_model.dart';
import '../models/license_model.dart';

class StorageService {
  static const _keyConfigs = 'parsa_configs';
  static const _keyLicenses = 'parsa_licenses';
  static const _keyLastConfig = 'parsa_last_config';
  static const _keyCurrentLicense = 'parsa_current_license';
  static const _keyIsAdminLoggedIn = 'parsa_admin_logged_in';

  static Future<List<V2RayConfig>> loadConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyConfigs) ?? [];
      final configs = <V2RayConfig>[];
      for (final s in list) {
        try {
          final json = jsonDecode(s) as Map<String, dynamic>;
          final cfg = V2RayConfig.fromJson(json);
          if (cfg != null) configs.add(cfg);
        } catch (_) {}
      }
      return configs;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveConfigs(List<V2RayConfig> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = configs.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(_keyConfigs, list);
    } catch (_) {}
  }

  static Future<String?> loadLastConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastConfig);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLastConfig(String raw) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastConfig, raw);
    } catch (_) {}
  }

  static Future<List<License>> loadLicenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyLicenses) ?? [];
      final licenses = <License>[];
      for (final s in list) {
        try {
          final json = jsonDecode(s) as Map<String, dynamic>;
          licenses.add(License.fromJson(json));
        } catch (_) {}
      }
      return licenses;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLicenses(List<License> licenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = licenses.map((l) => jsonEncode(l.toJson())).toList();
      await prefs.setStringList(_keyLicenses, list);
    } catch (_) {}
  }

  static Future<void> addLicense(License license) async {
    final list = await loadLicenses();
    list.add(license);
    await saveLicenses(list);
  }

  static Future<void> removeLicense(String key) async {
    final list = await loadLicenses();
    list.removeWhere((l) => l.key == key);
    await saveLicenses(list);
  }

  static Future<String?> loadCurrentLicenseKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyCurrentLicense);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCurrentLicenseKey(String? key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (key == null) {
        await prefs.remove(_keyCurrentLicense);
      } else {
        await prefs.setString(_keyCurrentLicense, key);
      }
    } catch (_) {}
  }

  static Future<bool> isAdminLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsAdminLoggedIn) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setAdminLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsAdminLoggedIn, value);
    } catch (_) {}
  }
}
