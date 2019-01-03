//https://adventofcode.com/2018/day/23

import 'dart:io';

import 'dart:math';

const USE_SAMPLE_DATA = false;

class Nanobot {
  int x, y, z;
  int signalRadius;

  Nanobot(this.x, this.y, this.z, this.signalRadius);
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

  var puzzleInput = USE_SAMPLE_DATA
      ? sampleInput
      : File('day_23_input.txt').readAsLinesSync();

  var nanobots = parseInput(puzzleInput);
  var largestRadiusBot = nanobots.reduce(compareMaxRadius);
  var partOneAnswer = botsInRadius(largestRadiusBot, nanobots);
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

  var botsInRange = List<int>();
  for (var nanobot in nanobots) {
    botsInRange.add(botsInRadius(nanobot, nanobots));
  }
  assert(botsInRange.length == nanobots.length);
  botsInRange.sort();
}

int botsInRadius(Nanobot a, List<Nanobot> nanobots) {
  int count = 0;
  for (var nanobot in nanobots) {
    if (manhattanDistance(a, nanobot) <= a.signalRadius) ++count;
  }
  return count;
}

int manhattanDistance(Nanobot a, Nanobot b) {
  return (a.x - b.x).abs() + (a.y - b.y).abs() + (a.z - b.z).abs();
}

Nanobot compareMaxRadius(Nanobot a, Nanobot b) {
  if (a.signalRadius > b.signalRadius)
    return a;
  else if (a.signalRadius < b.signalRadius)
    return b;
  else
    return null;
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
