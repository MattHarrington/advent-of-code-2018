// https://adventofcode.com/2018/day/13

import 'dart:io';
import 'package:uuid/uuid.dart';

const DEBUG = false;
const USE_SAMPLE_DATA = false;

enum Direction { left, straight, right }

enum Heading { up, down, left, right }

class Cart extends Comparable<Cart> {
  int x, y;
  Heading heading;
  Direction directionAtNextIntersection;
  final String id;

  void atIntersection() {
    if (directionAtNextIntersection != Direction.straight) _setNewState();

    int newIndex = (directionAtNextIntersection.index + 1) % 3;
    switch (newIndex) {
      case 0:
        directionAtNextIntersection = Direction.left;
        break;
      case 1:
        directionAtNextIntersection = Direction.straight;
        break;
      case 2:
        directionAtNextIntersection = Direction.right;
        break;
      default:
        throw Exception("Should never be here");
    }
  }

  void _setNewState() {
    if (heading == Heading.down &&
        directionAtNextIntersection == Direction.right) {
      heading = Heading.left;
    } else if (heading == Heading.down &&
        directionAtNextIntersection == Direction.left) {
      heading = Heading.right;
    } else if (heading == Heading.up &&
        directionAtNextIntersection == Direction.left) {
      heading = Heading.left;
    } else if (heading == Heading.up &&
        directionAtNextIntersection == Direction.right) {
      heading = Heading.right;
    } else if (heading == Heading.left &&
        directionAtNextIntersection == Direction.left) {
      heading = Heading.down;
    } else if (heading == Heading.left &&
        directionAtNextIntersection == Direction.right) {
      heading = Heading.up;
    } else if (heading == Heading.right &&
        directionAtNextIntersection == Direction.left) {
      heading = Heading.up;
    } else if (heading == Heading.right &&
        directionAtNextIntersection == Direction.right) {
      heading = Heading.down;
    }
  }

  Cart(this.x, this.y, this.heading) : id = Uuid().v4() {
    directionAtNextIntersection = Direction.left;
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
  String toString() => "($x, $y) $heading";
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
          carts.add(Cart(x, y, Heading.up));
          grid[y][x] = "|";
          break;
        case 'v':
          carts.add(Cart(x, y, Heading.down));
          grid[y][x] = "|";
          break;
        case '<':
          carts.add(Cart(x, y, Heading.left));
          grid[y][x] = "-";
          break;
        case '>':
          carts.add(Cart(x, y, Heading.right));
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
    for (var cart in carts.toList()) {
      moveCart(cart, grid);
      // Check for collision
      if (collisionCheck(cart, grid, removeCollidedCarts: true)) {
//        if (USE_SAMPLE_DATA) {
//          assert(cart.x == 7 && cart.y == 3);
//        } else {
//          assert(cart.x == 139 && cart.y == 65);
//        }
        print("Collision at: (${cart.x}, ${cart.y}) at tick: $tick");
      }
    }
    if (carts.length == 1) {
      loop = false;
      print("Last cart position: ${carts.first.x}, ${carts.first.y}");
    }

    ++tick;
  }
}

void moveCart(Cart cart, List<List<String>> grid) {
  if (cart.heading == Heading.up) {
    switch (grid[cart.y - 1][cart.x]) {
      case '-':
        throw Exception("Should never be here");
      case '|':
        --cart.y;
        break;
      case r'\':
        --cart.y;
        cart.heading = Heading.left;
        break;
      case '/':
        --cart.y;
        cart.heading = Heading.right;
        break;
      case '+':
        --cart.y;
        cart.atIntersection();
        break;
      default:
        throw Exception("Should never be here");
        break;
    }
  } else if (cart.heading == Heading.down) {
    switch (grid[cart.y + 1][cart.x]) {
      case '-':
        throw Exception("Should never be here");
      case '|':
        ++cart.y;
        break;
      case r'\':
        ++cart.y;
        cart.heading = Heading.right;
        break;
      case '/':
        ++cart.y;
        cart.heading = Heading.left;
        break;
      case '+':
        ++cart.y;
        cart.atIntersection();
        break;
      default:
        throw Exception("Should never be here");
        break;
    }
  } else if (cart.heading == Heading.left) {
    switch (grid[cart.y][cart.x - 1]) {
      case '|':
        throw Exception("Should never be here");
        break;
      case '-':
        --cart.x;
        break;
      case r'\':
        --cart.x;
        cart.heading = Heading.up;
        break;
      case '/':
        --cart.x;
        cart.heading = Heading.down;
        break;
      case '+':
        --cart.x;
        cart.atIntersection();
        break;
      default:
        throw Exception("Should never be here");
        break;
    }
  } else if (cart.heading == Heading.right) {
    switch (grid[cart.y][cart.x + 1]) {
      case '|':
        throw Exception("Should never be here");
        break;
      case '-':
        ++cart.x;
        break;
      case r'\':
        ++cart.x;
        cart.heading = Heading.down;
        break;
      case '/':
        ++cart.x;
        cart.heading = Heading.up;
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

bool collisionCheck(Cart justMovedCart, List<List<String>> grid,
    {bool removeCollidedCarts = false}) {
  var collidedCart = carts.firstWhere(
      (cart) =>
          cart.id != justMovedCart.id &&
          cart.x == justMovedCart.x &&
          cart.y == justMovedCart.y,
      orElse: () => null);
  if (collidedCart == null) {
    return false;
  } else if (collidedCart != null && removeCollidedCarts == true) {
    carts.remove(collidedCart);
    carts.remove(justMovedCart);
  }
  return true;
}

void printGrid(List<List<String>> grid) {
  for (var row in grid) {
    print(row);
  }
}

// Not correct part 2: 118,48 or 117,48

// Correct: (40,77)
