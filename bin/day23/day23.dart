//https://adventofcode.com/2018/day/23

import 'dart:io';

import 'dart:math';

const USE_SAMPLE_DATA = false;

class Point {
  int x, y, z;

  Point();

  Point.fromCoordinates(this.x, this.y, this.z);
}

class Cube {
  Point min, max;
  int botsInRange = 0;

  static Cube compareBotsInRange(Cube a, Cube b) {
    if (a.botsInRange == b.botsInRange)
//      throw StateError('Equal number of bots in range');
      return b;
    else if (a.botsInRange > b.botsInRange)
      return a;
    else
      return b;
  }

  List<Cube> getSubVolumes() {
    int d = ((max.x - min.x) / 2).floor();
    var subVolume1 = Cube(Point.fromCoordinates(min.x, min.y, min.z),
        Point.fromCoordinates(min.x + d, min.y + d, min.z + d));
    var subVolume2 = Cube(Point.fromCoordinates(min.x, min.y, min.z + d),
        Point.fromCoordinates(min.x + d, min.y + d, min.z + d * 2));
    var subVolume3 = Cube(Point.fromCoordinates(min.x, min.y + d, min.z),
        Point.fromCoordinates(min.x + d, min.y + d * 2, min.z + d));
    var subVolume4 = Cube(Point.fromCoordinates(min.x, min.y + d, min.z + d),
        Point.fromCoordinates(min.x + d, min.y + d * 2, min.z + d * 2));
    var subVolume5 = Cube(Point.fromCoordinates(min.x + d, min.y, min.z),
        Point.fromCoordinates(min.x + d * 2, min.y + d, min.z + d));
    var subVolume6 = Cube(Point.fromCoordinates(min.x + d, min.y, min.z + d),
        Point.fromCoordinates(min.x + d * 2, min.y + d, min.z + d * 2));
    var subVolume7 = Cube(Point.fromCoordinates(min.x + d, min.y + d, min.z),
        Point.fromCoordinates(min.x + d * 2, min.y + d * 2, min.z + d));
    var subVolume8 = Cube(
        Point.fromCoordinates(min.x + d, min.y + d, min.z + d),
        Point.fromCoordinates(min.x + d * 2, min.y + d * 2, min.z + d * 2));
    var subVolumes = [
      subVolume1,
      subVolume2,
      subVolume3,
      subVolume4,
      subVolume5,
      subVolume6,
      subVolume7,
      subVolume8
    ];
    return subVolumes;
  }

  Cube(this.min, this.max);

  @override
  toString() => '(${min.x}, ${min.y}, ${min.z}) (${max.x}, ${max.y}, ${max.z})';
}

class Nanobot {
  int x, y, z;
  int signalRadius;

  static Nanobot compareSignalRadius(Nanobot a, Nanobot b) {
    if (a.signalRadius > b.signalRadius)
      return a;
    else if (a.signalRadius < b.signalRadius)
      return b;
    else
      return b;
  }

  int numberBotsInRadius(List<Nanobot> nanobots) {
    int count = 0;
    for (var nanobot in nanobots) {
      if (manhattanDistanceTo(nanobot) <= signalRadius) ++count;
    }
    return count;
  }

  int manhattanDistanceTo(Nanobot other) {
    return (x - other.x).abs() + (y - other.y).abs() + (z - other.z).abs();
  }

  int manhattanDistanceToPoint(Point p) {
    return (x - p.x).abs() + (y - p.y).abs() + (z - p.z).abs();
  }

  Nanobot(this.x, this.y, this.z, this.signalRadius);

  @override
  toString() => '($x,$y,$z) r=$signalRadius';
}

