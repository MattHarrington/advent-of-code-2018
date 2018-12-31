// https://adventofcode.com/2018/day/15

import 'dart:io';
import 'dart:collection';
import 'package:quiver/core.dart';

const USE_SAMPLE_DATA = false;
const PART_ONE = false;
var units = List<Unit>();

abstract class Unit {
  static int comparePositions(Unit a, Unit b) {
    int value;
    if (a.x == b.x && a.y == b.y)
      value = 0;
    else if (a.y < b.y)
      value = -1;
    else if (a.y > b.y)
      value = 1;
    else if (a.y == b.y) {
      if (a.x < b.x)
        value = -1;
      else if (a.x > b.x) value = 1;
    }
    return value;
  }

  static int compareHitPoints(Unit a, Unit b) {
    int value;
    // If tied hitPoints, sort by reading order
    if (a.hitPoints == b.hitPoints) {
      if (a.x == b.x && a.y == b.y)
        value = 0;
      else if (a.y < b.y)
        value = -1;
      else if (a.y > b.y)
        value = 1;
      else if (a.y == b.y) {
        if (a.x < b.x)
          value = -1;
        else if (a.x > b.x) value = 1;
      }
    } else if (a.hitPoints < b.hitPoints)
      value = -1;
    else if (a.hitPoints > b.hitPoints) value = 1;
    return value;
  }

  var _attackPower = 3;
  var hitPoints = 200;
  int x, y;
  var alive = true;

  Unit(this.x, this.y);

  void attack(Unit target) {
    target.hitPoints -= _attackPower;
    if (target.hitPoints <= 0) target.alive = false;
  }

  @override
  toString() => '$runtimeType ($x,$y)';
}

class Elf extends Unit {
  Elf(int x, int y) : super(x, y) {
    if (!PART_ONE) _attackPower = 19;
  }
}

class Goblin extends Unit {
  Goblin(int x, int y) : super(x, y);
}

class Point extends Comparable<Point> {
  int x, y;
  int distance;

  Point(this.x, this.y, {this.distance = null});

  @override
  bool operator ==(o) => o is Point && x == o.x && y == o.y;

  @override
  int get hashCode => hash3(x.hashCode, y.hashCode, distance.hashCode);

  @override
  toString() => "($x,$y)";

  @override

  /// Compare distances. If tied, then compare reading order.
  int compareTo(Point other) {
    int value;
    if (distance == other.distance) {
      if (x == other.x && y == other.y)
        value = 0;
      else if (y < other.y)
        value = -1;
      else if (y > other.y)
        value = 1;
      else if (y == other.y) {
        if (x < other.x)
          value = -1;
        else if (x > other.x) value = 1;
      }
    } else if (distance < other.distance)
      value = -1;
    else if (distance > other.distance) value = 1;
    return value;
  }
}

