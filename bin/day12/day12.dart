// https://adventofcode.com/2018/day/12

import 'package:trie/trie.dart';
import 'dart:io';
import 'dart:collection';

const DEBUG = false;
const numberOfGenerations = 20;

class Pot<T> extends LinkedListEntry<Pot> {
  int number;
  T state;

  Pot(this.number, this.state);

  @override
  String toString() => '${state}';
}

main() {
  var yesRules = List<String>();
  var noRules = List<String>();

  var puzzleInput = File("day_12_input.txt").readAsLinesSync();

  var initialState = puzzleInput[0].split(" ")[2];
  print("initialState.length: ${initialState.length}");

  for (var i = 2; i < puzzleInput.length; ++i) {
    var splitRecord = puzzleInput[i].split(" ");
    if (splitRecord[2] == ".") noRules.add(splitRecord[0]);
    if (splitRecord[2] == "#") yesRules.add(splitRecord[0]);
  }

  var yesTrie = Trie.list(yesRules);
  var noTrie = Trie.list(noRules);

  print("All yesRules are: " + yesTrie.getAllWords().toString());
  print("All noRules are: " + noTrie.getAllWords().toString());

  // Pad the initial state with 4 empty pots to the left and 4 to the right
  var initialPotState = LinkedList<Pot>();
  initialPotState.add(Pot(-4, "."));
  initialPotState.add(Pot(-3, "."));
  initialPotState.add(Pot(-2, "."));
  initialPotState.add(Pot(-1, "."));
  for (var i = 0; i < initialState.length; ++i) {
    initialPotState.add(Pot(i, initialState[i]));
  }
  initialPotState.add(Pot(initialState.length, "."));
  initialPotState.add(Pot(initialState.length + 1, "."));
  initialPotState.add(Pot(initialState.length + 2, "."));
  initialPotState.add(Pot(initialState.length + 3, "."));
  assert(initialPotState.length == initialState.length + 8);

  var generations = List<LinkedList<Pot>>();
  generations.add(initialPotState);

  for (var i = 0; i < numberOfGenerations; ++i) {
//    if (i % 1000000000 == 0) stdout.write("${i} ..");
    var nextGeneration = LinkedList<Pot>();
    var iteration = 0;
    for (var currentPot in generations[i]) {
      int currentPotNumber = currentPot.number;
      if (currentPot.previous == null) {
        nextGeneration.add(Pot(currentPot.number - 4, "."));
        nextGeneration.add(Pot(currentPot.number - 3, "."));
        nextGeneration.add(Pot(currentPot.number - 2, "."));
        nextGeneration.add(Pot(currentPot.number - 1, "."));
      }

      var sb = StringBuffer();
      sb.write(currentPot.previous?.previous?.state ?? ".");
      sb.write(currentPot.previous?.state ?? ".");
      sb.write(currentPot.state);
      sb.write(currentPot.next?.state ?? ".");
      sb.write(currentPot.next?.next?.state ?? ".");
      var pattern = sb.toString();

      var newPot = Pot(currentPot.number, "NEWPOT");
      if (yesTrie.getAllWords().contains(pattern)) {
        newPot.state = "#";
      } else if (noTrie.getAllWords().contains(pattern)) {
        newPot.state = ".";
      }
      if (newPot.state == "NEWPOT") {
        print("Pattern ${pattern} not found in either trie");
      }
      nextGeneration.add(newPot);

      if (currentPot.next == null) {
        nextGeneration.add(Pot(currentPot.number + 1, "."));
        nextGeneration.add(Pot(currentPot.number + 2, "."));
        nextGeneration.add(Pot(currentPot.number + 3, "."));
        nextGeneration.add(Pot(currentPot.number + 4, "."));
      }

      ++iteration;
    }

    generations.add(nextGeneration);

    if (DEBUG) {
      print("Added pots: ${nextGeneration.first.number} "
          "${nextGeneration.first.next.number} ... "
          "${nextGeneration.last.previous.number} "
          "${nextGeneration.last.number}");
    }
  }

  if (DEBUG) {
    int generationCounter = 0;
    for (var pots in generations) {
      print("${generationCounter}: ${potsToString(pots)}");
      ++generationCounter;
    }
  }

  int sum = 0;
  var sb = StringBuffer();
  for (var pot in generations[numberOfGenerations]) {
    if (pot.state == "#") {
      sum += pot.number;
      if (DEBUG) sb.write("${pot.number} ");
    }
  }
  if (DEBUG) print("Pots with plants: ${sb.toString()}");

  print("Sum of generation ${numberOfGenerations}: ${sum}");
}

String potsToString(LinkedList<Pot> pots,
    {int beginning = -100, int end = 300}) {
  var sb = StringBuffer();
  for (var pot in pots) {
    if (pot.number >= beginning && pot.number <= end) {
      sb.write("${pot.number},");
    }
  }
  return sb.toString();
}
// Guessed 3029 -> too high
// Guessed 2015
