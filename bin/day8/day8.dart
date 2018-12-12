// https://adventofcode.com/2018/day/8

import "dart:io";

class Node {
  // Makes more sense if header is int, but doesn't improve code
  // and eliminates need for int.parse() and arithmetic.
  String header; // 1st digit: # of children, 2nd digit: # of metadata entries
  List<Node> children; // Zero or more
  List<int> metadata; // One or more
  int get value {
    // See part 2 of puzzle description for definition of "value".
    int sum = 0;
    if (children.length != 0) {
      for (var childNumber in metadata) {
        if (childNumber > children.length) continue; // Child number is invalid
        var child = children[childNumber - 1];
        sum += child.value;
      }
    } else {
      sum += metadata.reduce((a, b) => a + b);
    }
    return sum;
  }

  Node(List<int> headerList) {
    header = headerList.toString();
    children = List<Node>();
    metadata = List<int>();
  }

  void addChild(Node child) {
    children.add(child);
  }

  void addMetadata(int m) {
    metadata.add(m);
  }
}

main() {
  var input = File("day_8_input.txt").readAsStringSync();
//  var input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"; // Sample input
  var array = input.split(' ');
  var intArray = array.map((n) => int.parse(n)).toList();
  print("Puzzle input length: ${intArray.length}");

  int index = 0;
  int metadataSum = 0;

  Node deserialize(List<int> intArray) {
    if (intArray[index] == 0) {
      // Base case. Node has no children.
      var headerList = intArray.sublist(index, index + 2);

      var childlessNode = Node(headerList);
      var numberOfMetadataEntries = intArray[index + 1];
      index = index + 2;

      for (var m = 0; m < numberOfMetadataEntries; ++m) {
        var metaDataEntry = intArray[index];
        childlessNode.addMetadata(metaDataEntry);
        metadataSum += metaDataEntry;
        ++index;
      }

      return childlessNode;
    }

    Node root = Node(intArray.sublist(index, index + 2));
    var numberOfChildren = intArray[index];
    var numberOfMetadataEntries = intArray[index + 1];
    index = index + 2;

    for (var c = 0; c < numberOfChildren; ++c) {
      // Add children
      Node childNode = deserialize(intArray);
      root.addChild(childNode);
    }

    for (var m = 0; m < numberOfMetadataEntries; ++m) {
      // Add metadata
      var metaDataEntry = intArray[index];
      root.addMetadata(metaDataEntry);
      metadataSum += metaDataEntry;
      ++index;
    }

    return root;
  }

  var root = deserialize(intArray);

  print("Metadata sum: ${metadataSum}");
  print("Root value: ${root.value}");
}
