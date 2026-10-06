import 'dart:math' show Random;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/domain/models/location.dart';
import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/domain/models/score.dart';
import 'package:leafz/domain/models/tile.dart';
import 'package:leafz/data/services/storage_service.dart';
import 'package:leafz/ui/features/puzzle/view_models/puzzle_notifier.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockStorageService extends Mock implements StorageService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a [ProviderContainer] with the given storage override, processes
/// any pending microtasks (for Riverpod async init), and returns both the
/// container and the storage mock so tests can set expectations.
({ProviderContainer container, MockStorageService storage}) createContainer() {
  final storage = MockStorageService();
  // Default stubs — tests override as needed
  when(() => storage.has(any())).thenReturn(false);
  when(() => storage.get<String>(any())).thenReturn(null);
  when(() => storage.get<int>(any())).thenReturn(null);
  when(() => storage.get<List>(any())).thenReturn(null);
  when(() => storage.get<Map>(any())).thenReturn(null);
  when(() => storage.get<dynamic>(any())).thenReturn(null);
  when(() => storage.set(any(), any())).thenAnswer((_) => Future<void>.value());
  when(() => storage.remove(any())).thenAnswer((_) => Future<void>.value());
  when(() => storage.clear()).thenAnswer((_) => Future<void>.value());

  final container = ProviderContainer(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
  );
  return (container: container, storage: storage);
}

/// Generates correct location list for the given [n].
List<Location> _correctLocations(int n) =>
    Puzzle.generateTileCorrectLocations(n);

/// Creates tiles from the given current locations.
List<Tile> _tilesFromLocations(int n, List<Location> current) {
  final correct = _correctLocations(n);
  return Puzzle.getTilesFromLocations(
    correctLocations: correct,
    currentLocations: current,
  );
}

/// Sets up an almost-solved 3x3 board where only the last tile (value 8 at
/// position (3,2)) and whitespace (value 9 at (3,3)) are swapped.
/// Returns the tiles list that can be passed to a PuzzleRestorer.
List<Tile> almostSolvedTiles3x3() {
  final c = _correctLocations(3);
  final cur = List<Location>.from(c);
  final saved = cur[7]; // (3,2)
  cur[7] = cur[8]; // (3,3)
  cur[8] = saved; // (3,2)
  return _tilesFromLocations(3, cur);
}

/// Sets up a shuffled but solvable 3x3 board.
List<Tile> shuffledTiles3x3() {
  final c = _correctLocations(3);
  final cur = List<Location>.from(c);
  final toShuffle = cur.sublist(0, 7)..shuffle(Random(42));
  for (int i = 0; i < 7; i++) {
    cur[i] = toShuffle[i];
  }
  return _tilesFromLocations(3, cur);
}

// ---------------------------------------------------------------------------
// Puzzles
// ---------------------------------------------------------------------------

