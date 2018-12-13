// https://adventofcode.com/2018/day/12

import 'package:trie/trie.dart';
import 'dart:io';
import 'dart:collection';

const DEBUG = true;
//const numberOfGenerations = 50000000000;
const numberOfGenerations = 20;
//const numberOfGenerations = 1000;

class Pot<T> extends LinkedListEntry<Pot> {
  int number;
  T state;

  Pot(this.number, this.state);

  @override
  String toString() => '${state}';
}

class Garden<E> extends LinkedList<Pot> {
  @override
  toString() {
    var sb = StringBuffer();
    this.forEach((pot) => sb.write(pot.state));
    return sb.toString();
  }
}

main() {
  var yesRules = List<String>();
  var noRules = List<String>();

  var puzzleInput = File("day_12_sample_input.txt").readAsLinesSync();

  var initialState = puzzleInput[0].split(" ")[2];
  print("initialState.length: ${initialState.length}");

  for (var i = 2; i < puzzleInput.length; ++i) {
    var splitRecord = puzzleInput[i].split(" ");
    if (splitRecord[2] == ".") noRules.add(splitRecord[0]);
    if (splitRecord[2] == "#") yesRules.add(splitRecord[0]);
  }

  var yesTrie = Trie.list(yesRules);
  var noTrie = Trie.list(noRules);

  if (DEBUG) {
    print("All yesRules are: " + yesTrie.getAllWords().toString());
    print("All noRules are: " + noTrie.getAllWords().toString());
  }

  var currentGeneration = Garden<Pot>();

  for (var i = 0; i < initialState.length; ++i) {
    currentGeneration.add(Pot(i, initialState[i]));
  }

  for (var g = 0; g < numberOfGenerations; ++g) {
    var nextGeneration = Garden<Pot>();
//    if (DEBUG) print("${g}: ${currentGeneration.toString()}");
    if (DEBUG) print("${g}: ${potsToString(currentGeneration)}");
//    if (g % 100 == 0) stdout.write("${(g / 100).truncate()}C ..");

    // Ensure 5 empty pots at beginning
    int potsToAddAtBeginning = 0;
    var tempBeginningPot = currentGeneration.first;
    var beginningPatternStringBuffer = StringBuffer();
    for (var i = 0; i < 5; ++i) {
      if (tempBeginningPot.state == "#") {
        beginningPatternStringBuffer.write("#");
        potsToAddAtBeginning = 5 - i;
        break;
      } else if (tempBeginningPot.state == ".") {
        beginningPatternStringBuffer.write(".");
      }
      tempBeginningPot = tempBeginningPot.next;
    }
    var beginningPattern = beginningPatternStringBuffer.toString();

    for (var i = 0; i < potsToAddAtBeginning; ++i) {
      var firstPotNumber = currentGeneration.first.number;
      nextGeneration.addFirst(Pot(firstPotNumber - 1, "."));
//      if (DEBUG)
//        print("Added pot ${currentGeneration.first.number} at beginning");
    }

    // Ensure 5 empty pots at end
    int potsToAddAtEnd = 0;
    var endPatternStringBuffer = StringBuffer();
    var tempEndPot = currentGeneration.last;
    for (var i = 0; i < 5; ++i) {
      if (tempEndPot.state == "#") {
        endPatternStringBuffer.write("#");
        potsToAddAtEnd = 5 - i;
        break;
      } else if (tempEndPot.state == ".") {
        endPatternStringBuffer.write(".");
      }
      tempEndPot = tempEndPot.previous;
    }
    var endPattern = endPatternStringBuffer.toString();

    for (var i = 0; i < potsToAddAtEnd; ++i) {
      var lastPotNumber = currentGeneration.last.number;
      nextGeneration.add(Pot(lastPotNumber + 1, "."));
//      if (DEBUG) print("Added pot ${currentGeneration.last.number} at end");
    }
    var lastPot = currentGeneration.last;

    var iteration = 0;
    for (var currentPot in currentGeneration) {
      var sb = StringBuffer();
      sb.write(currentPot.previous?.previous?.state ?? ".");
      sb.write(currentPot.previous?.state ?? ".");
      sb.write(currentPot.state);
      sb.write(currentPot.next?.state ?? ".");
      sb.write(currentPot.next?.next?.state ?? ".");
      var pattern = sb.toString();

      var newPot = Pot(currentPot.number, currentPot.state);
      if (yesTrie.getAllWords().contains(pattern)) {
        newPot.state = "#";
      } else if (noTrie.getAllWords().contains(pattern)) {
        newPot.state = ".";
      }
      nextGeneration.add(newPot);
      ++iteration;
    }
    currentGeneration = nextGeneration;
//    if (DEBUG) print("currentGeneration.length: ${currentGeneration.length}");

  }

  int sum = 0;
  var sb = StringBuffer();
  for (var pot in currentGeneration) {
    if (pot.state == "#") {
      sum += pot.number;
//        if (DEBUG) sb.write("${pot.number} ");
    }
  }
  print("Sum of generation ${numberOfGenerations}: ${sum}");

//    if (DEBUG) print("Pots with plants: ${sb.toString()}");

  print("Number of last pot: ${currentGeneration.last.number}");
  print("Current generation: ${potsToString(currentGeneration)}");
//  print("currentGeneration.toString(): ${currentGeneration.toString()}");
  if (numberOfGenerations == 20) assert(sum == 2995);
}

String potsToString(Garden<Pot> pots, {int beginning = -2, int end = 35}) {
  var sb = StringBuffer();
  for (var pot in pots) {
    if (pot.number >= beginning && pot.number <= end) {
      sb.write("${pot.state}");
    }
  }
  return sb.toString();
}