main() {
  var grid = getStartingGrid();
  int round = 0;
  var gameOn = true;

  while (gameOn) {
    print('After $round rounds:');
    printGrid(grid);
    units.sort(Unit.comparePositions); // Sorts according to reading order
    for (var player in units.where((u) => u.alive)) {
      // Game over if no more targets
      if (units
          .where((u) => u.alive && player.runtimeType != u.runtimeType)
          .isEmpty) {
        gameOn = false;
        break;
      }

      var nextGrid = copyGrid(grid);
      var potentialTargetsToAttack = List<Unit>();
      var potentialSquaresToMoveTo = List<Point>();

      for (var target in units
          .where((u) => u.alive && player.runtimeType != u.runtimeType)) {
        // Identify open squares in range of each target
        var openSquares =
            getOpenSquaresInRange(player, Point(target.x, target.y), grid);
        if (openSquares.contains(Point(player.x, player.y))) {
          // Already in range to attack
          potentialTargetsToAttack.add(target);
        } else {
          // Not in range to attack
          potentialSquaresToMoveTo.addAll(openSquares);
        }
      }

      // If potential targets, attack target with lowest HP
      if (potentialTargetsToAttack.isNotEmpty) {
        potentialTargetsToAttack.sort(Unit.compareHitPoints);
        var attackedTarget = potentialTargetsToAttack.first;
        player.attack(attackedTarget);
        if (!attackedTarget.alive)
          nextGrid[attackedTarget.y][attackedTarget.x] = '.';
        grid = nextGrid;
        continue; // Go to next player
      }

      // No potential targets, so move
      if (potentialSquaresToMoveTo.isNotEmpty) {
        for (var destination in potentialSquaresToMoveTo) {
          destination.distance =
              shortestDistance(Point(player.x, player.y), destination, grid);
        }
        potentialSquaresToMoveTo.removeWhere(
            (square) => square.distance == null); // Remove unreachable squares
        if (potentialSquaresToMoveTo.isNotEmpty) {
          potentialSquaresToMoveTo.sort();
          var destination = potentialSquaresToMoveTo.first;
          move(player, destination, nextGrid);
        }
      }

      // Then attack
      for (var target in units
          .where((u) => u.alive && player.runtimeType != u.runtimeType)) {
        // Identify open squares in range of each target
        var openSquares =
            getOpenSquaresInRange(player, Point(target.x, target.y), nextGrid);
        if (openSquares.contains(Point(player.x, player.y))) {
          // Already in range to attack
          potentialTargetsToAttack.add(target);
        } else {}
      }
      // Attack target with lowest HP
      if (potentialTargetsToAttack.isNotEmpty) {
        potentialTargetsToAttack.sort(Unit.compareHitPoints);
        var attackedTarget = potentialTargetsToAttack.first;
        player.attack(attackedTarget);
        if (!attackedTarget.alive)
          nextGrid[attackedTarget.y][attackedTarget.x] = '.';
      }
      grid = nextGrid;
    } // player's turn is over

    ++round;
  }

  // Loop ends in middle of round.
  // Puzzle calls for last completed round.
  round = round - 1;
  print('Round: ${round}');

  var hitPointSum = 0;
  Type winner;
  for (var unit in units.where((u) => u.alive)) {
    hitPointSum += unit.hitPoints;
    winner = unit.runtimeType;
  }

  print('hitPointSum: $hitPointSum');
  print('round * hitPointSum = ${round * hitPointSum}');
  print('winner: $winner');
  var anyWinnersDie =
      units.any((u) => u.runtimeType == winner && u.alive == false);
  print('anyWinnersDie: $anyWinnersDie');

  if (PART_ONE && !USE_SAMPLE_DATA) assert(round * hitPointSum == 269430);
  if (!PART_ONE && !USE_SAMPLE_DATA)
    assert(round * hitPointSum == 55160 && !anyWinnersDie);
}

/// Move unit one step towards target
void move(Unit start, Point target, List<List<String>> nextGrid) {
  final rows = nextGrid.length;
  final columns = nextGrid.first.length;
  var destinations = List<Point>();

  // Up
  if (start.y > 0 && nextGrid[start.y - 1][start.x] == '.') {
    destinations.add(Point(start.x, start.y - 1,
        distance:
            shortestDistance(Point(start.x, start.y - 1), target, nextGrid)));
  }
  // Down
  if (start.y < columns - 1 && nextGrid[start.y + 1][start.x] == '.') {
    destinations.add(Point(start.x, start.y + 1,
        distance:
            shortestDistance(Point(start.x, start.y + 1), target, nextGrid)));
  }
  // Left
  if (start.x > 0 && nextGrid[start.y][start.x - 1] == '.') {
    destinations.add(Point(start.x - 1, start.y,
        distance:
            shortestDistance(Point(start.x - 1, start.y), target, nextGrid)));
  }
  // Right
  if (start.x < rows - 1 && nextGrid[start.y][start.x + 1] == '.') {
    destinations.add(Point(start.x + 1, start.y,
        distance:
            shortestDistance(Point(start.x + 1, start.y), target, nextGrid)));
  }

  destinations.removeWhere((p) => p.distance == null); // Unreachable dest.
  destinations.sort();
  var destination = destinations.first;
  var originalUnit = nextGrid[start.y][start.x];
  nextGrid[start.y][start.x] = '.';
  nextGrid[destination.y][destination.x] = originalUnit;
  start.x = destination.x;
  start.y = destination.y;
}