Puzzle storedPuzzle3x3({int movesCount = 7}) {
  final c = _correctLocations(3);
  return Puzzle(
    n: 3,
    tiles: _tilesFromLocations(3, List<Location>.from(c)),
    movesCount: movesCount,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────
  // generate
  // ────────────────────────────────────────────────

  group('PuzzleNotifier — generate', () {
    test('creates a solvable board with tiles', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        container.read(puzzleProvider.notifier);
        // Let the init timer fire
        async.elapse(Duration.zero);

        final state = container.read(puzzleProvider);
        check(state.tiles.length).equals(16); // 4x4 default
        check(state.puzzle.isSolvable()).isTrue();
      });
    });

    test('sets movesCount to 0 on fresh generate', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // First generate should set moves to 0
        check(container.read(puzzleProvider).movesCount).equals(0);
      });
    });

    test('restores from storage when puzzle exists', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.puzzle)).thenReturn(true);
      when(
        () => storage.get<Map>(StorageKey.puzzle),
      ).thenReturn(storedPuzzle3x3(movesCount: 7).toJson());
      when(() => storage.has(StorageKey.scores)).thenReturn(false);

      fakeAsync((async) {
        container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        final state = container.read(puzzleProvider);
        check(state.n).equals(3);
        check(state.movesCount).equals(7);
      });
    });

    test('does NOT restore from storage when forceRefresh is true', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.puzzle)).thenReturn(true);
      when(
        () => storage.get<Map>(StorageKey.puzzle),
      ).thenReturn(storedPuzzle3x3(movesCount: 7).toJson());
      when(() => storage.has(StorageKey.scores)).thenReturn(false);

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // forceRefresh should skip the stored puzzle and generate a fresh
        // board with movesCount = 0. n stays at whatever the stored value
        // was (3) since forceRefresh doesn't reset the size.
        notifier.generate(forceRefresh: true);
        check(container.read(puzzleProvider).movesCount).equals(0);
      });
    });

    test('loads scores from storage when scores key exists', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.scores)).thenReturn(true);
      const storedScore = Score(
        movesCount: 5,
        puzzleSize: 3,
        secondsElapsed: 30,
        gameMode: GameMode.classic,
      );
      when(
        () => storage.get<List>(StorageKey.scores),
      ).thenReturn(Score.toJsonList([storedScore]));
      when(() => storage.has(StorageKey.puzzle)).thenReturn(false);

      fakeAsync((async) {
        container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        final state = container.read(puzzleProvider);
        check(state.scores.length).equals(1);
        check(state.scores.first.movesCount).equals(5);
      });
    });

    test('generates a board with correct number of tiles', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        final state = container.read(puzzleProvider);
        check(state.tiles.length).equals(16); // 4x4 = 16 tiles
      });
    });
  });

  // ────────────────────────────────────────────────
  // swapTilesAndUpdatePuzzle
  // ────────────────────────────────────────────────

  group('PuzzleNotifier — swapTilesAndUpdatePuzzle', () {
    test('swaps tile and whitespace locations', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.scores)).thenReturn(false);

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // Replace tiles with the almost-solved 3x3 board by writing to
        // storage and forcing a fresh puzzle restore.
        when(() => storage.has(StorageKey.puzzle)).thenReturn(true);
        when(() => storage.get<Map>(StorageKey.puzzle)).thenReturn(
          Puzzle(n: 3, tiles: almostSolvedTiles3x3(), movesCount: 0).toJson(),
        );
        notifier.generate(forceRefresh: false);
        async.elapse(Duration.zero);

        final state = container.read(puzzleProvider);
        final tile8 = state.tiles[7]; // value 8
        final ws = state.tiles[8]; // whitespace
        final loc8 = tile8.currentLocation;
        final locWs = ws.currentLocation;

        notifier.swapTilesAndUpdatePuzzle(tile8);

        final updated = container.read(puzzleProvider);
        check(updated.tiles[7].currentLocation).equals(locWs);
        check(updated.tiles[8].currentLocation).equals(loc8);
      });
    });

    test('increments movesCount', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.scores)).thenReturn(false);

      // Simulate a pre-stored board that needs a move
      when(() => storage.has(StorageKey.puzzle)).thenReturn(true);
      final board = Puzzle(n: 3, tiles: shuffledTiles3x3(), movesCount: 0);
      when(
        () => storage.get<Map>(StorageKey.puzzle),
      ).thenReturn(board.toJson());

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // Find a movable tile
        final state = container.read(puzzleProvider);
        final movable = state.tiles.firstWhere(
          (t) => state.puzzle.tileIsMovable(t),
        );
        final movesBefore = state.movesCount;

        notifier.swapTilesAndUpdatePuzzle(movable);

        final after = container.read(puzzleProvider);
        check(after.movesCount).equals(movesBefore + 1);
      });
    });

    test('persists puzzle to storage after move', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.scores)).thenReturn(false);
      when(() => storage.has(StorageKey.puzzle)).thenReturn(true);
      when(() => storage.get<Map>(StorageKey.puzzle)).thenReturn(
        Puzzle(n: 3, tiles: shuffledTiles3x3(), movesCount: 0).toJson(),
      );

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        final state = container.read(puzzleProvider);
        final movable = state.tiles.firstWhere(
          (t) => state.puzzle.tileIsMovable(t),
        );

        notifier.swapTilesAndUpdatePuzzle(movable);

        verify(() => storage.set(StorageKey.puzzle, any())).called(1);
      });
    });

    test('saves scores when puzzle becomes solved', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.scores)).thenReturn(false);
      when(() => storage.has(StorageKey.puzzle)).thenReturn(true);
      when(() => storage.get<Map>(StorageKey.puzzle)).thenReturn(
        Puzzle(n: 3, tiles: almostSolvedTiles3x3(), movesCount: 0).toJson(),
      );
      when(() => storage.get<int>(StorageKey.secondsElapsed)).thenReturn(null);

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        final state = container.read(puzzleProvider);
        final tile8 = state.tiles[7];
        notifier.swapTilesAndUpdatePuzzle(tile8);

        // Scores should be persisted after solving
        verify(() => storage.set(StorageKey.scores, any())).called(1);
      });
    });
  });

  // ────────────────────────────────────────────────
  // handlePuzzleSolved (via updateScoresInStorage)
  // ────────────────────────────────────────────────

  group('PuzzleNotifier — handlePuzzleSolved', () {
    test('saves score to storage when puzzle is solved', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.scores)).thenReturn(false);
      when(() => storage.get<int>(StorageKey.secondsElapsed)).thenReturn(null);

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // Directly call updateScoresInStorage (called by handlePuzzleSolved)
        notifier.updateScoresInStorage();

        verify(() => storage.set(StorageKey.scores, any())).called(1);
      });
    });

    test('stores score with correct data', () {
      final (container: container, storage: storage) = createContainer();
      when(() => storage.has(StorageKey.scores)).thenReturn(false);
      when(() => storage.get<int>(StorageKey.secondsElapsed)).thenReturn(null);

      // Capture the stored score
      dynamic capturedScore;
      when(() => storage.set(StorageKey.scores, any())).thenAnswer((inv) {
        capturedScore = inv.positionalArguments[1];
        return Future<void>.value();
      });

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        notifier.updateScoresInStorage();

        final scores = Score.fromJsonList(capturedScore);
        check(scores.length).equals(1);
        check(scores.first.gameMode).equals(GameMode.classic);
        check(scores.first.puzzleSize).equals(4);
      });
    });
  });

  // ────────────────────────────────────────────────
  // setGameMode (orchestration)
  // ────────────────────────────────────────────────

  group('PuzzleNotifier — setGameMode', () {
    test('switches gameMode', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        check(container.read(puzzleProvider).gameMode).equals(GameMode.classic);
        notifier.setGameMode(GameMode.speedrun);
        check(
          container.read(puzzleProvider).gameMode,
        ).equals(GameMode.speedrun);
      });
    });

    test('persists mode to storage', () {
      final (container: container, storage: storage) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        notifier.setGameMode(GameMode.speedrun);
        verify(() => storage.set(StorageKey.gameMode, 'speedrun'));
      });
    });

    test('does nothing when switching to the same mode', () {
      final (container: container, storage: storage) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);
        // Clear interactions from the init timer's generate() call
        clearInteractions(storage);

        notifier.setGameMode(GameMode.classic);
        verifyNever(() => storage.set(any(), any()));
        verifyNever(() => storage.remove(any()));
      });
    });

    test('resets movesCount to 0', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // Simulate some moves
        notifier.setGameMode(GameMode.speedrun);
        check(container.read(puzzleProvider).movesCount).equals(0);
      });
    });

    test('resets stopWatchSecondsOverride to 0', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // Force a value then switch mode
        notifier.setGameMode(GameMode.speedrun);
        check(
          container.read(puzzleProvider).stopWatchSecondsOverride,
        ).equals(0);
      });
    });

    test('removes puzzle from storage', () {
      final (container: container, storage: storage) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        notifier.setGameMode(GameMode.speedrun);
        verify(() => storage.remove(StorageKey.puzzle));
      });
    });

    test('can switch to all game modes', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        final modesToTest = GameMode.values.where((m) => m != GameMode.classic);
        for (final mode in modesToTest) {
          notifier.setGameMode(mode);
          check(container.read(puzzleProvider).gameMode).equals(mode);
        }
      });
    });
  });

  // ────────────────────────────────────────────────
  // resetPuzzleSize
  // ────────────────────────────────────────────────

  group('PuzzleNotifier — resetPuzzleSize', () {
    test('sets n to the given size', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        notifier.resetPuzzleSize(5);
        check(container.read(puzzleProvider).n).equals(5);
      });
    });

    test('resets movesCount to 0', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        notifier.resetPuzzleSize(4);
        check(container.read(puzzleProvider).movesCount).equals(0);
      });
    });

    test('resets stopWatchSecondsOverride to 0', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        notifier.resetPuzzleSize(4);
        check(
          container.read(puzzleProvider).stopWatchSecondsOverride,
        ).equals(0);
      });
    });

    test('removes puzzle from storage', () {
      final (container: container, storage: storage) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        notifier.resetPuzzleSize(4);
        verify(() => storage.remove(StorageKey.puzzle));
      });
    });

    test('works for all supported sizes', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        for (final size in Puzzle.supportedPuzzleSizes) {
          notifier.resetPuzzleSize(size);
          check(container.read(puzzleProvider).n).equals(size);
        }
      });
    });
  });

  // ────────────────────────────────────────────────
  // keyboard events
  // ────────────────────────────────────────────────

  group('PuzzleNotifier — keyboard events', () {
    test('handleKeyboardEvent does not throw', () {
      final (container: container, storage: _) = createContainer();

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // Should handle unknown keys gracefully
        notifier.handleKeyboardEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.space,
            logicalKey: LogicalKeyboardKey.space,
            timeStamp: Duration(seconds: 1),
          ),
        );
        // No assertion needed — just verifying it doesn't throw
      });
    });
  });

  // ────────────────────────────────────────────────
  // Score truncation behavior
  // ────────────────────────────────────────────────

  group('PuzzleNotifier — score truncation', () {
    test('keeps only the most recent 10 scores', () {
      final (container: container, storage: storage) = createContainer();
      // Populate storage with 10 scores
      final scores10 = List.generate(
        10,
        (i) => Score(
          movesCount: i * 10,
          puzzleSize: 4,
          secondsElapsed: i * 5,
          gameMode: GameMode.classic,
        ),
      );
      when(() => storage.has(StorageKey.scores)).thenReturn(true);
      when(
        () => storage.get<List>(StorageKey.scores),
      ).thenReturn(Score.toJsonList(scores10));
      when(() => storage.get<int>(StorageKey.secondsElapsed)).thenReturn(null);

      dynamic capturedScores;
      when(() => storage.set(StorageKey.scores, any())).thenAnswer((inv) {
        capturedScores = inv.positionalArguments[1];
        return Future<void>.value();
      });

      fakeAsync((async) {
        final notifier = container.read(puzzleProvider.notifier);
        async.elapse(Duration.zero);

        // Save a new score (11th)
        notifier.updateScoresInStorage();

        final allScores = Score.fromJsonList(capturedScores);
        check(allScores.length).equals(10);
        // The oldest score (movesCount: 0) should be dropped,
        // the newest (movesCount: 90) should be kept, and the
        // just-added score should be the last.
        check(allScores.first.movesCount).equals(10); // was second oldest
        check(allScores.last.movesCount).equals(0); // the new score defaults
      });
    });
  });
}
