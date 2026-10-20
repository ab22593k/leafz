import 'package:checks/checks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/data/services/storage_service.dart';
import 'package:leafz/ui/features/puzzle/view_models/game_mode_strategy.dart';
import 'package:leafz/ui/features/puzzle/view_models/speedrun_game_mode_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStrategyHost extends Mock implements GameModeStrategyHost {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('SpeedrunGameModeStrategy', () {
    late SpeedrunGameModeStrategy strategy;
    late MockStrategyHost host;

    setUp(() {
      strategy = SpeedrunGameModeStrategy();
      host = MockStrategyHost();
      when(() => host.n).thenReturn(4);
      when(() => host.storageService).thenReturn(MockStorageService());
    });

    test('mode returns GameMode.speedrun', () {
      check(strategy.mode).equals(GameMode.speedrun);
    });

    test('speedrunCountdownSeconds returns correct value for size 3', () {
      when(() => host.n).thenReturn(3);
      strategy.onActivate(host);
      check(strategy.speedrunCountdownSeconds).equals(60);
    });

    test('speedrunCountdownSeconds returns correct value for size 4', () {
      when(() => host.n).thenReturn(4);
      strategy.onActivate(host);
      check(strategy.speedrunCountdownSeconds).equals(180);
    });

    test('speedrunCountdownSeconds returns correct value for size 5', () {
      when(() => host.n).thenReturn(5);
      strategy.onActivate(host);
      check(strategy.speedrunCountdownSeconds).equals(300);
    });

    test('speedrunCountdownSeconds returns correct value for size 6', () {
      when(() => host.n).thenReturn(6);
      strategy.onActivate(host);
      check(strategy.speedrunCountdownSeconds).equals(480);
    });

    test('speedrunCountdownSeconds returns 0 when host is not activated', () {
      check(strategy.speedrunCountdownSeconds).equals(0);
    });

    test('onActivate stores the host reference', () {
      strategy.onActivate(host);
      // After activation, speedrunCountdownSeconds should work
      when(() => host.n).thenReturn(4);
      check(strategy.speedrunCountdownSeconds).equals(180);
    });

    test('onDeactivate clears the host reference', () {
      strategy.onActivate(host);
      strategy.onDeactivate(host);
      check(strategy.speedrunCountdownSeconds).equals(0);
    });

    test('lifecycle hooks are no-ops by default', () {
      strategy.onActivate(host);
      strategy.onPuzzleGenerated(host);
      strategy.onTileMoved(host);
      strategy.onPuzzleSolved(host);
      strategy.onDeactivate(host);
      // Should not throw — all lifecycle hooks are no-ops (they call
      // notifyListeners only if needed, which is fine on a mock).
    });
  });
}
