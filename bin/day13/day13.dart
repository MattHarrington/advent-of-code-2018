// https://adventofcode.com/2018/day/13

import 'dart:io';
import 'package:uuid/uuid.dart';

const DEBUG = false;
const USE_SAMPLE_DATA = true;

enum NextDirection { left, straight, right }

enum State { up, down, left, right }

class Cart extends Comparable<Cart> {
  int x, y;
  State state;
  NextDirection nextDirection;
  final String id;

  void atIntersection() {
    if (nextDirection != NextDirection.straight) _setNewState();

    int newIndex = (nextDirection.index + 1) % 3;
    switch (newIndex) {
      case 0:
        nextDirection = NextDirection.left;
        break;
      case 1:
        nextDirection = NextDirection.straight;
        break;
      case 2:
        nextDirection = NextDirection.right;
        break;
      default:
        throw Exception("Should never be here");
    }
  }

  void _setNewState() {
    if (state == State.down && nextDirection == NextDirection.right) {
      state = State.left;
    } else if (state == State.down && nextDirection == NextDirection.left) {
      state = State.right;
    } else if (state == State.up && nextDirection == NextDirection.left) {
      state = State.left;
    } else if (state == State.up && nextDirection == NextDirection.right) {
      state = State.right;
    } else if (state == State.left && nextDirection == NextDirection.left) {
      state = State.down;
    } else if (state == State.left && nextDirection == NextDirection.right) {
      state = State.up;
    } else if (state == State.right && nextDirection == NextDirection.left) {
      state = State.up;
    } else if (state == State.right && nextDirection == NextDirection.right) {
      state = State.down;
    }
  }

  Cart(this.x, this.y, this.state) : id = Uuid().v4() {
    nextDirection = NextDirection.left;
  }

  @override
  int compareTo(Cart other) {
    if (y < other.y) {
      return -1;
    } else if (y > other.y) {
      return 1;
    } else if (x < other.x) {
      return -1;
    } else if (x > other.x) {
      return 1;
    } else if (y == other.y && x == other.x) {
      return 0;
    }
    return null;
  }

  @override
  String toString() => "$state";
}

var carts = List<Cart>();

main() {
  var puzzleInput = (USE_SAMPLE_DATA
      ? File("day_13_sample_input.txt").readAsLinesSync()
      : File("day_13_input.txt").readAsLinesSync());

  final rows = puzzleInput.length;
  final columns = puzzleInput.first.length;
  var grid = List.generate(rows, (_) => List<String>.filled(columns, ' '));

  for (var y = 0; y < rows; ++y) {
    for (var x = 0; x < columns; ++x) {
      var point = puzzleInput[y][x];
      switch (point) {
        case '^':
          carts.add(Cart(x, y, State.up));
          grid[y][x] = "|";
          break;
        case 'v':
          carts.add(Cart(x, y, State.down));
          grid[y][x] = "|";
          break;
        case '<':
          carts.add(Cart(x, y, State.left));
          grid[y][x] = "-";
          break;
        case '>':
          carts.add(Cart(x, y, State.right));
          grid[y][x] = "-";
          break;
        default:
          grid[y][x] = puzzleInput[y][x];
          break;
      }
    }
  }

  if (DEBUG) printGrid(grid);

  int tick = 0;
  var loop = true;
  while (loop) {
    // Sort carts
    carts.sort();
    // Move carts
    for (var cart in carts) {
      moveCart(cart, grid);
      // Check for collision
      if (collisionHappened(cart, grid)) {
        if (USE_SAMPLE_DATA) {assert(cart.x == 7 && cart.y == 3);}
        else {assert(cart.x == 139 && cart.y == 65);}

        print("Collision at: (${cart.x}, ${cart.y})");
        loop = false;
        break;
      }
    }

    ++tick;
  }
}

void moveCart(Cart cart, List<List<String>> grid) {
  if (cart.state == State.up) {
    switch (grid[cart.y - 1][cart.x]) {
      case '-':
        throw Exception("Should never be here");
      case '|':
        --cart.y;
        break;
      case r'\':
        --cart.y;
        cart.state = State.left;
        break;
      case '/':
        --cart.y;
        cart.state = State.right;
        break;
      case '+':
        --cart.y;
        cart.atIntersection();
        break;
      default:
        throw Exception("Should never be here");
        break;
    }
  } else if (cart.state == State.down) {
    switch (grid[cart.y + 1][cart.x]) {
      case '-':
        throw Exception("Should never be here");
      case '|':
        ++cart.y;
        break;
      case r'\':
        ++cart.y;
        cart.state = State.right;
        break;
      case '/':
        ++cart.y;
        cart.state = State.left;
        break;
      case '+':
        ++cart.y;
        cart.atIntersection();
        break;
      default:
        throw Exception("Should never be here");
        break;
    }
  } else if (cart.state == State.left) {
    switch (grid[cart.y][cart.x - 1]) {
      case '|':
        throw Exception("Should never be here");
        break;
      case '-':
        --cart.x;
        break;
      case r'\':
        --cart.x;
        cart.state = State.up;
        break;
      case '/':
        --cart.x;
        cart.state = State.down;
        break;
      case '+':
        --cart.x;
        cart.atIntersection();
        break;
      default:
        throw Exception("Should never be here");
        break;
    }
  } else if (cart.state == State.right) {
    switch (grid[cart.y][cart.x + 1]) {
      case '|':
        throw Exception("Should never be here");
        break;
      case '-':
        ++cart.x;
        break;
      case r'\':
        ++cart.x;
        cart.state = State.down;
        break;
      case '/':
        ++cart.x;
        cart.state = State.up;
        break;
      case '+':
        ++cart.x;
        cart.atIntersection();
        break;
      default:
        throw Exception("Should never be here");
        break;
    }
  }
}

bool collisionHappened(Cart justMovedCart, List<List<String>> grid) {
  return carts.any((cart) =>
      cart.id != justMovedCart.id &&
      cart.x == justMovedCart.x &&
      cart.y == justMovedCart.y);
}

void printGrid(List<List<String>> grid) {
  for (var row in grid) {
    print(row);
  }
}