/// Return shortest distance between 2 points on a Cartesian grid
/// with obstacles. BFS approach based on:
/// https://stackoverflow.com/questions/37784324/shortest-path-in-a-grid
/// https://www.geeksforgeeks.org/shortest-distance-two-cells-matrix-grid/
int shortestDistance(Point start, Point end, List<List<String>> grid) {
  final originalEndUnitType = grid[end.y][end.x];
  grid[end.y][end.x] = '.';
  final rows = grid.length;
  final columns = grid.first.length;
  var visited = List.generate(rows, (_) => List<bool>.filled(columns, false));
  var distances = List.generate(rows, (_) => List<int>.filled(columns, 0));
  int distance;

  var queue = Queue<Point>();
  queue.addFirst(start);

  while (queue.isNotEmpty) {
    var p = queue.removeLast();
    if (p == end) {
      distance = distances[p.y][p.x];
      break;
    }

    // Up
    if (p.y > 0 && grid[p.y - 1][p.x] == '.' && !visited[p.y - 1][p.x]) {
      queue.addFirst(Point(p.x, p.y - 1));
      distances[p.y - 1][p.x] = distances[p.y][p.x] + 1;
      visited[p.y - 1][p.x] = true;
    }
    // Down
    if (p.y < rows - 1 && grid[p.y + 1][p.x] == '.' && !visited[p.y + 1][p.x]) {
      queue.addFirst(Point(p.x, p.y + 1));
      distances[p.y + 1][p.x] = distances[p.y][p.x] + 1;
      visited[p.y + 1][p.x] = true;
    }
    // Left
    if (p.x > 0 && grid[p.y][p.x - 1] == '.' && !visited[p.y][p.x - 1]) {
      queue.addFirst(Point(p.x - 1, p.y));
      distances[p.y][p.x - 1] = distances[p.y][p.x] + 1;
      visited[p.y][p.x - 1] = true;
    }
    // Right
    if (p.x < columns - 1 &&
        grid[p.y][p.x + 1] == '.' &&
        !visited[p.y][p.x + 1]) {
      queue.addFirst(Point(p.x + 1, p.y));
      distances[p.y][p.x + 1] = distances[p.y][p.x] + 1;
      visited[p.y][p.x + 1] = true;
    }
  }
  grid[end.y][end.x] = originalEndUnitType;
  return distance;
}

/// Return list of points in range around a target.  Point is
/// in range if occupied by player or if open square.
List<Point> getOpenSquaresInRange(
    Unit player, Point targetPoint, List<List<String>> grid) {
  var openSquares = List<Point>();
  if (grid[targetPoint.y - 1][targetPoint.x] == '.' ||
      Point(targetPoint.x, targetPoint.y - 1) == Point(player.x, player.y))
    openSquares.add(Point(targetPoint.x, targetPoint.y - 1));
  if (grid[targetPoint.y][targetPoint.x + 1] == '.' ||
      Point(targetPoint.x + 1, targetPoint.y) == Point(player.x, player.y))
    openSquares.add(Point(targetPoint.x + 1, targetPoint.y));
  if (grid[targetPoint.y + 1][targetPoint.x] == '.' ||
      Point(targetPoint.x, targetPoint.y + 1) == Point(player.x, player.y))
    openSquares.add(Point(targetPoint.x, targetPoint.y + 1));
  if (grid[targetPoint.y][targetPoint.x - 1] == '.' ||
      Point(targetPoint.x - 1, targetPoint.y) == Point(player.x, player.y))
    openSquares.add(Point(targetPoint.x - 1, targetPoint.y));
  return openSquares;
}

/// Parses puzzle input. Adds elves & goblins to [units] and returns a grid.
List<List<String>> getStartingGrid() {
  var puzzleInput = USE_SAMPLE_DATA
      ? File("day_15_sample_1_input.txt").readAsLinesSync()
      : File("day_15_input.txt").readAsLinesSync();
  final rows = puzzleInput.length;
  final columns = puzzleInput.first.length;
  var grid = List.generate(rows, (_) => List<String>.filled(columns, ''));
  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      if (puzzleInput[y][x] == 'E') {
        units.add(Elf(x, y));
      }
      if (puzzleInput[y][x] == 'G') {
        units.add(Goblin(x, y));
      }
      grid[y][x] = puzzleInput[y][x];
    }
  }
  return grid;
}

/// Return a deep copy of a grid
List<List<String>> copyGrid(List<List<String>> grid) {
  final rows = grid.length;
  final columns = grid.first.length;
  var newGrid = List.generate(rows, (_) => List<String>.filled(columns, ' '));
  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      newGrid[y][x] = grid[y][x];
    }
  }
  return newGrid;
}

/// Prints grid
void printGrid(List<List<String>> grid) {
  grid.forEach((row) {
    row.forEach((cell) => stdout.write(cell));
    stdout.writeln();
  });
}
