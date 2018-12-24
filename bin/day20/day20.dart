// https://adventofcode.com/2018/day/20

import 'dart:collection';
import 'dart:io';
import 'dart:math';

const DEBUG = false;
const USE_SAMPLE_DATA = false;

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
      ? sample10
      : File('day_20_input.txt').readAsStringSync());

  if (DEBUG) print('Original puzzle input: $puzzleInput');

  // Deal with "empty options" like "(WNSE|)".
  // All empty options appear to retrace their steps
  // and end up where they started. Cutting empty options
  // in half allows them to be accurately added to the tree.
  var emptyOptionRegex = RegExp(r'\([NEWS|]*\|\)');
  puzzleInput = puzzleInput.replaceAllMapped(emptyOptionRegex, (Match m) {
    int halfway = (m.group(0).length / 2).truncate();
    return '${m.group(0).substring(0, halfway)})';
  });

  var tree = buildTree(puzzleInput);

  var height = tree.height;
  if (!USE_SAMPLE_DATA) assert(height == 4778);
  print('\nPart one answer: $height');

  // Part two

  var numDoorsList = bfsDistances(tree);
  var numberOfFarAwayRooms = numDoorsList.where((d) => d >= 1000).length;

//  if (!USE_SAMPLE_DATA) assert(numberOfFarAwayRooms == 8459);

  print('Far away rooms: $numberOfFarAwayRooms');
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
