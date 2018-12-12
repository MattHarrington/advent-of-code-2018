// https://adventofcode.com/2018/day/11

import 'dart:io';

const DEBUG = true;
const puzzle_input = 9995;

class Coordinate {
  int x, y;
  int powerLevel;

  Coordinate(this.x, this.y, this.powerLevel);

  // Override hashCode using strategy from Effective Java, Chapter 11
  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + x.hashCode;
    result = 37 * result + y.hashCode;
    result = 37 * result + powerLevel.hashCode;
    return result;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Coordinate) return false;
    Coordinate c = other;
    return (c.x == x && c.y == y && c.powerLevel == powerLevel);
  }

  @override
  String toString() => "(${x},${y}) power level: ${powerLevel}";
}

main() {
  if (DEBUG) {
    testPowerLevels();
    testGridSerialNumber18();
    testGridSerialNumber42();
    testEqualityOverride();
    testSerialNumber18LargestPatchValue();
    testSerialNumber42LargestPatchValue();
  }

  final grid = generateGrid(serialNumber: puzzle_input);

  // Part one

  var partOneAnswer = getGridMaxValue(
      computePatchGrid(patchSize: 3, serialNumber: puzzle_input));
  assert(partOneAnswer == Coordinate(33, 45, 29));
  print("Part one answer: ${partOneAnswer}");

  // Part two

  var partTwoMax = -1000000;
  Coordinate partTwoAnswer;
  var largestPatchSize = 0;
  stdout.write("Patch size: ");
  for (var patchSize = 1; patchSize <= 20; ++patchSize) {
    stdout.write("${patchSize},");
    var p = getGridMaxValue(
        computePatchGrid(patchSize: patchSize, serialNumber: puzzle_input));
    if (p.powerLevel > partTwoMax) {
      partTwoMax = p.powerLevel;
      partTwoAnswer = p;
      largestPatchSize = patchSize;
    }
  }
  stdout.writeln();
  assert(partTwoAnswer.x == 233 &&
      partTwoAnswer.y == 116 &&
      largestPatchSize == 15);
  print("Part two answer: ${partTwoAnswer}, Patch size: ${largestPatchSize}");
}

int computePowerLevel(int x, int y, {int serialNumber}) {
  var rackId = x + 10;
  var powerLevel = rackId * y;
  powerLevel += serialNumber;
  powerLevel *= rackId;
  int hundredsDigit = ((powerLevel % 1000) / 100).truncate();
  powerLevel = hundredsDigit;
  powerLevel -= 5;
  return powerLevel;
}

List<List<int>> generateGrid({int serialNumber}) {
  const int rows = 300;
  const int columns = 300;
  var grid = List.generate(rows, (_) => new List<int>.filled(columns, 0));

  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      grid[x][y] = computePowerLevel(x + 1, y + 1, serialNumber: serialNumber);
    }
  }
  return grid;
}

List<List<int>> computePatchGrid({int patchSize, int serialNumber}) {
  final rows = 300 - patchSize;
  final columns = 300 - patchSize;
  var patchGrid = List.generate(rows, (_) => new List<int>.filled(columns, 0));
  var grid = generateGrid(serialNumber: serialNumber);
  for (var y = 0; y < columns; ++y) {
    for (var x = 0; x < rows; ++x) {
      for (var patchY = 0; patchY < patchSize; ++patchY) {
        for (var patchX = 0; patchX < patchSize; ++patchX) {
          patchGrid[x][y] += grid[x + patchX][y + patchY];
        }
      }
    }
  }
  return patchGrid;
}

Coordinate getGridMaxValue(List<List<int>> grid) {
  var columns = grid.length;
  var rows = grid.first.length;
  var maxPowerLevel = -1000000;
  var xMax, yMax;
  for (var y = 0; y < columns; ++y) {
    for (var x = 0; x < rows; ++x) {
      if (grid[x][y] > maxPowerLevel) {
        maxPowerLevel = grid[x][y];
        xMax = x + 1; // increment b/c List is 0-indexed & coords are 1-300
        yMax = y + 1;
      }
    }
  }
  return (Coordinate(xMax, yMax, maxPowerLevel));
}

void testPowerLevels() {
  // Examples from problem description
  assert(computePowerLevel(3, 5, serialNumber: 8) == 4);
  assert(computePowerLevel(122, 79, serialNumber: 57) == -5);
  assert(computePowerLevel(217, 196, serialNumber: 39) == 0);
  assert(computePowerLevel(101, 153, serialNumber: 71) == 4);
}

void testGridSerialNumber18() {
  // Examples from problem description
  var sampleGrid1 = generateGrid(serialNumber: 18);
  assert(sampleGrid1[33 - 1][45 - 1] == 4);
  assert(sampleGrid1[34 - 1][45 - 1] == 4);
  assert(sampleGrid1[35 - 1][45 - 1] == 4);
  assert(sampleGrid1[33 - 1][46 - 1] == 3);
  assert(sampleGrid1[34 - 1][46 - 1] == 3);
  assert(sampleGrid1[35 - 1][46 - 1] == 4);
  assert(sampleGrid1[33 - 1][47 - 1] == 1);
  assert(sampleGrid1[34 - 1][47 - 1] == 2);
  assert(sampleGrid1[35 - 1][47 - 1] == 4);
}

void testGridSerialNumber42() {
  // Examples from problem description
  var sampleGrid2 = generateGrid(serialNumber: 42);
  assert(sampleGrid2[21 - 1][61 - 1] == 4);
  assert(sampleGrid2[22 - 1][61 - 1] == 3);
  assert(sampleGrid2[23 - 1][61 - 1] == 3);
  assert(sampleGrid2[21 - 1][62 - 1] == 3);
  assert(sampleGrid2[22 - 1][62 - 1] == 3);
  assert(sampleGrid2[23 - 1][62 - 1] == 4);
  assert(sampleGrid2[21 - 1][63 - 1] == 3);
  assert(sampleGrid2[22 - 1][63 - 1] == 3);
  assert(sampleGrid2[23 - 1][63 - 1] == 4);
}

void testSerialNumber18LargestPatchValue() {
  // Example from problem description
  var pg = computePatchGrid(patchSize: 3, serialNumber: 18);
  var max = getGridMaxValue(pg);
  assert(max.powerLevel == 29);
}

void testSerialNumber42LargestPatchValue() {
  // Example from problem description
  var pg = computePatchGrid(patchSize: 3, serialNumber: 42);
  var max = getGridMaxValue(pg);
  assert(max.powerLevel == 30);
}

void testEqualityOverride() {
  // Tests that @override of == in Coordinate is correct
  var a1 = getGridMaxValue(
      computePatchGrid(patchSize: 3, serialNumber: puzzle_input));
  var a2 = getGridMaxValue(
      computePatchGrid(patchSize: 3, serialNumber: puzzle_input));
  assert(a1 == a2);
}
