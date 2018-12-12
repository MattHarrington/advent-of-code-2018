// https://adventofcode.com/2018/day/10

import 'dart:io';

class Point {
  int x, y;

  Point(this.x, this.y);
}

main() {
  var puzzle_input = File("day_10_input.txt").readAsLinesSync();
  // Sample: "position=< 32266, -31853> velocity=<-3,  3>"
  var points = List<Point>();
  var velocities = List<Point>();
  for (var record in puzzle_input) {
    var regex = RegExp(r'-?\d*\.{0,1}\d+'); // Positive or negative numbers
    var digitMatches = regex.allMatches(record);

    var match1 = digitMatches.elementAt(0);
    var match2 = digitMatches.elementAt(1);
    var match3 = digitMatches.elementAt(2);
    var match4 = digitMatches.elementAt(3);

    var x = int.parse(match1.group(0));
    var y = int.parse(match2.group(0));
    var x_velocity = int.parse(match3.group(0));
    var y_velocity = int.parse(match4.group(0));

    points.add(Point(x, y));
    velocities.add(Point(x_velocity, y_velocity));
  }

  /*
   Draw on 100 x 40 grid, since that fits screen. Use linear map. From:
   https://stackoverflow.com/questions/12931115/algorithm-to-map-an-interval-to-a-smaller-interval

    To map
    [A, B] --> [a, b]

    use this formula
    (val - A)*(b-a)/(B-A) + a
   */

  int clock = 1;
  while (clock <= 10681) {
    int max_x = 0;
    int min_x = 1000000;
    int max_y = 0;
    int min_y = 1000000;
    for (var point in points) {
      if (point.x > max_x) max_x = point.x;
      if (point.y > max_y) max_y = point.y;
      if (point.x < min_x) min_x = point.x;
      if (point.y < min_y) min_y = point.y;
    }

    for (var i = 0; i < points.length; ++i) {
      points[i].x = points[i].x + velocities[i].x;
      points[i].y = points[i].y + velocities[i].y;
    }

    printPoints(points.map((p) {
      // Map x and y, return new point
      var new_x = ((p.x - min_x) * (99 - 0) / (max_x - min_x) + 0).round();
      var new_y = ((p.y - min_y) * (39 - 0) / (max_y - min_y) + 0).round();
      return Point(new_x, new_y);
    }).toList());

    print(
        "Clock: ${clock} min_x: ${min_x} max_x: ${max_x} min_y: ${min_y} max_y: ${max_y}");
    ++clock;
  }
}

void printPoints(List<Point> points) {
  // Create 2D "array"
  const int rows = 40;
  const int columns = 100;
  var canvas =
  List.generate(rows, (_) => new List<String>.filled(columns, "."));

  for (var point in points) {
    canvas[point.y][point.x] = "#";
  }

  for (var line in canvas) {
    var sb = StringBuffer();
    for (var pixel in line) {
      sb.write(pixel);
    }
    print(sb.toString());
  }
}