main() {
  List<String> sampleInput = [
    'pos=<0,0,0>, r=4',
    'pos=<1,0,0>, r=1',
    'pos=<4,0,0>, r=3',
    'pos=<0,2,0>, r=1',
    'pos=<0,5,0>, r=3',
    'pos=<0,0,3>, r=1',
    'pos=<1,1,1>, r=1',
    'pos=<1,1,2>, r=1',
    'pos=<1,3,1>, r=1'
  ];

  List<String> sampleInputPart2 = [
    'pos=<10,12,12>, r=2',
    'pos=<12,14,12>, r=2',
    'pos=<16,12,12>, r=4',
    'pos=<14,14,14>, r=6',
    'pos=<50,50,50>, r=200',
    'pos=<10,10,10>, r=5'
  ];

  var puzzleInput = USE_SAMPLE_DATA
      ? sampleInputPart2
      : File('day_23_input.txt').readAsLinesSync();

  var nanobots = parseInput(puzzleInput);
  var largestRadiusBot = nanobots.reduce(Nanobot.compareSignalRadius);
  var partOneAnswer = largestRadiusBot.numberBotsInRadius(nanobots);
  print('partOneAnswer: $partOneAnswer');
  if (!USE_SAMPLE_DATA) assert(partOneAnswer == 396);

  // Part 2

  int minX = nanobots.fold(nanobots.first.x, (p, element) => min(p, element.x));
  int maxX = nanobots.fold(nanobots.first.x, (p, element) => max(p, element.x));
  int minY = nanobots.fold(nanobots.first.y, (p, element) => min(p, element.y));
  int maxY = nanobots.fold(nanobots.first.y, (p, element) => max(p, element.y));
  int minZ = nanobots.fold(nanobots.first.z, (p, element) => min(p, element.z));
  int maxZ = nanobots.fold(nanobots.first.z, (p, element) => max(p, element.z));
  print('x range: $minX to $maxX = ${maxX - minX}');
  print('y range: $minY to $maxY = ${maxY - minY}');
  print('z range: $minZ to $maxZ = ${maxZ - minZ}');
  print('total coords: ${(maxX - minX) * (maxY - minY) * (maxZ - minZ)}');

  int s = pow(2, 28); // 268435456
  var startingCube =
      Cube(Point.fromCoordinates(-s, -s, -s), Point.fromCoordinates(s, s, s));

  for (var nanobot in nanobots) {
    if (botInRangeOfCube(nanobot, startingCube)) ++startingCube.botsInRange;
  }

  var testCube =
      Cube(Point.fromCoordinates(0, 0, 0), Point.fromCoordinates(16, 16, 16));
  var testSubVolumes = testCube.getSubVolumes();

  for (var i = 0; i <= 29; ++i) {
    var subvolumes = startingCube.getSubVolumes();
    for (var subvolume in subvolumes) {
      for (var nanobot in nanobots) {
        if (botInRangeOfCube(nanobot, subvolume)) ++subvolume.botsInRange;
      }
    }
    // Choose subVolume with most bots
    startingCube = subvolumes.reduce(Cube.compareBotsInRange);
  }

  print(startingCube);
  var testbot = Nanobot(startingCube.min.x, startingCube.min.y, startingCube.min.z, 0);
  var numBotsInRange = 0;
  for (var bot in nanobots) {
    if (bot.manhattanDistanceToPoint(Point.fromCoordinates(12,12,12)) <= bot.signalRadius) ++numBotsInRange;
  }
  print('bots in range: $numBotsInRange');

}

/// https://gdbooks.gitbooks.io/3dcollisions/content/Chapter1/closest_point_aabb.html
Point closestPointOnAABB(Nanobot bot, Cube aabb) {
  var result = Point();
  if (bot.x > aabb.max.x)
    result.x = aabb.max.x;
  else if (bot.x < aabb.min.x)
    result.x = aabb.min.x;
  else
    result.x = bot.x;
  if (bot.y > aabb.max.y)
    result.y = aabb.max.y;
  else if (bot.y < aabb.min.y)
    result.y = aabb.min.y;
  else
    result.y = bot.y;
  if (bot.z > aabb.max.z)
    result.z = aabb.max.z;
  else if (bot.z < aabb.min.z)
    result.z = aabb.min.z;
  else
    result.z = bot.z;
  return result;
}

bool botInRangeOfCube(Nanobot bot, Cube aabb) {
  var closestPoint = closestPointOnAABB(bot, aabb);
  if (bot.manhattanDistanceToPoint(closestPoint) <= bot.signalRadius)
    return true;
  else
    return false;
}

List<Nanobot> parseInput(List<String> puzzleInput) {
  var nanobots = List<Nanobot>();
  for (var record in puzzleInput) {
    var digitRegex = RegExp(r'pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)');
    var matches = digitRegex.allMatches(record).first;
    var x = int.parse(matches.group(1));
    var y = int.parse(matches.group(2));
    var z = int.parse(matches.group(3));
    var signalRadius = int.parse(matches.group(4));
    var nanobot = Nanobot(x, y, z, signalRadius);
    nanobots.add(nanobot);
  }
  return nanobots;
}
