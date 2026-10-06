import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/domain/models/location.dart';
import 'package:leafz/domain/models/puzzle.dart';
import 'package:leafz/domain/models/score.dart';
import 'package:leafz/domain/models/tile.dart';
import 'package:leafz/helpers/game_mode_helper.dart';
import 'package:leafz/ui/core/animations/animations_manager.dart';
import 'package:leafz/data/services/storage_service.dart';
import 'package:leafz/ui/features/puzzle/view_models/game_mode_strategy.dart';
import 'package:leafz/ui/features/puzzle/view_models/classic_game_mode_strategy.dart';
import 'package:leafz/ui/features/puzzle/view_models/speedrun_game_mode_strategy.dart';
import 'package:leafz/ui/features/puzzle/view_models/blind_game_mode_strategy.dart';
import 'package:leafz/ui/features/puzzle/view_models/marathon_game_mode_strategy.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:math' show Random;

final storageServiceProvider = Provider<StorageService>((ref) {
  throw StateError(
    'StorageService not provided. '
    'Override with KConfigStorageService() in main.dart\'s ProviderScope.',
  );
});

// ────────────────────────────────────────────────────
// Puzzle state
// ────────────────────────────────────────────────────

@immutable
class PuzzleState {
  final int n;
  final List<Tile> tiles;
  final int movesCount;
  final GameMode gameMode;
  final List<Score> scores;
  final int stopWatchSecondsOverride;

  // Blind state
  final bool tilesBlinded;
  final Set<Location> blindRevealedTiles;

  // Marathon state
  final int? marathonStartSize;
  final int? marathonEndSize;
  final bool marathonRetried;

  const PuzzleState({
    this.n = 4,
    this.tiles = const [],
    this.movesCount = 0,
    this.gameMode = GameMode.classic,
    this.scores = const [],
    this.stopWatchSecondsOverride = 0,
    this.tilesBlinded = false,
    this.blindRevealedTiles = const {},
    this.marathonStartSize,
    this.marathonEndSize,
    this.marathonRetried = false,
  });

  Puzzle get puzzle => Puzzle(n: n, tiles: tiles, movesCount: movesCount);

  List<Tile> get tilesWithoutWhitespace =>
      tiles.where((t) => !t.tileIsWhiteSpace).toList(growable: false);

  int get correctTilesCount =>
      tiles.where((t) => t.isAtCorrectLocation && !t.tileIsWhiteSpace).length;

  bool get hasStarted => movesCount > 0;

  bool get isMarathonComplete => switch ((gameMode, marathonEndSize)) {
    (GameMode.marathon, final end?) => n >= end,
    _ => false,
  };

  bool get isModeLocked => movesCount > 0;

  int get speedrunCountdownSeconds =>
      GameModeHelper.speedrunCountdownSeconds(n);

  bool isTileRevealed(Location location) =>
      blindRevealedTiles.contains(location);

  PuzzleState copyWith({
    int? n,
    List<Tile>? tiles,
    int? movesCount,
    GameMode? gameMode,
    List<Score>? scores,
    int? stopWatchSecondsOverride,
    bool? tilesBlinded,
    Set<Location>? blindRevealedTiles,
    int? marathonStartSize,
    int? marathonEndSize,
    bool? marathonRetried,
  }) {
    return PuzzleState(
      n: n ?? this.n,
      tiles: tiles ?? this.tiles,
      movesCount: movesCount ?? this.movesCount,
      gameMode: gameMode ?? this.gameMode,
      scores: scores ?? this.scores,
      stopWatchSecondsOverride:
          stopWatchSecondsOverride ?? this.stopWatchSecondsOverride,
      tilesBlinded: tilesBlinded ?? this.tilesBlinded,
      blindRevealedTiles: blindRevealedTiles ?? this.blindRevealedTiles,
      marathonStartSize: marathonStartSize ?? this.marathonStartSize,
      marathonEndSize: marathonEndSize ?? this.marathonEndSize,
      marathonRetried: marathonRetried ?? this.marathonRetried,
    );
  }
}

// ────────────────────────────────────────────────────
// Puzzle notifier
// ────────────────────────────────────────────────────

