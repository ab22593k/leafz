import 'package:checks/checks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/data/services/storage_service.dart';
import 'package:leafz/ui/features/puzzle/view_models/game_mode_strategy.dart';
import 'package:leafz/ui/features/puzzle/view_models/marathon_game_mode_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

class MockStrategyHost extends Mock implements GameModeStrategyHost {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('MarathonGameModeStrategy', () {
    late MarathonGameModeStrategy strategy;
    late MockStrategyHost host;
    late MockStorageService storage;

    setUp(() {
      strategy = MarathonGameModeStrategy();
      storage = MockStorageService();
      host = MockStrategyHost();
      when(() => host.n).thenReturn(3);
      when(() => host.storageService).thenReturn(storage);
      when(() => host.gameMode).thenReturn(GameMode.marathon);
      when(
        () => storage.set(any(), any()),
      ).thenAnswer((_) => Future<void>.value());
      when(() => storage.remove(any())).thenAnswer((_) => Future<void>.value());
      strategy.onActivate(host);
    });

    test('mode returns GameMode.marathon', () {
      check(strategy.mode).equals(GameMode.marathon);
    });

    group('initial state', () {
      test('marathonStartSize is null', () {
        check(strategy.marathonStartSize).isNull();
      });

      test('marathonEndSize is null', () {
        check(strategy.marathonEndSize).isNull();
      });

      test('marathonRetried is false', () {
        check(strategy.marathonRetried).isFalse();
      });

      test('isMarathonComplete is false when no end size set', () {
        check(strategy.isMarathonComplete).isFalse();
      });
    });

    group('setMarathonRange', () {
      test('sets start and end sizes', () {
        strategy.setMarathonRange(3, 6);
        check(strategy.marathonStartSize).equals(3);
        check(strategy.marathonEndSize).equals(6);
      });

      test('persists to storage', () {
        strategy.setMarathonRange(3, 6);
        verify(() => storage.set(StorageKey.marathonStartSize, 3));
        verify(() => storage.set(StorageKey.marathonEndSize, 6));
      });
    });

    group('isMarathonComplete', () {
      test('returns false when n is below end size', () {
        strategy.setMarathonRange(3, 6);
        when(() => host.n).thenReturn(4);
        check(strategy.isMarathonComplete).isFalse();
      });

      test('returns true when n equals end size', () {
        strategy.setMarathonRange(3, 6);
        when(() => host.n).thenReturn(6);
        check(strategy.isMarathonComplete).isTrue();
      });

      test('returns true when n exceeds end size', () {
        strategy.setMarathonRange(3, 4);
        when(() => host.n).thenReturn(5);
        check(strategy.isMarathonComplete).isTrue();
      });
    });

    group('resetMarathonState', () {
      test('clears start and end sizes', () {
        strategy.setMarathonRange(3, 6);
        strategy.resetMarathonState();
        check(strategy.marathonStartSize).isNull();
        check(strategy.marathonEndSize).isNull();
      });

      test('clears retried flag', () {
        strategy.setMarathonRange(3, 6);
        strategy.readyMarathonAdvance();
        strategy.resetMarathonState();
        check(strategy.marathonRetried).isFalse();
      });
    });

    group('readyMarathonAdvance', () {
      test('flags the puzzle as solved so advanceMarathonSize proceeds', () {
        strategy.setMarathonRange(3, 6);
        when(() => host.n).thenReturn(3);
        strategy.readyMarathonAdvance();
        // advanceMarathonSize should increment n because _onPuzzleSolved = true
        strategy.advanceMarathonSize(host);
        // 3 was the initial n, after advance it should be 4
        verify(() => host.n = 4);
      });

      test('advanceMarathonSize does nothing without readyMarathonAdvance', () {
        strategy.setMarathonRange(3, 6);
        strategy.advanceMarathonSize(host);
        verifyNever(() => host.n = any());
      });
    });

    group('advanceMarathonSize', () {
      test('advances to next supported size', () {
        strategy.setMarathonRange(3, 6);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => host.n = 4);
      });

      test('calls generate for the new board', () {
        strategy.setMarathonRange(3, 6);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => host.generate(forceRefresh: true));
      });

      test('resets movesCount to 0', () {
        strategy.setMarathonRange(3, 6);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => host.movesCount = 0);
      });

      test('resets stopWatchSecondsOverride to 0', () {
        strategy.setMarathonRange(3, 6);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => host.stopWatchSecondsOverride = 0);
      });

      test('removes puzzle from storage', () {
        strategy.setMarathonRange(3, 6);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => storage.remove(StorageKey.puzzle));
      });

      test('stops advancing when reaching end size', () {
        strategy.setMarathonRange(4, 4);
        when(() => host.n).thenReturn(4);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        // n should stay at 4 since we've reached the end size
        verifyNever(() => host.n = any());
      });

      test('does not advance beyond the last supported size', () {
        when(() => host.n).thenReturn(6);
        strategy.setMarathonRange(3, 10);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verifyNever(() => host.n = any());
      });

      test('advances across multiple sizes', () {
        strategy.setMarathonRange(3, 6);

        // Advance 3→4.  setUp already stubs host.n = 3.
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => host.n = 4);

        // Advance 4→5
        when(() => host.n).thenReturn(4);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => host.n = 5);

        // Advance 5→6
        when(() => host.n).thenReturn(5);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verify(() => host.n = 6);

        // Try to advance 6→ (should stop, already at end)
        when(() => host.n).thenReturn(6);
        strategy.readyMarathonAdvance();
        strategy.advanceMarathonSize(host);
        verifyNever(() => host.n = any());
      });
    });

    group('lifecycle', () {
      test(
        'onDeactivate resets state and clears storage when not marathon',
        () {
          when(() => host.gameMode).thenReturn(GameMode.classic);
          strategy.setMarathonRange(3, 6);
          strategy.onDeactivate(host);
          verify(() => storage.remove(StorageKey.marathonStartSize));
          verify(() => storage.remove(StorageKey.marathonEndSize));
          check(strategy.marathonStartSize).isNull();
          check(strategy.marathonEndSize).isNull();
        },
      );

      test(
        'onDeactivate does not clear storage when still in marathon mode',
        () {
          // host.gameMode already returns GameMode.marathon from setUp
          strategy.setMarathonRange(3, 6);
          strategy.onDeactivate(host);
          verifyNever(() => storage.remove(StorageKey.marathonStartSize));
          verifyNever(() => storage.remove(StorageKey.marathonEndSize));
        },
      );

      test('onPuzzleSolved triggers advance flow', () {
        strategy.setMarathonRange(3, 6);
        strategy.onPuzzleSolved(host);
        // Should call readyMarathonAdvance + advanceMarathonSize
        verify(() => host.n = 4);
      });
    });
  });
}
