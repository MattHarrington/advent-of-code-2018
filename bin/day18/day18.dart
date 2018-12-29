// https://adventofcode.com/2018/day/18

import 'dart:io';

const USE_SAMPLE_DATA = false;

main() {
  final puzzleInput = USE_SAMPLE_DATA
      ? File('day_18_sample_input.txt').readAsLinesSync()
      : File('day_18_input.txt').readAsLinesSync();

  final rows = puzzleInput.length;
  final columns = puzzleInput.first.length;
  var grid = List.generate(rows, (_) => List<String>.filled(columns, ' '));
  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      grid[y][x] = puzzleInput[y][x];
    }
  }

  int clock = 0;
  print('After $clock minutes:');
  printGrid(grid);

  do {
    var newGrid = List.generate(rows, (_) => List<String>.filled(columns, ' '));
    for (var y = 0; y < rows; ++y) {
      for (var x = 0; x < columns; ++x) {
        var next = grid[y][x];
        switch (grid[y][x]) {
          case '.':
            // Open ground
            if (groundBecomesTree(x, y, grid)) next = '|';
            break;
          case '|':
            // Trees
            if (treeBecomesLumberyard(x, y, grid)) next = '#';
            break;
          case '#':
            // Lumberyard
            if (lumberyardRemainsLumberyard(x, y, grid)) {
              next = '#';
            } else {
              next = '.';
            }
            break;
          default:
            throw 'Should never be here';
            break;
        }
        newGrid[y][x] = next;
      }
    }
    ++clock;
    if (clock % 10000 == 0) {
      print('After $clock minutes:');
      print('--> Resources: ${computeResources(newGrid)}');
//      printGrid(newGrid);
    }
    grid = copyGrid(newGrid);
  } while (clock < 1000000000);
}

int computeResources(List<List<String>> grid) {
  var treeCount = 0;
  var lumberyardCount = 0;
  for (var row in grid) {
    for (var acre in row) {
      if (acre == '|') ++treeCount;
      if (acre == '#') ++lumberyardCount;
    }
  }
  return treeCount * lumberyardCount;
}

List<List<String>> copyGrid(List<List<String>> grid) {
  final rows = grid.length;
  final columns = grid.first.length;
  var newGrid = List.generate(rows, (_) => List<String>.filled(columns, ' '));
  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      newGrid[y][x] = grid[y][x];
    }
  }
  return newGrid;
}

bool groundBecomesTree(int x, int y, List<List<String>> grid) {
  assert(grid[y][x] == '.');
  final rows = grid.length;
  final columns = grid.first.length;

  var treeCount = 0;
  if (x > 0 && y > 0 && grid[y - 1][x - 1] == '|') ++treeCount;
  if (y > 0 && grid[y - 1][x] == '|') ++treeCount;
  if (x < columns - 1 && y > 0 && grid[y - 1][x + 1] == '|') ++treeCount;
  if (x > 0 && grid[y][x - 1] == '|') ++treeCount;
  if (x < columns - 1 && grid[y][x + 1] == '|') ++treeCount;
  if (x > 0 && y < rows - 1 && grid[y + 1][x - 1] == '|') ++treeCount;
  if (y < rows - 1 && grid[y + 1][x] == '|') ++treeCount;
  if (x < columns - 1 && y < rows - 1 && grid[y + 1][x + 1] == '|') ++treeCount;
  if (treeCount >= 3) {
    return true;
  } else {
    return false;
  }
}

bool treeBecomesLumberyard(int x, int y, List<List<String>> grid) {
  assert(grid[y][x] == '|');
  final rows = grid.length;
  final columns = grid.first.length;

  var lumberyardCount = 0;
  if (x > 0 && y > 0 && grid[y - 1][x - 1] == '#') ++lumberyardCount;
  if (y > 0 && grid[y - 1][x] == '#') ++lumberyardCount;
  if (x < columns - 1 && y > 0 && grid[y - 1][x + 1] == '#') ++lumberyardCount;
  if (x > 0 && grid[y][x - 1] == '#') ++lumberyardCount;
  if (x < columns - 1 && grid[y][x + 1] == '#') ++lumberyardCount;
  if (x > 0 && y < rows - 1 && grid[y + 1][x - 1] == '#') ++lumberyardCount;
  if (y < rows - 1 && grid[y + 1][x] == '#') ++lumberyardCount;
  if (x < columns - 1 && y < rows - 1 && grid[y + 1][x + 1] == '#')
    ++lumberyardCount;
  if (lumberyardCount >= 3) {
    return true;
  } else {
    return false;
  }
}

bool lumberyardRemainsLumberyard(int x, int y, List<List<String>> grid) {
  assert(grid[y][x] == '#');
  final rows = grid.length;
  final columns = grid.first.length;

  var lumberyardCount = 0;
  if (x > 0 && y > 0 && grid[y - 1][x - 1] == '#') ++lumberyardCount;
  if (y > 0 && grid[y - 1][x] == '#') ++lumberyardCount;
  if (x < columns - 1 && y > 0 && grid[y - 1][x + 1] == '#') ++lumberyardCount;
  if (x > 0 && grid[y][x - 1] == '#') ++lumberyardCount;
  if (x < columns - 1 && grid[y][x + 1] == '#') ++lumberyardCount;
  if (x > 0 && y < rows - 1 && grid[y + 1][x - 1] == '#') ++lumberyardCount;
  if (y < rows - 1 && grid[y + 1][x] == '#') ++lumberyardCount;
  if (x < columns - 1 && y < rows - 1 && grid[y + 1][x + 1] == '#')
    ++lumberyardCount;

  var treeCount = 0;
  if (x > 0 && y > 0 && grid[y - 1][x - 1] == '|') ++treeCount;
  if (y > 0 && grid[y - 1][x] == '|') ++treeCount;
  if (x < columns - 1 && y > 0 && grid[y - 1][x + 1] == '|') ++treeCount;
  if (x > 0 && grid[y][x - 1] == '|') ++treeCount;
  if (x < columns - 1 && grid[y][x + 1] == '|') ++treeCount;
  if (x > 0 && y < rows - 1 && grid[y + 1][x - 1] == '|') ++treeCount;
  if (y < rows - 1 && grid[y + 1][x] == '|') ++treeCount;
  if (x < columns - 1 && y < rows - 1 && grid[y + 1][x + 1] == '|') ++treeCount;

  if (lumberyardCount >= 1 && treeCount >= 1) {
    return true;
  } else {
    return false;
  }
}

void printGrid(List<List<String>> grid) {
  final rows = grid.length;
  final columns = grid.first.length;
  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      stdout.write(grid[y][x]);
    }
    stdout.writeln();
  }
  print('');
}

// 207998 correct
