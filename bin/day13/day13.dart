// https://adventofcode.com/2018/day/13
import 'dart:io';

const DEBUG = true;
const USE_SAMPLE_DATA = true;

enum Direction { left, straight, right }

class Cart {
  int x, y;
  String state;
  Direction heading;

  // TODO decide to turn left, go straight, or turn right at an intersection

  Cart(this.x, this.y, this.state) {
    heading = Direction.straight;
  }
}

main() {
  var puzzleInput = (USE_SAMPLE_DATA
      ? File("day_13_sample_input.txt").readAsLinesSync()
      : File("day_13_input.txt").readAsLinesSync());

  final rows = puzzleInput.length;
  final columns = puzzleInput.first.length;
  var grid = List.generate(rows, (_) => new List<String>.filled(columns, ' '));

  var carts = List<Cart>();

  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      var point = puzzleInput[y][x];
      if (point == "^" || point == "v") {
        carts.add(Cart(x, y, point));
        grid[y][x] = "|";
      } else if (point == "<" || point == ">") {
        carts.add(Cart(x, y, point));
        grid[y][x] = "-";
      } else {
        grid[y][x] = puzzleInput[y][x];
      }
    }
  }

  if (DEBUG) {
    for (var row in grid) {
      print(row);
    }
  }

  int tick = 0;
  while (true) {
    // Move carts
    // Check for collision
    for (var cart in carts) {
      if (cart.state == "^") {
        ++cart.y;
      } else if (cart.state == "v") {
        --cart.y;
      } else if (cart.state == "<") {
        --cart.x;
      } else if (cart.state == ">") {
        ++cart.x;
      }
    }
    var collision = true;
    if (collision) break;
    ++tick;
  }
}

void moveCart(Cart cart, List<List<String>> grid) {
  if (cart.state == "^") {
    switch (grid[cart.y - 1][cart.x]) {
      case '|':
        --cart.y;
        break;
      case r'\':
        --cart.y;
        cart.heading = Direction.left;
        break;
      case '/':
        --cart.y;
        cart.heading = Direction.right;
        break;
      case '+':
        --cart.y;
        cart.heading = Direction.left;
        break;
      default:
        print("Should never be here");
        break;
    }
  } else if (cart.state == "v") {
//    --cart.y;
  } else if (cart.state == "<") {
//    --cart.x;
  } else if (cart.state == ">") {
//    ++cart.x;
  }
}
