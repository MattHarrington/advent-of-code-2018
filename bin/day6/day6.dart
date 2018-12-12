// https://adventofcode.com/2018/day/6

/*
 This puzzle was frustrating.  My original strategy was sound, and
 my solution worked with the sample data, but failed with my puzzle
 input.  After much head-scratching, I read krokerik's solution in
 C at the GitHub URL below.  I started over, inspired by the simpler
 approach in that solution, but still could not get it to pass
 with the puzzle input.

 It turns out I had a bug in both my original solution and the better
 solution introduced by krokerik.  I mistakenly wrote "==" when I
 meant "=", so my code did not perform an assigment as expected.

 Along the way, I also learned about overriding the hashCode getter
 and == operator, both of which were required in my original approach
 but not the final one.

 https://github.com/krokerik/Advent-of-Code/blob/master/2018/c/Dec06.c
*/

import 'dart:io';

class Point {
  int x, y;

  Point(this.x, this.y);

  // Override hashCode using strategy from Effective Java,
  // Chapter 11.
  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + x.hashCode;
    result = 37 * result + y.hashCode;
    return result;
  }

  // You should generally implement operator == if you
  // override hashCode.
  @override
  bool operator ==(dynamic other) {
    if (other is! Point) return false;
    Point point = other;
    return (point.x == x && point.y == y);
  }

  @override
  toString() => "($x,$y)";
}

class Coordinate {
  // TODO: Consider "class Coordinate extends Point {...}"
  Point location;
  int closestPointsTotal = 0; // Total number of points closest to this location

  Coordinate(this.location);

  // Override hashCode using strategy from Effective Java,
  // Chapter 11.
  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + location.hashCode;
    result = 37 * result + closestPointsTotal.hashCode;
    return result;
  }

  // You should generally implement operator == if you
  // override hashCode.
  @override
  bool operator ==(dynamic other) {
    if (other is! Coordinate) return false;
    Coordinate c = other;
    return (c.location == location &&
        c.closestPointsTotal == closestPointsTotal);
  }

  @override
  toString() => "$location: $closestPointsTotal";
}

main() {
  const debug = false;
  List<String> input = File("day_6_input.txt").readAsLinesSync();
  // Sample: 124, 262

  var topEdge = 1000000;
  var bottomEdge = -1;
  var leftEdge = 1000000;
  var rightEdge = -1;

  var coordinates = List<Coordinate>();

  for (var record in input) {
    var splitRecord = record.split(',');
    var x = int.parse(splitRecord[0]);
    var y = int.parse(splitRecord[1]);
    var point = Point(x, y);
    var coordinate = Coordinate(point);
    coordinates.add(coordinate);

    if (x < leftEdge) {
      leftEdge = x;
    } else if (x > rightEdge) {
      rightEdge = x;
    }
    if (y < topEdge) {
      topEdge = y;
    } else if (y > bottomEdge) {
      bottomEdge = y;
    }
  }

  print("Bounding box: (${leftEdge}, ${topEdge}) to "
      "(${rightEdge}, ${bottomEdge})");

  var distanceThreshold = 10000;
  var safeRegionArea = 0;

  for (int y = topEdge; y <= bottomEdge; ++y) {
    var sb = StringBuffer();
    for (int x = leftEdge; x <= rightEdge; ++x) {
      var point = Point(x, y);
      var cumulativeDistanceToCoordinates = 0;
      var shortestDistance = 1000000;
      Coordinate closestCoordinate;
      var pointIsEquidistant = false;

      for (var coordinate in coordinates) {
        // Find closest coordinate to point
        var dist = manhattanDistance(point, coordinate.location);
        cumulativeDistanceToCoordinates += dist;

        if (dist == shortestDistance) {
          // Ignore points equidistant from two coordinates
          pointIsEquidistant = true;
        } else if (dist < shortestDistance) {
          pointIsEquidistant = false;
          shortestDistance = dist;
          closestCoordinate = coordinate;
        }
      }

      if (cumulativeDistanceToCoordinates < distanceThreshold) {
        ++safeRegionArea;
      }

      if (pointIsEquidistant == false &&
          closestCoordinate.closestPointsTotal != -1) {
        ++closestCoordinate.closestPointsTotal;
      }

      if (point.x == leftEdge ||
          point.x == rightEdge ||
          point.y == topEdge ||
          point.y == bottomEdge) {
        // Point is on perimeter of bounding box, and therefore in an
        // infinite region.  Use -1 to mark coordinate as infinite region.
        closestCoordinate.closestPointsTotal = -1;
      }

      if (debug == true) sb.write(closestCoordinate);
    }
    if (debug == true) print(sb.toString());
  }

  var largestArea = 0;
  Coordinate coordinateWithLargestArea;
  for (var coordinate in coordinates) {
    if (coordinate.closestPointsTotal > largestArea) {
      largestArea = coordinate.closestPointsTotal; // Bug was here. = vs. ==
      coordinateWithLargestArea = coordinate;
    }
  }

  print("Coordinate ${coordinateWithLargestArea.location} has the "
      "largest area: ${coordinateWithLargestArea.closestPointsTotal}");
  print("Safe region area: ${safeRegionArea}");
}

int manhattanDistance(Point a, Point b) {
  return (a.x - b.x).abs() + (a.y - b.y).abs();
}
