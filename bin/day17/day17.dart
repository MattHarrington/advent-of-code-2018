// https://adventofcode.com/2018/day/17

import 'dart:io';

const DEBUG = false;
const USE_SAMPLE_DATA = false;

int answer = 0;

main() {
  var puzzleInput = (USE_SAMPLE_DATA
      ? File("day_17_sample_input.txt").readAsLinesSync()
      : File("day_17_input.txt").readAsLinesSync());
  // Sample: x=495, y=2..7
  // Sample: y=7, x=495..501

  // TODO extract min/max from the puzzle input rather than manually
  int minY = (USE_SAMPLE_DATA ? 1 : 5);
  int maxY = (USE_SAMPLE_DATA ? 13 : 1841);

  final rows = maxY + 1;
  final columns = 700;
  var grid = List.generate(rows, (_) => List<String>.filled(columns, '.'));

  for (var record in puzzleInput) {
    // I really need to learn regular expressions. There must
    // be a better way than below.
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

  var partOneAnswer = goDown(500, minY, grid, maxY);
  if (USE_SAMPLE_DATA) {
    assert(partOneAnswer == 57);
  } else {
    assert(partOneAnswer == 35707);
  }

  displayGrid(grid, begin: 200, end: 700);
  print("Answer solved with recursion: $partOneAnswer");
  print("Answer solved by counting ~ and |: ${answerByCounting(grid)}");
  if (DEBUG) {
    saveGridToFile(File('grid_output.txt'), grid, begin: 250, end: 700);
  }
  
  var partTwoAnswer = countWaterAtRest(grid);
  if (USE_SAMPLE_DATA) {
    assert(partTwoAnswer == 29);
  } else {
    assert(partTwoAnswer == 29293);
  }
  print("Water at rest after spring runs dry: $partTwoAnswer");
}

/// Instead of using recursion, get answer by counting ~ and | in grid
int answerByCounting(List<List<String>> grid) {
  int result = 0;
  for (var row in grid) {
    for (var element in row) {
      if (element == '~' || element == '|') ++result;
    }
  }
  return result;
}

/// Count ~ in grid.  For part two.
int countWaterAtRest(List<List<String>> grid) {
  int result = 0;
  for (var row in grid) {
    for (var element in row) {
      if (element == '~') ++result;
    }
  }
  return result;
}

int goDown(int x, int y, List<List<String>> grid, int maxY) {
  if (y > maxY || grid[y][x] == '#' || grid[y][x] == '~' || grid[y][x] == '|') {
    // base case
    return 0;
  } else {
    grid[y][x] = '|';
    ++answer;
    if (DEBUG) displayGrid(grid);
    return 1 +
        goDown(x, y + 1, grid, maxY) +
        goLeft(x - 1, y, grid, maxY) +
        goRight(x + 1, y, grid, maxY);
  }
}

int goLeft(int x, int y, List<List<String>> grid, maxY) {
  if (y > maxY - 1) {
    // Too deep
    return 0;
  } else if (grid[y][x] == '#') {
    // Hit wall
    return 0;
  } else if (grid[y + 1][x + 1] != '#' && grid[y + 1][x] == '.') {
    // Can't go left if not falling off wall
    return 0;
  } else if (grid[y + 1][x] == '|') {
    // Can't go left if on top of flowing water
    return 0;
  } else if (grid[y + 1][x + 1] == '#' && grid[y + 1][x] == '.') {
    // Water flowed off wall, so go down
    return goDown(x, y, grid, maxY);
  } else if (grid[y][x] == '|' || grid[y][x] == '~') {
    // Already traversed this path in goRight()
    return 0;
  } else {
    grid[y][x] = '|';
    ++answer;
    if (DEBUG) displayGrid(grid);
    return 1 + goLeft(x - 1, y, grid, maxY);
  }
}

int goRight(int x, int y, List<List<String>> grid, int maxY) {
  if (y > maxY - 1) {
    // Too deep
    return 0;
  } else if (grid[y][x] == '#') {
    // Hit wall
    checkIfWaterSettled(x - 1, y, grid);
    return 0;
  } else if (grid[y + 1][x - 1] != '#' && grid[y + 1][x] == '.') {
    // Can't go right if not falling off wall
    return 0;
  } else if (grid[y + 1][x] == '|') {
    // Can't go right if on top of flowing water
    return 0;
  } else if (grid[y + 1][x - 1] == '#' && grid[y + 1][x] == '.') {
    // Water flowed off wall, so go down
    return goDown(x, y, grid, maxY);
  } else if (grid[y][x] == '|' || grid[y][x] == '~') {
    // Already traversed this path in goLeft()
    return 0;
  } else {
    grid[y][x] = '|';
    ++answer;
    if (DEBUG) displayGrid(grid);
    return 1 + goRight(x + 1, y, grid, maxY);
  }
}

/// Called when goRight() hits a wall. Go backwards through X,
/// and mark range with '~' if a wall is found.  If sand ('.') is found,
/// do nothing.
void checkIfWaterSettled(int x, int y, List<List<String>> grid) {
  int numberToGoBack = 0;
  int originalX = x;
  while (grid[y][x] != '#') {
    if (grid[y][x] == '.') {
      return;
    }
    ++numberToGoBack;
    --x;
  }
  for (var i = 0; i < numberToGoBack; ++i) {
    grid[y][originalX - i] = '~';
  }
}

/// Display grid between 2 X coordinates
void displayGrid(List<List<String>> grid, {int begin = 494, int end = 508}) {
  if (!USE_SAMPLE_DATA) {
    begin = 250;
    end = 700;
  }
  int rowNumber = 0;
  for (var row in grid) {
    var sb = StringBuffer();
    for (var element in row.sublist(begin, end)) {
      sb.write(element);
    }
    print("${rowNumber.toString().padLeft(4)} ${sb.toString()}");
    ++rowNumber;
  }
  print("answer: $answer\n");
}

/// Save grid to file for viewing in text editor, since it's huge.
void saveGridToFile(File fileName, List<List<String>> grid,
    {int begin = 494, int end = 508}) {
  var sink = fileName.openWrite();
  int rowNumber = 0;
  for (var row in grid) {
    var sb = StringBuffer();
    for (var element in row.sublist(begin, end)) {
      sb.write(element);
    }
    sink.writeln("${rowNumber.toString().padLeft(4)} ${sb.toString()}");
    ++rowNumber;
  }
  sink.writeln("answer: $answer");
  sink.close();
}
