// https://adventofcode.com/2018/day/12

import 'package:trie/trie.dart';
import 'dart:io';
import 'dart:collection';

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

  var initialPotState = LinkedList<Pot>();
  for (var i = 0; i < initialState.length; ++i) {
    initialPotState.add(Pot(i, initialState[i]));
  }
  assert(initialPotState.length == initialState.length);

  var generations = List<LinkedList<Pot>>();
  generations.add(initialPotState);

  for (var i = 0; i < 20; ++i) {
    var nextGeneration = LinkedList<Pot>();
    var iteration = 0;
    for (var currentPot in generations[i]) {
      if (currentPot.previous == null) {
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
      }

      ++iteration;
    }

    generations.add(nextGeneration);

    print("Added pots: ${nextGeneration.first.number} "
        "${nextGeneration.first.next.number} ... "
        "${nextGeneration.last.previous.number} "
        "${nextGeneration.last.number}");
  }

  for (var generation in generations) {
    print(generation);
  }

  int sum = 0;
  var sb = StringBuffer();
  for (var pot in generations[20]) {
    if (pot.state == "#") {
      sum += pot.number;
      sb.write("${pot.number} ");
    }
  }
  print(sb.toString());

  print("Sum of generation 20: ${sum}");
}

// Guessed 3029 -> too high
