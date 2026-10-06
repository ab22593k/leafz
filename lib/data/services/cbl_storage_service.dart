import 'dart:convert';
import 'dart:io';

import 'package:leafz/data/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

class KConfigStorageService implements StorageService {
  final Map<String, dynamic> _cache = {};
  File? _kconfigFile;
  SharedPreferences? _prefs;

  bool get _useKConfig => Platform.isLinux;

  @override
  Future<void> init() async {
    if (_useKConfig) {
      await _initKConfig();
    } else {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> _initKConfig() async {
    final home = Platform.environment['HOME'];
    if (home == null) {
      final appDir = await getApplicationDocumentsDirectory();
      _kconfigFile = File('${appDir.path}/${appStorageDirName}rc');
    } else {
      await xdg.dataHome.create(recursive: true);
      _kconfigFile = File('${xdg.dataHome.path}/${appStorageDirName}rc');
    }
    if (await _kconfigFile!.exists()) {
      final content = await _kconfigFile!.readAsString();
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty ||
            trimmed.startsWith(';') ||
            trimmed.startsWith('#') ||
            trimmed.startsWith('[')) {
          continue;
        }
        final eq = trimmed.indexOf('=');
        if (eq == -1) continue;
        final key = trimmed.substring(0, eq).trim();
        final value = trimmed.substring(eq + 1).trim();
        try {
          _cache[key] = json.decode(value);
        } catch (_) {
          _cache[key] = value;
        }
      }
    }
  }

  Future<void> _flush() async {
    final buffer = StringBuffer();
    buffer.writeln('[General]');
    for (final entry in _cache.entries) {
      buffer.writeln('${entry.key}=${json.encode(entry.value)}');
    }
    await _kconfigFile!.writeAsString(buffer.toString());
  }

  @override
  T? get<T>(String key) {
    dynamic raw;
    if (_useKConfig) {
      raw = _cache[key];
    } else {
      final value = _prefs!.get(key);
      if (value is! String) return value as T?;
      try {
        raw = json.decode(value);
      } catch (_) {
        return value as T?;
      }
    }
    if (raw == null) return null;
    return raw as T?;
  }

  @override
  bool has(String key) {
    if (_useKConfig) return _cache.containsKey(key);
    return _prefs!.containsKey(key);
  }

  @override
  Future<void> set(String? key, dynamic data) async {
    if (key == null) return;
    if (_useKConfig) {
      _cache[key] = data;
      await _flush();
    } else {
      await _prefs!.setString(key, json.encode(data));
    }
  }

  @override
  Future<void> remove(String key) async {
    if (_useKConfig) {
      _cache.remove(key);
      await _flush();
    } else {
      await _prefs!.remove(key);
    }
  }

  @override
  Future<void> clear() async {
    if (_useKConfig) {
      _cache.clear();
      await _flush();
    } else {
      await _prefs!.clear();
    }
  }
}
