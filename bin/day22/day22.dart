// https://adventofcode.com/2018/day/22

/*
Tried enums in this solution versus magic strings.
 */

import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';

const USE_SAMPLE_DATA = false;
const PADDING = 100; // Accommodates paths beyond target

enum Terrain { rocky, wet, narrow }

/// Helper function because can't override toString() on enum
String terrainToString(Terrain terrain) {
  switch (terrain) {
    case Terrain.rocky:
      return '.';
      break;
    case Terrain.wet:
      return '=';
      break;
    case Terrain.narrow:
      return '|';
      break;
    default:
      throw ArgumentError.value(terrain);
  }
}

enum Tool { climbingGear, torch, neither }

class Region extends Comparable<Region> {
  int x, y;
  Terrain terrain;
  int minutes;
  Tool tool;

  List<Tool> get allowedTools {
    var tools = List<Tool>();
    switch (terrain) {
      case Terrain.rocky:
        tools.addAll([Tool.climbingGear, Tool.torch]);
        break;
      case Terrain.wet:
        tools.addAll([Tool.climbingGear, Tool.neither]);
        break;
      case Terrain.narrow:
        tools.addAll([Tool.torch, Tool.neither]);
        break;
      default:
        throw ArgumentError.value(terrain);
    }
    return tools;
  }

  Region(this.x, this.y, this.terrain);

  @override
  int compareTo(Region other) {
    if (minutes == other.minutes)
      return 0;
    else if (minutes < other.minutes)
      return -1;
    else
      return 1;
  }

  @override
  toString() => '($x,$y) ${terrainToString(terrain)} $minutes';
}

class Point {
  int x, y;

  Point(this.x, this.y);
}

main() {
  var depth = USE_SAMPLE_DATA ? 510 : 3339;
  var target = USE_SAMPLE_DATA ? Point(10, 10) : Point(10, 715);

  var erosionLevel = getErosionLevel(target, depth);
  var caveMap = getCaveMap(erosionLevel);
  assert(caveMap[0][0] == Terrain.rocky &&
      caveMap[target.y][target.x] == Terrain.rocky);
  printGrid(caveMap, target);

  var partOneAnswer = getRiskLevel(caveMap, target);
  print('partOneAnswer: $partOneAnswer');

  var partTwoAnswer = dijkstra(caveMap, target);
  print('partTwoAnswer: $partTwoAnswer');

  if (USE_SAMPLE_DATA) {
    assert(partOneAnswer == 114);
    assert(partTwoAnswer == 45);
  } else {
    assert(partOneAnswer == 7915);
    assert(partTwoAnswer == 980);
  }
}

List<List<Terrain>> getCaveMap(List<List<int>> erosionLevel) {
  final rows = erosionLevel.length;
  final columns = erosionLevel.first.length;
  var caveMap = List.generate(rows, (_) => List<Terrain>.filled(columns, null));
  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      Terrain terrain;
      switch (erosionLevel[y][x] % 3) {
        case 0:
          terrain = Terrain.rocky;
          break;
        case 1:
          terrain = Terrain.wet;
          break;
        case 2:
          terrain = Terrain.narrow;
          break;
        default:
          throw ArgumentError.value(erosionLevel[y][x] % 3);
      }
      caveMap[y][x] = terrain;
    }
  }
  return caveMap;
}

int getRiskLevel(List<List<Terrain>> caveMap, Point target) {
  final rows = caveMap.length;
  final columns = caveMap.first.length;
  int riskLevel = 0;
  for (var y = 0; y <= target.y; ++y) {
    for (var x = 0; x <= target.x; ++x) {
      switch (caveMap[y][x]) {
        case Terrain.rocky:
          riskLevel += 0;
          break;
        case Terrain.wet:
          riskLevel += 1;
          break;
        case Terrain.narrow:
          riskLevel += 2;
          break;
        default:
          throw ArgumentError.value(caveMap[y][x]);
      }
    }
  }
  return riskLevel;
}

