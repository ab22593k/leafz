import 'package:leafz/domain/models/game_mode.dart';
import 'package:leafz/domain/models/score.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';

void main() {
  group('Score model', () {
    test('fromJson/toJson round-trip with all fields', () {
      final json = {
        'secondsElapsed': 120,
        'movesCount': 42,
        'puzzleSize': 4,
        'gameMode': 'speedrun',
        'timestamp': 1700000000000,
      };
      final score = Score.fromJson(json);
      check(score.toJson()).deepEquals(json);
    });

    test('fromJson defaults missing gameMode to classic', () {
      final json = {'secondsElapsed': 0, 'movesCount': 0, 'puzzleSize': 3};
      final score = Score.fromJson(json);
      check(score.gameMode).equals(GameMode.classic);
    });

    test('fromJson handles null timestamp', () {
      final json = {
        'secondsElapsed': 0,
        'movesCount': 0,
        'puzzleSize': 3,
        'gameMode': 'classic',
        'timestamp': null,
      };
      final score = Score.fromJson(json);
      check(score.timestamp).isNull();
    });

    test('toJson omits null timestamp', () {
      const score = Score(secondsElapsed: 0, movesCount: 0, puzzleSize: 3);
      check(score.toJson().containsKey('timestamp')).isFalse();
    });

    test('toJsonList / fromJsonList round-trip', () {
      final scores = [
        const Score(secondsElapsed: 10, movesCount: 5, puzzleSize: 3),
        const Score(secondsElapsed: 20, movesCount: 8, puzzleSize: 4),
      ];
      final jsonList = Score.toJsonList(scores);
      final restored = Score.fromJsonList(jsonList);
      check(restored).length.equals(2);
      check(restored.first.secondsElapsed).equals(10);
    });
  });
}
