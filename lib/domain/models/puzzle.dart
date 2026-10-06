import 'package:leafz/domain/models/location.dart';
import 'package:leafz/domain/models/tile.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'dart:math' show Random;

/// Model for a Puzzle
class Puzzle extends Equatable {
  final int n;
  final List<Tile> tiles;
  final int movesCount;

  /// Cached index of the whitespace tile to avoid O(n) scans on repeated
  /// lookups from [whiteSpaceTile], [tileIsMovable], and directional checks.
  final int _whitespaceTileIndex;

  Puzzle({
    required this.n,
    required this.tiles,
    this.movesCount = 0,
    int? whitespaceTileIndex,
  }) : _whitespaceTileIndex =
           whitespaceTileIndex ??
           tiles.lastIndexWhere((tile) => tile.tileIsWhiteSpace);

  /// List of supported puzzle sizes
  static List<int> supportedPuzzleSizes = [3, 4, 5, 6];

  /// Get whitespace tile
  Tile get whiteSpaceTile => tiles[_whitespaceTileIndex];

  /// Check if a [Tile] is movable
  ///
  /// A tile if movable if it's not a whitespace tile
  /// and if it's located around the whitespace tile
  /// (top of, bottom of, right of, or left of)
  bool tileIsMovable(Tile tile) {
    if (tile.tileIsWhiteSpace) {
      return false;
    }
    return tile.currentLocation.isLocatedAround(whiteSpaceTile.currentLocation);
  }

  /// Check if a tile is left of the whitespace tile
  bool tileIsLeftOfWhiteSpace(Tile tile) {
    return tile.currentLocation.isLeftOf(whiteSpaceTile.currentLocation);
  }

  /// Check if a tile is right of the whitespace tile
  bool tileIsRightOfWhiteSpace(Tile tile) {
    return tile.currentLocation.isRightOf(whiteSpaceTile.currentLocation);
  }

  /// Check if a tile is top of the whitespace tile
  bool tileIsTopOfWhiteSpace(Tile tile) {
    return tile.currentLocation.isTopOf(whiteSpaceTile.currentLocation);
  }

  /// Check if a tile is bottom of the whitespace tile
  bool tileIsBottomOfWhiteSpace(Tile tile) {
    return tile.currentLocation.isBottomOf(whiteSpaceTile.currentLocation);
  }

  /// Returns the tile at the top of the whitespace tile
  Tile? get tileTopOfWhitespace =>
      tiles.firstWhereOrNull((tile) => tileIsTopOfWhiteSpace(tile));

  /// Returns the tile at the bottom of the whitespace tile
  Tile? get tileBottomOfWhitespace =>
      tiles.firstWhereOrNull((tile) => tileIsBottomOfWhiteSpace(tile));

  /// Returns the tile at the right of the whitespace tile
  Tile? get tileRightOfWhitespace =>
      tiles.firstWhereOrNull((tile) => tileIsRightOfWhiteSpace(tile));

  /// Returns the tile at the left of the whitespace tile
  Tile? get tileLeftOfWhitespace =>
      tiles.firstWhereOrNull((tile) => tileIsLeftOfWhiteSpace(tile));

