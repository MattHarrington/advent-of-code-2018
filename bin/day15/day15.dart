// https://adventofcode.com/2018/day/15

import 'dart:io';
import 'package:quiver/core.dart';

const USE_SAMPLE_DATA = true;
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
}

class Elf extends Unit {
  Elf(int x, int y) : super(x, y);
}

class Goblin extends Unit {
  Goblin(int x, int y) : super(x, y);
}

class Point {
  int x, y;

  Point(this.x, this.y);

  @override
  bool operator ==(o) => o is Point && x == o.x && y == o.y;

  @override
  int get hashCode => hash2(x.hashCode, y.hashCode);

  @override
  toString() => "($x,$y)";
}

main() {
  var grid = getStartingGrid();
  printGrid(grid);
  int round = 0;
  while (true) {
    // TODO: when does game end?
    // Determine unit's turn
    // Identify open squares in range of each target
    // If already in range, don't move.  Instead, attack.
    // If not in range, move.
    // To move:
    //   Find squares in range reachable in fewest steps
    //   Take single step towards square
    // After moving, attack:
    //   Find all targets in range
    //   Select target with fewest HP
    //   Reduce target HP by attackPower
    //   If target HP <= 0, target dies and replaced by '.'

    var nextGrid = copyGrid(grid);

    units.sort(Unit.comparePositions);

    for (var player in units.where((u) => u.alive)) {
      var potentialTargetsToAttack = List<Unit>();
      var potentialSquaresToMoveTo = List<Point>();
      for (var target in units
          .where((u) => u.alive && player.runtimeType != u.runtimeType)) {
        // Identify open squares in range of each target
        var openSquares =
            getOpenSquaresInRange(Point(target.x, target.y), grid);
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
        continue; // Go to next player
      }

      // Move then attack
      if (potentialSquaresToMoveTo.isNotEmpty) {
        move();
      }

      // Attack here
      for (var target in units
          .where((u) => u.alive && player.runtimeType != u.runtimeType)) {
        // Identify open squares in range of each target
        var openSquares =
            getOpenSquaresInRange(Point(target.x, target.y), grid);
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
    }

    grid = nextGrid;
    ++round;
  }
}

void move() {
  // BFS
  // Maybe https://stackoverflow.com/questions/37784324/shortest-path-in-a-grid
  throw 'Not implemented yet';
}

List<Point> getOpenSquaresInRange(Point targetPoint, List<List<String>> grid) {
  var openSquares = List<Point>();
  if (grid[targetPoint.y - 1][targetPoint.x] == '.')
    openSquares.add(Point(targetPoint.x, targetPoint.y));
  if (grid[targetPoint.y][targetPoint.x + 1] == '.')
    openSquares.add(Point(targetPoint.x + 1, targetPoint.y));
  if (grid[targetPoint.y + 1][targetPoint.x] == '.')
    openSquares.add(Point(targetPoint.x, targetPoint.y + 1));
  if (grid[targetPoint.y][targetPoint.x - 1] == '.')
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
