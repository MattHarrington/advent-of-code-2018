// https://adventofcode.com/2018/day/17

import 'dart:io';

const DEBUG = false;
const USE_SAMPLE_DATA = true;

main() {
  var puzzleInput = (USE_SAMPLE_DATA
      ? File("day_17_sample_input.txt").readAsLinesSync()
      : File("day_17_input.txt").readAsLinesSync());
  // Sample: x=495, y=2..7
  // Sample: y=7, x=495..501
  final rows = 14;
  final columns = 508;
  var grid = List.generate(rows, (_) => List<String>.filled(columns, '.'));

  for (var record in puzzleInput) {
    var recordSplit = record.split(',');
    var xRegex = RegExp(r'(x)=(\d*\.{0,2}\d+)');
    var xInput = xRegex.allMatches(record).elementAt(0).group(2);
    var yRegex = RegExp(r'(y)=(\d*\.{0,2}\d+)');
    var yInput = yRegex.allMatches(record).elementAt(0).group(2);
    if (DEBUG) print("x: $xInput   y: $yInput");

    var xRangeRegex = RegExp(r'(\d*)\.{0,2}(\d*)');
    var xRangeBegin =
        int.parse(xRangeRegex.allMatches(xInput).elementAt(0).group(1));
    int xRangeEnd;
    if (xRangeRegex.allMatches(xInput).elementAt(0).group(2).trim() == "") {
      xRangeEnd = xRangeBegin;
    } else {
      xRangeEnd =
          int.parse(xRangeRegex.allMatches(xInput).elementAt(0).group(2));
    }

    var yRangeRegex = RegExp(r'(\d*)\.{0,2}(\d*)');
    var yRangeBegin =
        int.parse(yRangeRegex.allMatches(yInput).elementAt(0).group(1));
    int yRangeEnd;
    if (yRangeRegex.allMatches(yInput).elementAt(0).group(2).trim() == "") {
      yRangeEnd = yRangeBegin;
    } else {
      yRangeEnd =
          int.parse(yRangeRegex.allMatches(yInput).elementAt(0).group(2));
    }

    if (DEBUG)
      print("x begin: $xRangeBegin x end: $xRangeEnd  "
          "y begin: $yRangeBegin y end: $yRangeEnd");

    for (var y = yRangeBegin; y <= yRangeEnd; ++y) {
      for (var x = xRangeBegin; x <= xRangeEnd; ++x) {
        grid[y][x] = '#';
      }
    }
  }

  grid[0][500] = '+';

  print('goDown: ${goDown(500, 0, grid)}');
}

int goDown(int x, int y, List<List<String>> grid) {
  if (y > 13 || grid[y][x] == '#') {
    // base case
    return 0;
  } else {
    grid[y][x] = '|';
    printGrid(grid);
    return 1 +
        goDown(x, y + 1, grid) +
        goLeft(x, y, grid) +
        goRight(x, y, grid);
  }
}

int goLeft(int x, int y, List<List<String>> grid) {
  if (y > 12 ||
      grid[y][x] == '#' ||
      (grid[y + 1][x + 1] != '#' && grid[y + 1][x] == '.') ||
      grid[y + 1][x] == '|') {
    // base case
    return -1;
  } else if (grid[y + 1][x + 1] == '#' && grid[y + 1][x] == '.') {
    return goDown(x, y, grid);
  } else {
    grid[y][x] = '|';
    printGrid(grid);
    return 1 + goLeft(x - 1, y, grid);
  }
}

int goRight(int x, int y, List<List<String>> grid) {
  if (y == 13) {
    // For debugging.  Set breakpoint below.
    print('y == 13');
  }
  if (y > 12 ||
      grid[y][x] == '#'
      ) {
    // base case
    checkIfSettled(x - 1, y, grid);
    return -1;
  }

  else if ((grid[y + 1][x - 1] != '#' && grid[y + 1][x] == '.') ||
      grid[y + 1][x] == '|') {return 1;}

  else if (grid[y + 1][x - 1] == '#' && grid[y + 1][x] == '.') {
    return goDown(x, y, grid);
  } else {
    grid[y][x] = '|';
    printGrid(grid);
    return 1 + goRight(x + 1, y, grid);
  }
}

void checkIfSettled(int x, int y, List<List<String>> grid) {
// Go backwards, if find # mark all as ~, if find '.', do nothing.
  int numberToGoBack = 0;
  int originalX = x;
  while (grid[y][x] != '#') {
    if (grid[y][x] == '.') {
      numberToGoBack = 0;
      break;
    }
    ++numberToGoBack;
    --x;
  }
  for (var i = 0; i < numberToGoBack; ++i) {
    grid[y][originalX - i] = '~';
  }
}

void printGrid(List<List<String>> grid, {int begin = 494, int end = 508}) {
  int rowNumber = 0;
  for (var row in grid) {
    var sb = StringBuffer();
    for (var element in row.sublist(begin, end)) {
      sb.write(element);
    }
    print("${rowNumber.toString().padLeft(2)} ${sb.toString()}");
    ++rowNumber;
  }
  print("\n");
}