int dijkstra(List<List<Terrain>> grid, Point target) {
  final rows = grid.length;
  final columns = grid.first.length;
  var minutes = List.generate(
      rows, (_) => List.generate(columns, (_) => List<int>.filled(3, null)));
  minutes[0][0][Tool.torch.index] = 0;
  var visited = List.generate(
      rows, (_) => List.generate(columns, (_) => List<bool>.filled(3, false)));
  var pq = PriorityQueue<Region>();

  var startingRegion = Region(0, 0, grid[0][0]);
  startingRegion.terrain = Terrain.rocky;
  startingRegion.minutes = 0;
  startingRegion.tool = Tool.torch;

  pq.add(startingRegion);

  while (pq.isNotEmpty) {
    var currentRegion = pq.removeFirst();
    var x = currentRegion.x;
    var y = currentRegion.y;
    if (visited[y][x][currentRegion.tool.index]) continue;
    visited[y][x][currentRegion.tool.index] = true;
    if (x == target.x && y == target.y) {
      if (currentRegion.tool != Tool.torch) {
        minutes[y][x][Tool.torch.index] =
            minutes[y][x][currentRegion.tool.index] + 7;
      }
      break;
    }

    var neighbors = List<Region>();

    // left
    if (x > 0 && !visited[y][x - 1][currentRegion.tool.index]) {
      var neighbor = Region(x - 1, y, grid[y][x - 1]);
      neighbors.add(neighbor);
    }
    // right
    if (x < columns - 1 && !visited[y][x + 1][currentRegion.tool.index]) {
      var neighbor = Region(x + 1, y, grid[y][x + 1]);
      neighbors.add(neighbor);
    }
    // up
    if (y > 0 && !visited[y - 1][x][currentRegion.tool.index]) {
      var neighbor = Region(x, y - 1, grid[y - 1][x]);
      neighbors.add(neighbor);
    }
    // down
    if (y < rows - 1 && !visited[y + 1][x][currentRegion.tool.index]) {
      var neighbor = Region(x, y + 1, grid[y + 1][x]);
      neighbors.add(neighbor);
    }

    for (var neighbor in neighbors) {
      // If no tool change required, m = 1.
      // If tool change required, m = 8 and change tool.
      int m;
      if (neighbor.allowedTools.contains(currentRegion.tool)) {
        m = 1;
        neighbor.tool = currentRegion.tool;
      } else {
        m = 1 + 7; // 1 to enter the region, 7 to change tool
        neighbor.tool = currentRegion.allowedTools
            .firstWhere((tool) => tool != currentRegion.tool);
      }

      var newMinutesCandidate = m + minutes[y][x][currentRegion.tool.index];
      if (minutes[neighbor.y][neighbor.x][neighbor.tool.index] == null) {
        // Think of null like infinity in a typical Dijkstra implementation
        minutes[neighbor.y][neighbor.x][neighbor.tool.index] =
            newMinutesCandidate;
      } else {
        minutes[neighbor.y][neighbor.x][neighbor.tool.index] = min(
            minutes[neighbor.y][neighbor.x][neighbor.tool.index],
            newMinutesCandidate);
      }
      neighbor.minutes = minutes[neighbor.y][neighbor.x][neighbor.tool.index];
      pq.add(neighbor);
    }
  }
  return minutes[target.y][target.x][Tool.torch.index];
}

List<List<int>> getErosionLevel(Point target, int depth) {
  final rows = target.y + PADDING;
  final columns = target.x + PADDING;
  var geologicIndex =
      List.generate(rows, (_) => List<int>.filled(columns, null));
  var erosionLevel =
      List.generate(rows, (_) => List<int>.filled(columns, null));

  for (var x = 0; x < columns; ++x) {
    geologicIndex[0][x] = x * 16807;
    erosionLevel[0][x] = (geologicIndex[0][x] + depth) % 20183;
  }
  for (var y = 0; y < rows; ++y) {
    geologicIndex[y][0] = y * 48271;
    erosionLevel[y][0] = (geologicIndex[y][0] + depth) % 20183;
  }

//  geologicIndex[target.y][target.x] = 0;
//  erosionLevel[target.y][target.x] = (0 + depth) % 20183;

  for (var x = 1; x < columns; ++x) {
    for (var y = 1; y < rows; ++y) {
      if (x == target.x && y == target.y) {
        geologicIndex[target.y][target.x] = 0;
        erosionLevel[target.y][target.x] = (0 + depth) % 20183;
        continue;
      }
      geologicIndex[y][x] = erosionLevel[y][x - 1] * erosionLevel[y - 1][x];
      erosionLevel[y][x] = (geologicIndex[y][x] + depth) % 20183;
    }
  }
  return erosionLevel;
}

/// Prints grid
void printGrid(List<List<Terrain>> grid, Point target) {
  for (var y = 0; y <= target.y; ++y) {
    for (var x = 0; x <= target.x; ++x) {
      String terrainString;
      switch (grid[y][x]) {
        case Terrain.rocky:
          terrainString = '.';
          break;
        case Terrain.wet:
          terrainString = '=';
          break;
        case Terrain.narrow:
          terrainString = '|';
          break;
        default:
          throw ArgumentError.value(grid[y][x]);
      }
      stdout.write(terrainString);
    }
    stdout.writeln();
  }
}
