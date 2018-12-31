// https://adventofcode.com/2018/day/15
// https://stackoverflow.com/questions/37784324/shortest-path-in-a-grid
// https://www.geeksforgeeks.org/shortest-distance-two-cells-matrix-grid/

import 'dart:io';
import 'dart:collection';
import 'package:quiver/core.dart';

const USE_SAMPLE_DATA = false;
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

  final _attackPower = 3;
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
  final _attackPower = 19;
  Elf(int x, int y) : super(x, y);
}

class Goblin extends Unit {
  Goblin(int x, int y) : super(x, y);
}

class Point {
  static int compareDistances(Point a, Point b) {
    int value;
    // If tied hitPoints, sort by reading order
    if (a.distance == b.distance) {
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
    } else if (a.distance < b.distance)
      value = -1;
    else if (a.distance > b.distance) value = 1;
    return value;
  }

  int x, y;
  int distance;

  Point(this.x, this.y, {this.distance = 0});

  @override
  bool operator ==(o) => o is Point && x == o.x && y == o.y;

  @override
  int get hashCode => hash3(x.hashCode, y.hashCode, distance.hashCode);

  @override
  toString() => "($x,$y)";
}

main() {
  var grid = getStartingGrid();
  int round = 0;
  var gameOn = true;

  while (gameOn) {
    print('After $round rounds:');
//    printGrid(grid);

    units.sort(Unit.comparePositions);
    for (var player in units.where((u) => u.alive)) {
      if (units
          .where((u) => u.alive && player.runtimeType != u.runtimeType)
          .isEmpty) {
        // Game over, no more targets
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

      // Have now gone through all targets

      // Attack target with lowest HP
      if (potentialTargetsToAttack.isNotEmpty) {
        potentialTargetsToAttack.sort(Unit.compareHitPoints);
        var attackedTarget = potentialTargetsToAttack.first;
        player.attack(attackedTarget);
        if (!attackedTarget.alive)
          nextGrid[attackedTarget.y][attackedTarget.x] = '.';
        grid = nextGrid;
        continue; // Go to next player
      }

      // Move then attack
      if (potentialSquaresToMoveTo.isNotEmpty) {
        for (var end in potentialSquaresToMoveTo) {
          end.distance = shortestDistance(Point(player.x, player.y), end, grid);
        }
        potentialSquaresToMoveTo.removeWhere(
            (square) => square.distance == null); // unreachable squares
        if (potentialSquaresToMoveTo.isNotEmpty) {
          potentialSquaresToMoveTo.sort(Point.compareDistances);
          var destination = potentialSquaresToMoveTo.first;
          move(player, destination, nextGrid);
        }
      }

      // Attack here
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
    } // player

    ++round;
  }
  print('Round: ${round-1}');
  var hitPointSum = 0;
  Type winner;
  for (var unit in units.where((u) => u.alive)) {
    hitPointSum += unit.hitPoints;
    winner = unit.runtimeType;
  }
  print('hitPointSum: $hitPointSum');
  print('winner: $winner');
  var anyWinnersDie = units.any((u) => u.runtimeType == winner && u.alive == false);
  print('anyWinnersDie: $anyWinnersDie');

}

void move(Unit start, Point target, List<List<String>> nextGrid) {
  final rows = nextGrid.length;
  final columns = nextGrid.first.length;

  var potentialDestinations = List<Point>();
  // Up
  if (start.y > 0 && nextGrid[start.y - 1][start.x] == '.') {
    potentialDestinations.add(Point(start.x, start.y - 1,
        distance:
            shortestDistance(Point(start.x, start.y - 1), target, nextGrid)));
  }
  // Down
  if (start.y < columns - 1 && nextGrid[start.y + 1][start.x] == '.') {
    potentialDestinations.add(Point(start.x, start.y + 1,
        distance:
            shortestDistance(Point(start.x, start.y + 1), target, nextGrid)));
  }
  // Left
  if (start.x > 0 && nextGrid[start.y][start.x - 1] == '.') {
    potentialDestinations.add(Point(start.x - 1, start.y,
        distance:
            shortestDistance(Point(start.x - 1, start.y), target, nextGrid)));
  }
  // Right
  if (start.x < rows - 1 && nextGrid[start.y][start.x + 1] == '.') {
    potentialDestinations.add(Point(start.x + 1, start.y,
        distance:
            shortestDistance(Point(start.x + 1, start.y), target, nextGrid)));
  }
  potentialDestinations.removeWhere((p) => p.distance == null);
  potentialDestinations.sort(Point.compareDistances);
  var destination = potentialDestinations.first;
  var originalUnit = nextGrid[start.y][start.x];
  nextGrid[start.y][start.x] = '.';
  nextGrid[destination.y][destination.x] = originalUnit;
  start.x = destination.x;
  start.y = destination.y;
}

int shortestDistance(Point start, Point end, List<List<String>> grid) {
  var originalEndUnitType = grid[end.y][end.x];
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
//  if (distance == null) {
////    printGrid(grid);
//    print('why null?');
//  }
  return distance;
}

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

void printGrid(List<List<String>> grid) {
  grid.forEach((row) {
    row.forEach((cell) => stdout.write(cell));
    stdout.writeln();
  });
}

// 12480 too low
