// https://adventofcode.com/2018/day/20

import 'dart:collection';
import 'dart:io';
import 'dart:math';

const DEBUG = false;
const USE_SAMPLE_DATA = false;

class Node {
  String value;
  List<Node> children;

  Node(this.value) {
    children = List<Node>();
  }

  void addChild(Node child) {
    children.add(child);
  }

  int get depth {
    if (value == r'$') {
      return -1000; // Can be large negative number since it's passed to max()
    }
    int maxDepth = 0;

    for (var child in children) {
      maxDepth = max(maxDepth, child.depth);
    }
    if (DEBUG) stdout.write(value);
    return maxDepth + 1;
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

  var puzzleInput =
      (USE_SAMPLE_DATA ? sample18 : File('day_20_input.txt').readAsStringSync());

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

  var depth = tree.depth;
  if (!USE_SAMPLE_DATA) assert(depth == 4778);
  print('\nPart one answer: $depth');
}

/// Return a tree given puzzle input.
/// Uses a stack to hold parent node when
/// adding children.
Node buildTree(String puzzleInput) {
  var rootNode = Node(puzzleInput[1]);
  var currentNode = rootNode;

  var stack = Queue<Node>();

  for (var i = 2; i < puzzleInput.length; ++i) {
    if (puzzleInput[i] == '(') {
      stack.addFirst(currentNode); // push
    }

    if (puzzleInput[i] == '|') {
      currentNode = stack.first; // peek
    }

    if (puzzleInput[i] == ')') {
      currentNode = stack.removeFirst(); // pop
    }

    if ('NEWS'.contains(puzzleInput[i])) {
      var childNode = Node(puzzleInput[i]);
      currentNode.addChild(childNode);
      currentNode = childNode;
    }
  }

  return rootNode;
}
