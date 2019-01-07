//https://adventofcode.com/2018/day/23

/*
Strategy for part 1 is trivial.  For part 2, create an axis-aligned
bounding box (AABB) cube which surrounds all nanobots.  Make its dimensions
2 times a power of two so each cube side can be easily bisected.  Divide
the AABB into 8 subvolumes and find one with most bots in range.  Further
subdivide that subvolume until the AABB is a single point.  That point
has the most nanobots in range for this form of the puzzle input.
Might not work in the general case.

There's currently a small bug when using the sample data for part 2.
Bug is probably in AABB.compareBotsInRange() which should return AABB
closest to origin in cases where 2 volumes are closest to an equal
number of nanobots.
 */

import 'dart:io';
import 'dart:math';

const USE_SAMPLE_DATA = false;

class Point {
  int x, y, z;

  Point();

  Point.fromCoordinates(this.x, this.y, this.z);
}

/// Axis-aligned Bounding Box (AABB)
class AABB {
  Point min, max;
  int botsInRange = 0;

  static AABB compareBotsInRange(AABB a, AABB b) {
    if (a.botsInRange == b.botsInRange)
      // TODO choose closest to origin, but for now return b
      return b;
    else if (a.botsInRange > b.botsInRange)
      return a;
    else
      return b;
  }

  /// https://gdbooks.gitbooks.io/3dcollisions/content/Chapter1/closest_point_aabb.html
  Point closestPointToBot(Nanobot bot) {
    var result = Point();
    if (bot.x > max.x)
      result.x = max.x;
    else if (bot.x < min.x)
      result.x = min.x;
    else
      result.x = bot.x;
    if (bot.y > max.y)
      result.y = max.y;
    else if (bot.y < min.y)
      result.y = min.y;
    else
      result.y = bot.y;
    if (bot.z > max.z)
      result.z = max.z;
    else if (bot.z < min.z)
      result.z = min.z;
    else
      result.z = bot.z;
    return result;
  }

  /// Returns list of this cube divided into 8 subvolumes
  List<AABB> getSubvolumes() {
    int d = ((max.x - min.x) / 2).floor();
    var subvolume1 = AABB(Point.fromCoordinates(min.x, min.y, min.z),
        Point.fromCoordinates(min.x + d, min.y + d, min.z + d));
    var subvolume2 = AABB(Point.fromCoordinates(min.x, min.y, min.z + d),
        Point.fromCoordinates(min.x + d, min.y + d, min.z + d * 2));
    var subvolume3 = AABB(Point.fromCoordinates(min.x, min.y + d, min.z),
        Point.fromCoordinates(min.x + d, min.y + d * 2, min.z + d));
    var subvolume4 = AABB(Point.fromCoordinates(min.x, min.y + d, min.z + d),
        Point.fromCoordinates(min.x + d, min.y + d * 2, min.z + d * 2));
    var subvolume5 = AABB(Point.fromCoordinates(min.x + d, min.y, min.z),
        Point.fromCoordinates(min.x + d * 2, min.y + d, min.z + d));
    var subvolume6 = AABB(Point.fromCoordinates(min.x + d, min.y, min.z + d),
        Point.fromCoordinates(min.x + d * 2, min.y + d, min.z + d * 2));
    var subvolume7 = AABB(Point.fromCoordinates(min.x + d, min.y + d, min.z),
        Point.fromCoordinates(min.x + d * 2, min.y + d * 2, min.z + d));
    var subvolume8 = AABB(
        Point.fromCoordinates(min.x + d, min.y + d, min.z + d),
        Point.fromCoordinates(min.x + d * 2, min.y + d * 2, min.z + d * 2));
    var subvolumes = [
      subvolume1,
      subvolume2,
      subvolume3,
      subvolume4,
      subvolume5,
      subvolume6,
      subvolume7,
      subvolume8
    ];
    return subvolumes;
  }

  AABB(this.min, this.max);

  @override
  toString() =>
      'min: (${min.x}, ${min.y}, ${min.z}) max: (${max.x}, ${max.y}, ${max.z})';
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
      // TODO can this be improved? What to do in a tie?
      return b;
  }

  bool inRangeOf(AABB aabb) {
    var closestPoint = aabb.closestPointToBot(this);
    if (manhattanDistanceToPoint(closestPoint) <= signalRadius)
      return true;
    else
      return false;
  }

  int numberBotsInRadius(List<Nanobot> nanobots) {
    int count = 0;
    for (var nanobot in nanobots) {
      if (manhattanDistanceToBot(nanobot) <= signalRadius) ++count;
    }
    return count;
  }

  int manhattanDistanceToBot(Nanobot other) {
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

  print('\nPart 2:');
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

  // Create AABB from s.  Choose power of 2 large enough to enclose all bots
  int s = pow(2, 28); // 268435456.  -s to s then encloses all bots
  var aabb =
      AABB(Point.fromCoordinates(-s, -s, -s), Point.fromCoordinates(s, s, s));

  for (var i = 0; i <= 29; ++i) {
    var subvolumes = aabb.getSubvolumes();
    for (var subvolume in subvolumes) {
      for (var nanobot in nanobots) {
        if (nanobot.inRangeOf(subvolume)) ++subvolume.botsInRange;
      }
    }
    // Choose subvolume with most bots
    aabb = subvolumes.reduce(AABB.compareBotsInRange);
  }

  print('\naabb = $aabb');

  var numBotsInRange = 0;
  for (var bot in nanobots) {
    if (bot.manhattanDistanceToPoint(aabb.min) <= bot.signalRadius)
      ++numBotsInRange;
  }
  print('Bots in range of aabb: $numBotsInRange');

  var partTwoAnswer = aabb.min.x + aabb.min.y + aabb.min.z; // dist to origin
  print('partTwoAnswer: $partTwoAnswer');
  if (!USE_SAMPLE_DATA) assert(partTwoAnswer == 119406340);
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
