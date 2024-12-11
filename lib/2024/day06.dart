import 'package:advent_of_code/utils.dart';

enum Direction {
  up(0, -1),
  right(1, 0),
  down(0, 1),
  left(-1, 0);

  final int xOffset;
  final int yOffset;

  const Direction(this.xOffset, this.yOffset);

  Direction turnClockwise() {
    switch (this) {
      case up:
        return Direction.right;
      case right:
        return Direction.down;
      case down:
        return Direction.left;
      case left:
        return Direction.up;
    }
  }

  Position getNextPosition(Position currentPosition) {
    return (currentPosition.$1 + xOffset, currentPosition.$2 + yOffset);
  }

  @override
  String toString() {
    switch (this) {
      case up:
        return "^";
      case right:
        return ">";
      case down:
        return "v";
      case left:
        return "<";
    }
  }

  static Direction parse(String input) {
    switch (input) {
      case "^":
        return Direction.up;

      case ">":
        return Direction.right;

      case "v":
        return Direction.down;

      case "<":
        return Direction.left;

      default:
        throw Exception("Unknown guard direction character: $input");
    }
  }
}

typedef Position = (int, int);
typedef WalkedPosition = (Position, Direction);

class Grid {
  final List<List<bool>> tiles;

  Position guardPosition;

  Direction guardDirection;

  Grid(this.tiles, this.guardPosition, this.guardDirection);

  Set<Position> walkGuard() {
    final walkedPositions = <Position>{guardPosition};

    while (true) {
      final nextPosition = guardDirection.getNextPosition(guardPosition);
      final isWalkable = tiles
          .elementAtOrNull(nextPosition.$2)
          ?.elementAtOrNull(nextPosition.$1);

      if (isWalkable == null) {
        break;
      }

      if (isWalkable == false) {
        guardDirection = guardDirection.turnClockwise();
        continue;
      }

      walkedPositions.add(nextPosition);
      guardPosition = nextPosition;
    }

    return walkedPositions;
  }

  bool canMoveOutOfGrid(
    Position initialGuardPosition,
    Direction initialGuardDirection,
    Position obstacleAtPosition,
  ) {
    guardPosition = initialGuardPosition;
    guardDirection = initialGuardDirection;

    final walkedPositions = <WalkedPosition>{};
    tiles[obstacleAtPosition.$2][obstacleAtPosition.$1] = false;

    while (true) {
      final nextPosition = guardDirection.getNextPosition(guardPosition);

      if (nextPosition.$1 < 0 || nextPosition.$2 < 0) {
        break;
      }

      final isWalkable = tiles
          .elementAtOrNull(nextPosition.$2)
          ?.elementAtOrNull(nextPosition.$1);

      if (isWalkable == null) {
        break;
      }

      if (walkedPositions.contains((guardPosition, guardDirection))) {
        tiles[obstacleAtPosition.$2][obstacleAtPosition.$1] = true;
        return false;
      }

      if (isWalkable == false) {
        guardDirection = guardDirection.turnClockwise();
        continue;
      }

      walkedPositions.add((guardPosition, guardDirection));
      guardPosition = nextPosition;
    }

    tiles[obstacleAtPosition.$2][obstacleAtPosition.$1] = true;
    return true;
  }

  @override
  String toString() {
    return 'Grid{tiles: $tiles, guardPosition: $guardPosition, guardDirection: $guardDirection}';
  }

  static Grid parseInput(String input) {
    final lines = input.split("\n");
    final rows = lines.map((line) => line.split("").toList()).toList();

    final tiles = <List<bool>>[];
    Position? guardPosition;
    Direction? guardDirection;

    for (var y = 0; y < rows.length; y++) {
      final currentRow = rows[y];
      final resultRow = <bool>[];

      for (var x = 0; x < currentRow.length; x++) {
        switch (currentRow[x]) {
          case ".":
            resultRow.add(true);
            break;

          case "#":
            resultRow.add(false);
            break;

          case var currentCharacter:
            guardPosition = (x, y);
            guardDirection = Direction.parse(currentCharacter);
            resultRow.add(true);
            break;
        }
      }

      tiles.add(resultRow);
    }

    if (guardPosition == null || guardDirection == null) {
      throw Exception("Could not find guard position or direction");
    }

    return Grid(tiles, guardPosition, guardDirection);
  }
}

void part1() {
  final fileContents = readInputFile(2024, 6, "input");
  final grid = Grid.parseInput(fileContents);
  final walkedPath = grid.walkGuard();

  print(walkedPath.length);
}

void part2() {
  final fileContents = readInputFile(2024, 6, "input");

  final grid = Grid.parseInput(fileContents);
  final initialGuardDirection = grid.guardDirection;
  final initialGuardPosition = grid.guardPosition;

  final walkedPath = grid.walkGuard();
  final positionsToPutObstacleOn = walkedPath
      .expand((position) => [
            Direction.up.getNextPosition(position),
            Direction.right.getNextPosition(position),
            Direction.down.getNextPosition(position),
            Direction.left.getNextPosition(position),
            position,
          ])
      .toSet()
      .where((position) =>
          grid.tiles
              .elementAtOrNull(position.$2)
              ?.elementAtOrNull(position.$1) ==
          true)
      .toList();

  positionsToPutObstacleOn.sort((a, b) => a.$2.compareTo(b.$2));

  final positionsWhereGuardCannotMoveOut =
      positionsToPutObstacleOn.where((position) {
    print("Checking obstacle position: $position");

    return grid.canMoveOutOfGrid(
          initialGuardPosition,
          initialGuardDirection,
          position,
        ) ==
        false;
  });
  final uniquePositions = positionsWhereGuardCannotMoveOut.toSet();

  print("Result: ${uniquePositions.length}");
}
