// https://adventofcode.com/2018/day/20

import 'dart:collection';
import 'dart:io';
import 'dart:math';

const DEBUG = false;
const USE_SAMPLE_DATA = true;

class Node {
  String direction;
  List<Node> children;

  Node(this.direction) {
    children = List<Node>();
  }

  void addChild(Node child) {
    children.add(child);
  }

  static int depthOfTree(Node node) {
    if (node.direction == r'$') {
      return -1000;
    }
    int maxDepth = 0;

    for (var child in node.children) {
      maxDepth = max(maxDepth, depthOfTree(child));
    }
    stdout.write(node.direction);
    return maxDepth + 1;
  }

  @override
  toString() => '';
}

main() {
  /*
  Examples:
  ^WNE$ -> 3
  ^ENWWW(NEEE|SSE(EE|N))$ -> 10
  ^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$ -> 18 (mine is wrong)
  ^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$ -> 23
  ^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$ -> 31
   */
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

  // Deal with "empty options"
  var emptyOptionRegex = RegExp(r'\([NEWS|]*\|\)');
//  puzzleInput = puzzleInput.replaceAll(emptyOptionRegex, '');

  puzzleInput = puzzleInput.replaceAllMapped(emptyOptionRegex, (Match m) {
    int halfway = (m.group(0).length / 2).truncate();
    return '${m.group(0).substring(0, halfway)})';
  });

  if (DEBUG) print('New puzzle input: $puzzleInput');

  var puzzleStack = Queue<String>();
  for (var i = 1; i < puzzleInput.length; ++i) {
    puzzleStack.add(puzzleInput[i]);
  }

  var firstNode = Node(puzzleStack.removeFirst());
  buildTree(firstNode, puzzleStack);
  var depth = Node.depthOfTree(firstNode);
  print('\nDepth: $depth');
}

void buildTree(Node node, Queue<String> stack) {
  if (stack.isEmpty) return;
  var next = stack.removeFirst();
//  if (next == r'$') return;
//  if (next == ' ') return;
  if (next == '|') return;
  if (next == ')') return;
  if (next == '(') {
    // children
    buildTree(node, stack);
//    if (stack.isEmpty) {
//      print("empty stack?");
//      return;
//    }
//    do {
//      next = stack.removeFirst();
//    } while (next == ')');
//    while (next == '|') next = stack.removeFirst();
//  next = stack.removeFirst();
//  if (next == '|') next = stack.removeFirst();
//  next = stack.removeFirst();
    stack.add(next);
  return;
  }
  var newNode = Node(next);
  node.addChild(newNode);
  buildTree(newNode, stack);
}

// 4724 too low
// 5019 too high
