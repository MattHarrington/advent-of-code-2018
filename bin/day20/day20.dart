// https://adventofcode.com/2018/day/20

import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:quiver/core.dart';

const DEBUG = false;
const USE_SAMPLE_DATA = false;

/// Used in method 1
class Node {
  String value;
  Node parent;
  List<Node> children;
  bool visited = false;
  static int length = 0;

  Node(this.value) {
    children = List<Node>();
    ++length;
  }

  Node.withParent(String value, Node parent) {
    this.value = value;
    this.parent = parent;
    children = List<Node>();
    ++length;
  }

  void addChild(Node child) {
    children.add(child);
  }

  int distanceTo(Node ancestor) {
    if (parent == null) return 1;
    int distance = 2;

    var currentNode = this;
    while (currentNode.parent != ancestor) {
      currentNode = currentNode.parent;
      ++distance;
    }
    return distance;
  }

  int get height {
    if (value == '') {
      return -1000; // Can be large negative number since it's passed to max()
    }
    int maxHeight = 0;

    for (var child in children) {
      maxHeight = max(maxHeight, child.height);
    }
    if (DEBUG) stdout.write(value);
    return maxHeight + 1;
  }
}

/// Room with (x,y) coordinates.  Used as key in method 2.
class Room {
  int x, y;

  Room(this.x, this.y);

  @override
  bool operator ==(o) => o is Room && x == o.x && y == o.y;

  @override
  int get hashCode => hash2(x.hashCode, y.hashCode);

  @override
  toString() => "($x,$y)";
}

main() {
  /*
  Examples:
  ^WNE$ -> 3
  ^ENWWW(NEEE|SSE(EE|N))$ -> 10
  ^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$ -> 18
  ^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$ -> 23
  ^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$ -> 31
   */
  var sampleA = r'^N(E|W)N$'; // Solution fails with this input
  var sample3 = r'^WNE$';
  var sample10 = r'^ENWWW(NEEE|SSE(EE|N))$';
  var sample18 = r'^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$';
  var sample23 = r'^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$';
  var sample31 =
      r'^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$';

  var puzzleInput = (USE_SAMPLE_DATA
      ? sample18
      : File('day_20_input.txt').readAsStringSync());

  /*
   Method 1: build n-ary tree.  Height is part 1 answer.
   Part 2 answer should be BFS, calculate distance from node to root, return
   nodes with distance >= 1000.  However, there appears to be a bug.
   Gave up and used method 2.
   */

  // Deal with "empty options" like "(WNSE|)".
  // All empty options appear to retrace their steps
  // and end up where they started. Cutting empty options
  // in half allows them to be accurately added to the tree.
  final emptyOptionRegex = RegExp(r'\([NEWS|]*\|\)');
  final modifiedPuzzleInput =
      puzzleInput.replaceAllMapped(emptyOptionRegex, (Match m) {
    int halfway = (m.group(0).length / 2).truncate();
    return '${m.group(0).substring(0, halfway)})';
  });

  final tree = buildTree(modifiedPuzzleInput);

  final height = tree.height;
  if (!USE_SAMPLE_DATA) assert(height == 4778);
  print('\nPart one answer, method 1: $height');

  final numDoorsList = bfsDistances(tree);
  final numberOfFarAwayRooms1 = numDoorsList.where((d) => d >= 1000).length;

  print('Rooms >= 1000 doors away, method 1: $numberOfFarAwayRooms1');

  /*
   Method 2.  Traverse puzzle input and store distance from start in a map.
   If the map already contains a key, reset the distance since we've already
   been to that position.  Part 1 answer is room with greatest distance.
   Part 2 answer is number of rooms >= 1000 doors away.
   */

  final maze = exploreRooms(puzzleInput);
  final method2MaxDistance = maze.values.reduce(max);
  print('Part one answer, method 2: $method2MaxDistance');
  if (!USE_SAMPLE_DATA) assert(method2MaxDistance == 4778);
  final numberOfFarAwayRooms2 = maze.values.where((d) => d >= 1000).length;
  print('Rooms >= 1000 doors away, method 2: $numberOfFarAwayRooms2');
  if (!USE_SAMPLE_DATA) assert(numberOfFarAwayRooms2 == 8459);
}

/// Explore all rooms in puzzleInput.  Return map of room -> distance
/// from start.
Map<Room, int> exploreRooms(String puzzleInput) {
  var maze = Map<Room, int>();
  var stack = Queue<Room>();
  Room currentRoom;
  var distance = 0;

  for (var i = 0; i < puzzleInput.length; ++i) {
    switch (puzzleInput[i]) {
      case '^':
        // First room
        currentRoom = Room(0, 0);
        break;
      case '(':
        stack.addFirst(Room(currentRoom.x, currentRoom.y)); // push
        break;
      case '|':
        // Instantiate new room, otherwise you'll
        // change values on stack while peeking.
        currentRoom = Room(stack.first.x, stack.first.y); // peek
        break;
      case ')':
        currentRoom = stack.removeFirst(); // pop
        break;
      case 'N':
        --currentRoom.y;
        break;
      case 'E':
        ++currentRoom.x;
        break;
      case 'W':
        --currentRoom.x;
        break;
      case 'S':
        ++currentRoom.y;
        break;
      case r'$':
        // Last room
        break;
      case '\n':
        // When reading string from a file, Dart appears to append a newline
        break;
      default:
        throw "Should never be here";
        break;
    }

    if (maze.containsKey(currentRoom)) {
      // Have already visited this room
      distance = maze[currentRoom];
    } else {
      // Add new room
      maze[Room(currentRoom.x, currentRoom.y)] = distance;
    }
    ++distance;
  }

  return maze;
}

/// Return a tree given puzzle input.
/// Uses a stack to hold parent node when
/// adding children.
Node buildTree(String puzzleInput) {
  var rootNode = Node(puzzleInput[1]);
  var currentNode = rootNode;

  var stack = Queue<Node>();

  for (var i = 2; i < puzzleInput.length - 1; ++i) {
    if (puzzleInput[i] == '(') {
      stack.addFirst(currentNode); // push
    } else if (puzzleInput[i] == '|') {
      currentNode = stack.first; // peek
    } else if (puzzleInput[i] == ')') {
      currentNode = stack.removeFirst(); // pop
    } else {
      var childNode = Node.withParent(puzzleInput[i], currentNode);
      currentNode.addChild(childNode);
      currentNode = childNode;
    }
  }

  return rootNode;
}

/// Traverse tree with breadth first search.
/// Return list of distances of each node to root.
List<int> bfsDistances(Node root) {
  var depths = List<int>();
  var stack = Queue<Node>();
  stack.addFirst(root);
  while (stack.isNotEmpty) {
    var currentNode = stack.removeFirst();
    for (var child in currentNode.children) {
      if (child.visited == false) stack.addFirst(child);
    }
    depths.add(currentNode.distanceTo(root));
    currentNode.visited = true;
  }
  assert(depths.length == Node.length);
  return depths;
}
