// https://adventofcode.com/2018/day/7
// Solution based on Kahn's algorithm: https://youtu.be/_LuIvEi_kZk

import 'dart:io';
import 'dart:collection';

main() {
  const USING_SAMPLE_DATA = false;
  List<String> input;
  String vertices;
  String publishedPartOneAnswer, publishedPartTwoAnswer;
  if (USING_SAMPLE_DATA) {
    input = File("day_7_sample_input.txt").readAsLinesSync();
    vertices = "ABCDEF";
    publishedPartOneAnswer = "CABDFE";
    publishedPartTwoAnswer = "15";
  } else {
    input = File("day_7_input.txt").readAsLinesSync();
    vertices = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    publishedPartOneAnswer = "FMOXCDGJRAUIHKNYZTESWLPBQV";
    publishedPartTwoAnswer = "1053";
  }
  // Sample: "Step N must be finished before step E can begin."

  var dag = Map<String, List<String>>();

  for (var record in input) {
    var splitRecord = record.split(" ");
    var v1 = splitRecord[1];
    var v2 = splitRecord[7];
    dag.putIfAbsent(v1, () => List<String>());
    dag[v1].add(v2); // Adjacency list
  }

  var sw = Stopwatch();
  sw.start();
  var myPartOneAnswer = partOneSolution(dag, vertices);
  sw.stop();
  print("Part one takes ${sw.elapsedMilliseconds} milliseconds");
  assert(myPartOneAnswer == publishedPartOneAnswer);

  sw.reset();
  sw.start();
  var myPartTwoAnswer = partTwoSolution(dag, vertices, USING_SAMPLE_DATA);
  sw.stop();
  print("Part two takes ${sw.elapsedMilliseconds} milliseconds");
  assert(myPartTwoAnswer == publishedPartTwoAnswer);

  print("Part one answer: ${myPartOneAnswer}");
  print("Part two answer: ${myPartTwoAnswer}");
}

String partOneSolution(Map<String, List<String>> dag, String vertices) {
  List<String> topoList = List<String>();

  var verticesInDegreeZero = List<String>(); // Vertices with in-degree = 0

  // Build initial inDegreeMap
  var inDegreeMap = Map<String, int>(); // Key: vertex. Value: # in-degree
  for (var i = 0; i < vertices.length; ++i) {
    inDegreeMap[vertices[i]] = 0;
  }
  dag.forEach((k, v) {
    for (var vertex in v) {
      ++inDegreeMap[vertex];
    }
  });

  // Find vertices with in-degrees of 0.  Add to a list.
  do {
    for (var vertex in inDegreeMap.keys) {
      if (inDegreeMap[vertex] == 0) {
        verticesInDegreeZero.add(vertex);
        inDegreeMap[vertex] = -1000; // Hack: can't remove key while iterating
      }
    }

    // Always choose the vertex with in-degree 0 which comes first
    // alphabetically.  Reverse sort because removing last element
    // from a List is likely efficient.
    verticesInDegreeZero.sort((a, b) => b.compareTo(a));
    var lastVertex = verticesInDegreeZero.removeLast();
    topoList.add(lastVertex);
    inDegreeMap.remove(lastVertex);
    if (dag.containsKey(lastVertex)) { // dag won't contain key of final vertex
      for (var vertex in dag[lastVertex]) {
        // Find vertices connected to that last vertex and decrement
        // their in-degree counts.
        --inDegreeMap[vertex];
      }
    }
  } while (inDegreeMap.length > 0);

  // Concatenate list elements since AoC website expects this format
  var sb = StringBuffer();
  for (var vertex in topoList) {
    sb.write(vertex);
  }
  return sb.toString();
}

String partTwoSolution(
    Map<String, List<String>> dag, String vertices, bool USING_SAMPLE_DATA) {
  int stepDurationOffset = (USING_SAMPLE_DATA ? 0 : 60);

  List<String> topoList = List<String>();
  var verticesInDegreeZero = List<String>(); // Vertices with in-degree = 0

  // Build initial inDegreeMap
  var inDegreeMap = Map<String, int>(); // Key: vertex. Value: # in-degree
  for (var i = 0; i < vertices.length; ++i) {
    inDegreeMap[vertices[i]] = 0;
  }
  dag.forEach((k, v) {
    for (var vertex in v) {
      ++inDegreeMap[vertex];
    }
  });

  int numberOfWorkers = (USING_SAMPLE_DATA ? 2 : 5);

  // A stack for each worker.  Length of step added to stack depends
  // on step letter.  One element popped each clock cycle.
  var workerStacks = Map.fromIterable(
      List<int>.generate(numberOfWorkers, (int index) => index++),
      key: (item) => item,
      value: (item) => Queue<String>());

  // Empty queue means a worker is available
  bool workerIsAvailable() {
    return workerStacks.values.any((q) => q.isEmpty);
  }

  int clock = 0;
  do {
    // Pop worker stacks
    workerStacks.values.forEach((q) {
      if (q.isNotEmpty) {
        var step = q.removeLast();
        if (q.isEmpty) {
          // Add step to topoList
          topoList.add(step);
          inDegreeMap.remove(step);
          // Look for new steps (decrement in-degree map)
          // Final vertex is a sink and won't be a key in dag
          if (dag.containsKey(step)) {
            for (var vertex in dag[step]) {
              --inDegreeMap[vertex];
            }
          }
        }
      }
    });

    // Find vertices with in-degree 0
    inDegreeMap.keys.forEach((vertex) {
      if (inDegreeMap[vertex] == 0) {
        verticesInDegreeZero.add(vertex);
        inDegreeMap[vertex] = -1000; // Hack: can't remove keys while iterating
      }
    });

    // Reverse sort and remove last to ensure steps chosen in alphabetical
    // order.
    // Add N elements to a worker's stack, where N is how long step takes.
    // See website for explanation of step duration.
    verticesInDegreeZero.sort((a, b) => b.compareTo(a));
    while (workerIsAvailable() && verticesInDegreeZero.isNotEmpty) {
      String lastVertex = verticesInDegreeZero.removeLast();
      workerStacks.values.lastWhere((q) => q.isEmpty).addAll(List.generate(
          lastVertex.runes.first - 64 + stepDurationOffset, (i) => lastVertex));
    }

    ++clock;
  } while (inDegreeMap.length > 0);

  return (clock - 1).toString();
}
