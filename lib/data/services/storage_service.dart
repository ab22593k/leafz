/// Application directory/namespace name used across storage paths.
///
/// Used on Linux as the subdirectory under XDG base directories
/// (e.g. `~/.local/share/leafz/`, `~/.cache/leafz/`) and as the
/// KConfig-style data file name (`leafzrc`).
const String appStorageDirName = 'leafz';

class StorageKey {
  static const String puzzle = 'puzzle';
  static const String secondsElapsed = 'secondsElapsed';
  static const String scores = 'scores';
  static const String gameMode = 'gameMode';
  static const String marathonStartSize = 'marathonStartSize';
  static const String marathonEndSize = 'marathonEndSize';
}

abstract class StorageService {
  Future<void> init();
  Future<void> remove(String key);
  T? get<T>(String key);
  Future<void> clear();
  bool has(String key);
  Future<void> set(String? key, dynamic data);
}
