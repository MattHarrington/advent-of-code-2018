// https://adventofcode.com/2018/day/25

import 'dart:io';
import 'package:quiver/core.dart';

const USE_SAMPLE_DATA = false;

class Coordinate {
  int x, y, z, t;
  List<Coordinate> children;

  int manhattanDistanceTo(Coordinate other) {
    return (x - other.x).abs() +
        (y - other.y).abs() +
        (z - other.z).abs() +
        (t - other.t).abs();
  }

  Coordinate(this.x, this.y, this.z, this.t) : children = List<Coordinate>() {}

  @override
  int get hashCode => hash4(x.hashCode, y.hashCode, z.hashCode, t.hashCode);

  @override
  bool operator ==(o) =>
      o is Coordinate && x == o.x && y == o.y && z == o.z && t == o.t;
}

main() {
  var puzzleInput = USE_SAMPLE_DATA
      ? File('day_25_sample_4_input.txt').readAsLinesSync()
      : File('day_25_input.txt').readAsLinesSync();
  var coordinates = getCoordinates(puzzleInput);

  // Part 1

  // Setup
  var visited = Map<Coordinate, bool>();
  for (var coordinate in coordinates) {
    visited[coordinate] = false;
    for (var other in coordinates) {
      if (coordinate == other) continue;
      if (coordinate.manhattanDistanceTo(other) <= 3)
        coordinate.children.add(other);
    }
  }

  // DFS
  int connectedComponents = 0;
  for (var coordinate in coordinates) {
    if (visited[coordinate]) continue;
    dfs(coordinate, visited);
    ++connectedComponents;
  }

  print('Part 1: Number of constellations: $connectedComponents');
  if (!USE_SAMPLE_DATA) assert(connectedComponents == 420);
}

/// Depth-first search
void dfs(Coordinate coordinate, Map<Coordinate, bool> visited) {
  visited[coordinate] = true;
  for (var child in coordinate.children) {
    if (!visited[child]) dfs(child, visited);
  }
}

/// Parse a List<String> from the puzzle input into a List<Coordinate>
List<Coordinate> getCoordinates(List<String> puzzleInput) {
  var coordinates = List<Coordinate>();
  var regex = RegExp(r'(-?\d+),(-?\d+),(-?\d+),(-?\d+)');
  for (var record in puzzleInput) {
    var matches = regex.allMatches(record).first;
    int x = int.parse(matches.group(1));
    int y = int.parse(matches.group(2));
    int z = int.parse(matches.group(3));
    int t = int.parse(matches.group(4));
    var coordinate = Coordinate(x, y, z, t);
    coordinates.add(coordinate);
  }
  return coordinates;
}