class PuzzleNotifier extends Notifier<PuzzleState>
    implements GameModeStrategyHost {
  final Random _random = Random();
  Timer? _blindTimer;
  late final Map<GameMode, GameModeStrategy> _strategies;

  /// Cached storage service — accessing [ref] inside [ref.onDispose] is
  /// unsafe because Riverpod prohibits reading other providers during
  /// life-cycles. Cache it once in [build] and reuse everywhere.
  late final StorageService _storageService;

  // ── GameModeStrategyHost ──

  @override
  GameMode get gameMode => state.gameMode;

  @override
  int get n => state.n;

  @override
  set n(int v) => _emit(state.copyWith(n: v));

  @override
  int get movesCount => state.movesCount;

  @override
  set movesCount(int v) => _emit(state.copyWith(movesCount: v));

  @override
  int get stopWatchSecondsOverride => state.stopWatchSecondsOverride;

  @override
  set stopWatchSecondsOverride(int v) =>
      _emit(state.copyWith(stopWatchSecondsOverride: v));

  @override
  StorageService get storageService => _storageService;

  @override
  void notifyListeners() {} // state reassignment triggers Riverpod rebuilds

  // ── Build ──

  @override
  PuzzleState build() {
    _strategies = {
      GameMode.classic: ClassicGameModeStrategy(),
      GameMode.speedrun: SpeedrunGameModeStrategy(),
      GameMode.blind: BlindGameModeStrategy(),
      GameMode.marathon: MarathonGameModeStrategy(),
    };
    _storageService = ref.read(storageServiceProvider);
    ref.onDispose(() {
      _blindTimer?.cancel();
      // Deactivate only the active strategy — iterating all strategies
      // during onDispose can trigger Riverpod lifecycle assertions when
      // strategies access host storage.
      try {
        _strategies[state.gameMode]?.onDeactivate(this);
      } catch (_) {}
    });

    final initialMode = switch (_storageService.get<String>(
      StorageKey.gameMode,
    )) {
      String name => GameMode.values.byName(name),
      _ => GameMode.classic,
    };
    _strategies[initialMode]!.onActivate(this);

    final savedScores = _getScoresFromStorage();

    final storedPuzzle = _getPuzzleFromStorage();
    if (storedPuzzle != null) {
      return PuzzleState(
        gameMode: initialMode,
        tiles: storedPuzzle.tiles,
        n: storedPuzzle.n,
        movesCount: storedPuzzle.movesCount,
        scores: savedScores,
      );
    }

    return _initializePuzzle(initialMode, savedScores);
  }

  PuzzleState _initializePuzzle(GameMode initialMode, List<Score> savedScores) {
    final tiles = Puzzle.generateSolvableTiles(4, _random);

    updatePuzzleInStorage();
    _strategies[initialMode]!.onPuzzleGenerated(this);

    return PuzzleState(
      gameMode: initialMode,
      tiles: tiles,
      scores: savedScores,
    );
  }

  void _emit(PuzzleState next) {
    state = next;
  }

  // ── Score storage helpers ──

  @override
  void updateScoresInStorage() {
    final storage = _storageService;
    final seconds = switch (state.stopWatchSecondsOverride) {
      > 0 => state.stopWatchSecondsOverride,
      _ => storage.get<int>(StorageKey.secondsElapsed) ?? 0,
    };
    final newScore = Score(
      movesCount: state.movesCount,
      puzzleSize: state.n,
      secondsElapsed: seconds,
      gameMode: state.gameMode,
      timestamp: DateTime.now(),
    );
    try {
      final savedScores = _getScoresFromStorage();
      // Sort by timestamp ascending (oldest first), then keep the 10 most
      // recent. Pre-migration scores with null timestamp are treated as
      // the oldest via [DateTime(0)] and get dropped first.
      final sorted = [...savedScores, newScore]
        ..sort(
          (a, b) => (a.timestamp ?? DateTime(0)).compareTo(
            b.timestamp ?? DateTime(0),
          ),
        );
      final scores = sorted.length > 10
          ? sorted.sublist(sorted.length - 10)
          : sorted;
      _emit(state.copyWith(scores: scores));
      storage.set(StorageKey.scores, Score.toJsonList(scores));
    } catch (e) {
      storage.remove(StorageKey.scores);
      log('Error updating scores in storage $e');
    }
  }

  List<Score> _getScoresFromStorage() {
    try {
      final data = _storageService.get<List>(StorageKey.scores);
      if (data != null) return Score.fromJsonList(data);
    } catch (e) {
      log('Error retrieving scores from storage');
      log('$e');
    }
    return [];
  }

  @override
  void updatePuzzleInStorage() {
    try {
      _storageService.set(StorageKey.puzzle, state.puzzle.toJson());
    } catch (e) {
      log('Error updating puzzle in storage');
      log('$e');
    }
  }

  Puzzle? _getPuzzleFromStorage() {
    try {
      final data = _storageService.get<Map>(StorageKey.puzzle);
      if (data == null) return null;
      return Puzzle.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      log('Error in local storage, clearing data...');
      _storageService.clear();
      return null;
    }
  }

  // ── Core puzzle logic ──

  void swapTilesAndUpdatePuzzle(Tile tile) {
    final swapped = _swappedTiles(tile);
    if (swapped == null) return;

    final isSolved = Puzzle(
      n: state.n,
      tiles: swapped,
      movesCount: state.movesCount + 1,
    ).isSolved;
    // Values are unique, so the moved tile is identified by value —
    // locations have already been swapped at this point.
    final movedTile = swapped.firstWhere((t) => t.value == tile.value);
    _announceMove(movedTile: movedTile, isSolved: isSolved, tiles: swapped);

    _emit(state.copyWith(tiles: swapped, movesCount: state.movesCount + 1));
    _strategies[state.gameMode]!.onTileMoved(this);
    updatePuzzleInStorage();
  }

  /// Returns a copy of [state.tiles] with [tile] and the whitespace
  /// swapped, or `null` when either tile cannot be located.
  List<Tile>? _swappedTiles(Tile tile) {
    final tiles = List<Tile>.of(state.tiles);
    final movedIdx = tiles.indexWhere(
      (ct) => ct.currentLocation == tile.currentLocation,
    );
    final wsIdx = tiles.indexWhere((t) => t.tileIsWhiteSpace);
    if (movedIdx == -1 || wsIdx == -1) return null;

    final moved = tiles[movedIdx];
    final ws = tiles[wsIdx];
    tiles[movedIdx] = moved.copyWith(currentLocation: ws.currentLocation);
    tiles[wsIdx] = ws.copyWith(currentLocation: moved.currentLocation);
    return tiles;
  }

  /// Haptic feedback for a move: vibrate on solve, medium impact when the
  /// moved tile lands correctly, silent otherwise.
  void _announceMove({
    required Tile movedTile,
    required bool isSolved,
    required List<Tile> tiles,
  }) {
    if (!movedTile.isAtCorrectLocation) return;
    if (isSolved) {
      HapticFeedback.vibrate();
      _handlePuzzleSolved(tiles);
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void generate({bool forceRefresh = false}) {
    final storage = _storageService;
    if (storage.has(StorageKey.scores)) {
      final saved = _getScoresFromStorage();
      if (saved.isNotEmpty) _emit(state.copyWith(scores: saved));
    }
    if (storage.has(StorageKey.puzzle) && !forceRefresh) {
      final stored = _getPuzzleFromStorage();
      if (stored != null) {
        _emit(
          state.copyWith(
            tiles: stored.tiles,
            n: stored.n,
            movesCount: stored.movesCount,
          ),
        );
        return;
      }
    }
    _generateNew();
    updatePuzzleInStorage();
    _strategies[state.gameMode]!.onPuzzleGenerated(this);
  }

  void _generateNew() {
    final tiles = Puzzle.generateSolvableTiles(state.n, _random);

    _emit(
      state.copyWith(tiles: tiles, movesCount: 0, stopWatchSecondsOverride: 0),
    );
  }

  void _handlePuzzleSolved(List<Tile> tiles) {
    updateScoresInStorage();
    _strategies[state.gameMode]!.onPuzzleSolved(this);
  }

  // ── Keyboard ──

  void handleKeyboardEvent(KeyEvent event) {
    if (event case KeyDownEvent(:var physicalKey)) {
      final tile = switch (physicalKey) {
        PhysicalKeyboardKey.arrowDown => state.puzzle.tileTopOfWhitespace,
        PhysicalKeyboardKey.arrowUp => state.puzzle.tileBottomOfWhitespace,
        PhysicalKeyboardKey.arrowLeft => state.puzzle.tileRightOfWhitespace,
        PhysicalKeyboardKey.arrowRight => state.puzzle.tileLeftOfWhitespace,
        _ => null,
      };
      if (tile case var t?) swapTilesAndUpdatePuzzle(t);
    }
  }

  // ── Game mode switching ──

  void setGameMode(GameMode mode) {
    if (state.gameMode == mode) return;
    final old = _strategies[state.gameMode]!;
    old.onDeactivate(this);
    _emit(
      state.copyWith(
        gameMode: mode,
        movesCount: 0,
        stopWatchSecondsOverride: 0,
      ),
    );
    _storageService.set(StorageKey.gameMode, mode.name);
    _storageService.remove(StorageKey.puzzle);
    generate(forceRefresh: true);
    _strategies[mode]!.onActivate(this);
  }

  void resetPuzzleSize(int size) {
    assert(Puzzle.supportedPuzzleSizes.contains(size));
    _emit(state.copyWith(n: size, movesCount: 0, stopWatchSecondsOverride: 0));
    _storageService.remove(StorageKey.puzzle);
    generate(forceRefresh: true);
  }

  // ── Blind mode timer ──

  void startBlindTimer() {
    _blindTimer?.cancel();
    final delay = GameModeHelper.blindHideDelaySeconds(state.n);
    _blindTimer = Timer(Duration(seconds: delay), () {
      _emit(state.copyWith(tilesBlinded: true, blindRevealedTiles: const {}));
    });
  }

  void revealBlindTile(Location location) {
    if (!state.tilesBlinded) return;
    final revealed = {...state.blindRevealedTiles, location};
    _emit(state.copyWith(blindRevealedTiles: revealed));
    Future.delayed(AnimationsManager.blindRevealAutoHide, () {
      final nextRevealed = Set<Location>.from(state.blindRevealedTiles)
        ..remove(location);
      _emit(state.copyWith(blindRevealedTiles: nextRevealed));
    });
  }

  void resetBlindState() {
    _blindTimer?.cancel();
    _blindTimer = null;
    _emit(state.copyWith(tilesBlinded: false, blindRevealedTiles: const {}));
  }

  // ── Marathon mode helpers ──

  void setMarathonRange(int start, int end) {
    _emit(state.copyWith(marathonStartSize: start, marathonEndSize: end));
    _storageService.set(StorageKey.marathonStartSize, start);
    _storageService.set(StorageKey.marathonEndSize, end);
  }

  void resetMarathonState() {
    _emit(
      state.copyWith(
        marathonStartSize: null,
        marathonEndSize: null,
        marathonRetried: false,
      ),
    );
    if (state.gameMode != GameMode.marathon) {
      _storageService.remove(StorageKey.marathonStartSize);
      _storageService.remove(StorageKey.marathonEndSize);
    }
  }

  void readyMarathonAdvance() {}

  void advanceMarathonSize() {
    final sizes = Puzzle.supportedPuzzleSizes;
    final idx = sizes.indexOf(state.n);
    final endSize = state.marathonEndSize;
    if (idx < sizes.length - 1 && (endSize == null || state.n < endSize)) {
      _emit(
        state.copyWith(
          n: sizes[idx + 1],
          movesCount: 0,
          stopWatchSecondsOverride: 0,
        ),
      );
      _storageService.remove(StorageKey.puzzle);
      generate(forceRefresh: true);
    }
  }
}

final puzzleProvider = NotifierProvider<PuzzleNotifier, PuzzleState>(
  PuzzleNotifier.new,
);
