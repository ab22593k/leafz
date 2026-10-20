import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/domain/models/location.dart';
import 'package:leafz/data/services/storage_service.dart';
import 'package:leafz/helpers/game_mode_helper.dart';
import 'package:leafz/ui/features/puzzle/view_models/game_mode_strategy.dart';
import 'package:leafz/ui/features/puzzle/view_models/blind_game_mode_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStrategyHost extends Mock implements GameModeStrategyHost {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('BlindGameModeStrategy', () {
    late BlindGameModeStrategy strategy;
    late MockStrategyHost host;

    setUp(() {
      strategy = BlindGameModeStrategy();
      host = MockStrategyHost();
      when(() => host.n).thenReturn(4);
      when(() => host.storageService).thenReturn(MockStorageService());
    });

    test('mode returns GameMode.blind', () {
      check(strategy.mode).equals(GameMode.blind);
    });

    group('initial state', () {
      test('tilesBlinded is false', () {
        check(strategy.tilesBlinded).isFalse();
      });

      test('blindRevealedTiles is empty', () {
        check(strategy.blindRevealedTiles).isEmpty();
      });

      test('isTileRevealed returns false for any location', () {
        const loc = Location(x: 1, y: 1);
        check(strategy.isTileRevealed(loc)).isFalse();
      });
    });

    group('resetBlindState', () {
      test('resets tilesBlinded to false', () {
        strategy.startBlindTimer();
        strategy.resetBlindState();
        check(strategy.tilesBlinded).isFalse();
      });

      test('clears revealed tiles', () {
        strategy.startBlindTimer();
        strategy.resetBlindState();
        check(strategy.blindRevealedTiles).isEmpty();
        check(strategy.tilesBlinded).isFalse();
      });

      test('can be called multiple times without error', () {
        strategy.resetBlindState();
        strategy.resetBlindState();
        strategy.resetBlindState();
        check(strategy.tilesBlinded).isFalse();
      });
    });

    group('revealBlindTile', () {
      test('does nothing when tiles are not blinded', () {
        const loc = Location(x: 2, y: 2);
        strategy.revealBlindTile(loc);
        check(strategy.isTileRevealed(loc)).isFalse();
        check(strategy.blindRevealedTiles).isEmpty();
      });

      test('reveals tile after tilesBlinded is true', () {
        const loc = Location(x: 1, y: 1);

        fakeAsync((async) {
          strategy.onActivate(host);
          strategy.startBlindTimer();
          async.elapse(
            Duration(seconds: GameModeHelper.blindHideDelaySeconds(4)),
          );
        });

        check(strategy.tilesBlinded).isTrue();
        strategy.revealBlindTile(loc);
        check(strategy.isTileRevealed(loc)).isTrue();
      });

      test('auto-hides revealed tile after 1.5 seconds', () {
        const loc = Location(x: 1, y: 1);

        fakeAsync((async) {
          strategy.onActivate(host);
          strategy.startBlindTimer();
          async.elapse(
            Duration(seconds: GameModeHelper.blindHideDelaySeconds(4)),
          );
        });

        check(strategy.tilesBlinded).isTrue();

        fakeAsync((async) {
          strategy.revealBlindTile(loc);
          check(strategy.isTileRevealed(loc)).isTrue();

          async.elapse(const Duration(milliseconds: 1500));
          check(strategy.isTileRevealed(loc)).isFalse();
        });
      });
    });

    group('startBlindTimer', () {
      test('hides tiles after the configured delay for size 3', () {
        when(() => host.n).thenReturn(3);

        fakeAsync((async) {
          strategy.onActivate(host);
          strategy.startBlindTimer();
          check(strategy.tilesBlinded).isFalse();

          async.elapse(const Duration(seconds: 14));
          check(strategy.tilesBlinded).isFalse();

          async.elapse(const Duration(seconds: 1));
          check(strategy.tilesBlinded).isTrue();
        });
      });

      test('clears previously revealed tiles when starting', () {
        fakeAsync((async) {
          strategy.onActivate(host);
          strategy.startBlindTimer();
          async.elapse(
            Duration(seconds: GameModeHelper.blindHideDelaySeconds(4)),
          );
        });

        check(strategy.tilesBlinded).isTrue();
        check(strategy.blindRevealedTiles).isEmpty();
      });

      test('notifies host when tiles become blinded', () {
        when(() => host.n).thenReturn(3);

        fakeAsync((async) {
          strategy.onActivate(host);
          strategy.startBlindTimer();

          async.elapse(const Duration(seconds: 15));
          verify(() => host.notifyListeners()).called(1);
        });
      });
    });

    group('lifecycle', () {
      test('onActivate stores host reference', () {
        strategy.onActivate(host);
        strategy.startBlindTimer();
        // Should not throw — host is stored
        check(strategy.tilesBlinded).isFalse();
      });

      test('onDeactivate resets blind state and clears host', () {
        fakeAsync((async) {
          strategy.onActivate(host);
          strategy.startBlindTimer();
          async.elapse(const Duration(seconds: 10));
        });

        strategy.onDeactivate(host);
        check(strategy.tilesBlinded).isFalse();
        check(strategy.blindRevealedTiles).isEmpty();
      });

      test('onPuzzleGenerated starts blind timer', () {
        strategy.onActivate(host);
        fakeAsync((async) {
          strategy.onPuzzleGenerated(host);
          async.elapse(
            Duration(seconds: GameModeHelper.blindHideDelaySeconds(4)),
          );
          check(strategy.tilesBlinded).isTrue();
        });
      });
    });
  });
}