  /// Given a puzzle size, generate a list of tile [Location]s
  ///
  /// For example, for a 3x3 puzzle, generated correct locations will be:
  /// | 1,1 | 2,1 | 3, 1 |
  /// | 1,2 | 2,2 | 3, 2 |
  /// | 1,3 | 2,3 | 3, 3 |
  static List<Location> generateTileCorrectLocations(int n) {
    List<Location> tilesCorrectLocations = [];
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        Location location = Location(y: i + 1, x: j + 1);
        tilesCorrectLocations.add(location);
      }
    }
    return tilesCorrectLocations;
  }

  /// Returns a list of tiles from current & correct locations lists
  static List<Tile> getTilesFromLocations({
    required List<Location> correctLocations,
    required List<Location> currentLocations,
  }) {
    return List.generate(
      correctLocations.length,
      (i) => Tile(
        value: i + 1,
        correctLocation: correctLocations[i],
        currentLocation: currentLocations[i],
        tileIsWhiteSpace: i == correctLocations.length - 1,
      ),
    );
  }

  /// Generates a shuffled, solvable board for size [n] with zero tiles
  /// in their correct positions (so the puzzle never starts solved).
  ///
  /// Single source of truth for board generation — replaces the duplicated
  /// shuffle-until-solvable loops formerly in `PuzzleNotifier`.
  static List<Tile> generateSolvableTiles(int n, Random random) {
    final correctLocations = generateTileCorrectLocations(n);
    var currentLocations = List<Location>.from(correctLocations)
      ..shuffle(random);
    var tiles = getTilesFromLocations(
      correctLocations: correctLocations,
      currentLocations: currentLocations,
    );
    var puzzle = Puzzle(n: n, tiles: tiles, movesCount: 0);
    while (!puzzle.isSolvable() || puzzle.getNumberOfCorrectTiles() != 0) {
      currentLocations = List<Location>.from(correctLocations)..shuffle(random);
      tiles = getTilesFromLocations(
        correctLocations: correctLocations,
        currentLocations: currentLocations,
      );
      puzzle = Puzzle(n: n, tiles: tiles, movesCount: 0);
    }
    return tiles;
  }

  /// Gives the number of inversions in a puzzle given its tile arrangement.
  ///
  /// An inversion is when a tile of a lower value is in a greater position than
  /// a tile of a higher value.
  int countInversions() {
    // 2x2 or smaller has no inversions
    if (tiles.length < 4) return 0;

    var count = 0;
    final len = tiles.length;
    for (var a = 0; a < len; a++) {
      if (a == _whitespaceTileIndex) continue;
      final tileA = tiles[a];

      for (var b = a + 1; b < len; b++) {
        if (b == _whitespaceTileIndex) continue;
        final tileB = tiles[b];
        if (tileA.value == tileB.value) continue;
        final lowerValue = tileA.value < tileB.value ? tileA : tileB;
        final higherValue = tileA.value < tileB.value ? tileB : tileA;
        if (lowerValue.currentLocation.compareTo(higherValue.currentLocation) >
            0) {
          count++;
        }
      }
    }
    return count;
  }

  /// Determines if the puzzle is solvable.
  bool isSolvable() {
    final height = tiles.length ~/ n;
    assert(n * height == tiles.length, 'tiles must be equal to n * height');
    final inversions = countInversions();

    if (n.isOdd) {
      return inversions.isEven;
    }

    final whitespaceRow = tiles[_whitespaceTileIndex].currentLocation.y;

    return ((height - whitespaceRow) + 1).isOdd
        ? inversions.isEven
        : inversions.isOdd;
  }

  bool get isSolved => getNumberOfCorrectTiles() == tiles.length - 1;

  /// Gets the number of tiles that are currently in their correct position.
  int getNumberOfCorrectTiles() {
    var numberOfCorrectTiles = 0;
    for (final tile in tiles) {
      if (!tile.tileIsWhiteSpace) {
        if (tile.currentLocation == tile.correctLocation) {
          numberOfCorrectTiles++;
        }
      }
    }
    return numberOfCorrectTiles;
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'n': int n, 'tiles': List<dynamic> rawTiles} => Puzzle(
        tiles: rawTiles.map((x) => Tile.fromJson(x)).toList(growable: false),
        movesCount: json['movesCount'] ?? 0,
        n: n,
      ),
      _ => throw const FormatException('Invalid puzzle JSON'),
    };
  }

  Map<String, dynamic> toJson() => {
    'tiles': List<dynamic>.from(tiles.map((x) => x.toJson())),
    'movesCount': movesCount,
    'n': n,
  };

  @override
  List<Object?> get props => [n, movesCount, tiles];
}
