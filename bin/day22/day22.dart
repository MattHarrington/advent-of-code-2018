// https://adventofcode.com/2018/day/22

import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';

const USE_SAMPLE_DATA = true;

enum Terrain { rocky, wet, narrow, M, T }

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
      return null;
      break;
  }
}

Terrain stringToTerrain(String terrain) {
  switch (terrain) {
    case '.':
      return Terrain.rocky;
      break;
    case '=':
      return Terrain.wet;
      break;
    case '|':
      return Terrain.narrow;
      break;
    default:
      return null;
      break;
  }
}

enum Tools { climbingGear, torch, neither }

class Region extends Comparable<Region> {
//  Point location;
  int x, y;
  Terrain terrain;
  int minutes;

  List<Tools> get allowedTools {
    var tools = List<Tools>();
    switch (terrain) {
      case Terrain.M:
      case Terrain.T:
        tools.add(Tools.torch);
        break;
      case Terrain.rocky:
        tools.addAll([Tools.climbingGear, Tools.torch]);
        break;
      case Terrain.wet:
        tools.addAll([Tools.climbingGear, Tools.neither]);
        break;
      case Terrain.narrow:
        tools.addAll([Tools.torch, Tools.neither]);
        break;
      default:
        break;
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
  toString() => '($x,$y) ${terrainToString(terrain)}';
}

class Point {
  int x, y;

  Point(this.x, this.y);

  @override
  toString() => '($x,$y)';
}

main() {
  var depth = USE_SAMPLE_DATA ? 510 : 3339;
  var target = USE_SAMPLE_DATA ? Point(10, 10) : Point(10, 715);
  var geoGrid = getEmptyGrid(target);
  var erosionGrid = getEmptyGrid(target);
  processGrids(geoGrid, erosionGrid, depth);
  var caveMap = getRiskLevel(erosionGrid, target);
//  print('riskLevel: $riskLevel');
  print('after generating map...');
  printGrid(caveMap);
  var answer = dijkstra(caveMap, target);
  print(answer);
}

List<List<String>> getRiskLevel(List<List<int>> erosionGrid, Point target) {
  final rows = erosionGrid.length;
  final columns = erosionGrid.first.length;
  var grid = List.generate(rows, (_) => List<String>.filled(columns, null));
  int riskLevel = 0;
  var sb = StringBuffer();
  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      String terrain;
      if (x == 0 && y == 0) {
        terrain = 'M';
      } else if (x == target.x && y == target.y) {
        terrain = 'T';
      } else {
        switch (erosionGrid[y][x] % 3) {
          case 0:
            terrain = '.'; // rocky
            riskLevel += 0;
            break;
          case 1:
            terrain = '='; // wet
            riskLevel += 1;
            break;
          case 2:
            terrain = '|'; // narrow
            riskLevel += 2;
            break;
          default:
            throw ArgumentError;
            break;
        }
      }
      grid[y][x] = terrain;
      sb.write(terrain);
    }
    sb.writeln();
  }
  print(sb.toString());
  print('riskLevel: $riskLevel');
//  return riskLevel;
  return grid;
}

int dijkstra(List<List<String>> grid, Point target) {
  final rows = grid.length;
  final columns = grid.first.length;
  var visited = List.generate(rows, (_) => List<bool>.filled(columns, false));
  var minutes = List.generate(rows, (_) => List<int>.filled(columns, null));
  var pq = PriorityQueue<Region>();

  grid[0][0] = '.';
  grid[target.y][target.x] = '.';

  var start = Region(0, 0, stringToTerrain(grid[0][0]));
  start.terrain = Terrain.rocky;
  start.minutes = 0;
  var previousRegion = start;
  var currentTool = Tools.torch;
  minutes[0][0] = 0;
  pq.add(start);
  while (pq.isNotEmpty) {
    var currentRegion = pq.removeFirst();
    var x = currentRegion.x;
    var y = currentRegion.y;
    if (visited[y][x]) continue;
    visited[y][x] = true;
    if (x == target.x && y == target.y) {
      if (currentTool != Tools.torch) minutes[y][x] += 7;
      break;
    }

//    var allowed = currentRegion.allowedTools;
    if (!currentRegion.allowedTools.contains(currentTool)) {
      currentTool =
          previousRegion.allowedTools.firstWhere((tool) => tool != currentTool);
    }

    var neighbors = List<Region>();
    if (x > 0 && !visited[y][x - 1]) {
      // left
      var neighbor = Region(x - 1, y, stringToTerrain(grid[y][x - 1]));
      neighbors.add(neighbor);
    }
    if (x < columns - 1 && !visited[y][x + 1]) {
      // right
      var neighbor = Region(x + 1, y, stringToTerrain(grid[y][x + 1]));
      neighbors.add(neighbor);
    }
    if (y > 0 && !visited[y - 1][x]) {
      // up
      var neighbor = Region(x, y - 1, stringToTerrain(grid[y - 1][x]));
      neighbors.add(neighbor);
    }
    if (y < rows - 1 && !visited[y + 1][x]) {
      // down
      var neighbor = Region(x, y + 1, stringToTerrain(grid[y + 1][x]));
      neighbors.add(neighbor);
    }
    for (var neighbor in neighbors) {
      int m = neighbor.allowedTools.contains(currentTool) ? 1 : 8;
      var newMinutesCandidate = m + minutes[y][x];
      if (minutes[neighbor.y][neighbor.x] == null) {
        minutes[neighbor.y][neighbor.x] = newMinutesCandidate;
      } else {
        minutes[neighbor.y][neighbor.x] =
            min(minutes[neighbor.y][neighbor.x], newMinutesCandidate);
      }
      neighbor.minutes = minutes[neighbor.y][neighbor.x];
      pq.add(neighbor);
    }
    previousRegion = currentRegion;
  }
  return minutes[target.y][target.x];
}

void processGrids(
    List<List<int>> geoGrid, List<List<int>> erosionGrid, int depth) {
  final rows = geoGrid.length;
  final columns = geoGrid.first.length;

  for (var x = 0; x < columns; ++x) {
    geoGrid[0][x] = x * 16807;
    erosionGrid[0][x] = (geoGrid[0][x] + depth) % 20183;
  }
  for (var y = 0; y < rows; ++y) {
    geoGrid[y][0] = y * 48271;
    erosionGrid[y][0] = (geoGrid[y][0] + depth) % 20183;
  }
  geoGrid[rows - 1][columns - 1] = 0;
  erosionGrid[rows - 1][columns - 1] = 0 + depth % 20183;

  for (var x = 1; x < columns; ++x) {
    for (var y = 1; y < rows; ++y) {
      geoGrid[y][x] = erosionGrid[y][x - 1] * erosionGrid[y - 1][x];
      erosionGrid[y][x] = (geoGrid[y][x] + depth) % 20183;
    }
  }
}

List<List<int>> getEmptyGrid(Point p) {
  final rows = p.y + 1 + 20;
  final columns = p.x + 1 + 20;
  var grid = List.generate(rows, (_) => List<int>.filled(columns, null));
  return grid;
}

/// Prints grid
void printGrid(List<List<String>> grid) {
  grid.forEach((row) {
    row.forEach((cell) => stdout.write(cell));
    stdout.writeln();
  });
}
