// https://adventofcode.com/2018/day/12
// This code provides solution for part 1.  For part 2, run with
// 50,000,000,000 generations and note that simulation achieves
// a steady state.  Record the constant number of plants added
// per generation and calculate value at 50,000,000,000 with:
// (50000000000 - 1000) * steady state num per gen + number at iteration 1000
// Part 2 answer = 3650000000377

import 'dart:io';
import 'dart:collection';

const DEBUG = false;
const USE_SAMPLE_DATA = false;
//const numberOfGenerations = 50000000000;
//const numberOfGenerations = 1000;
const numberOfGenerations = 20;

/// Elements in [LinkedList] must extend [LinkedListEntry]
class Pot<T> extends LinkedListEntry<Pot> {
  int number;
  T state;

  Pot(this.number, this.state);

  @override
  String toString() => '${number}: ${state}';
}

/// Subclass of [LinkedList] which provides custom toString()
class Garden<E> extends LinkedList<Pot> {
  @override
  toString() {
    var sb = StringBuffer();
    this.forEach((pot) => sb.write(pot.state));
    return sb.toString();
  }
}

main() {
  // Parse puzzle input
  var puzzleInput = (USE_SAMPLE_DATA
      ? File("day_12_sample_input.txt").readAsLinesSync()
      : File("day_12_input.txt").readAsLinesSync());
  var initialState = puzzleInput[0].split(" ")[2];
  var yesRules = List<String>();
  var noRules = List<String>();
  for (var i = 2; i < puzzleInput.length; ++i) {
    var splitRecord = puzzleInput[i].split(" ");
    if (splitRecord[2] == ".") noRules.add(splitRecord[0]);
    if (splitRecord[2] == "#") yesRules.add(splitRecord[0]);
  }

  // Populate Garden
  var currentGeneration = Garden<Pot>();
  for (var i = 0; i < initialState.length; ++i) {
    currentGeneration.add(Pot(i, initialState[i]));
  }

  // Loop through generations
  for (var gen = 0; gen < numberOfGenerations; ++gen) {
    var nextGeneration = Garden<Pot>();  // Start fresh
    if (DEBUG) print("${gen}: ${gardenToString(currentGeneration)}");

    // Ensure 5 empty pots at beginning
    int potsToAddAtBeginning = 0;
    var tempBeginningPot = currentGeneration.first;
    for (var i = 0; i < 5; ++i) {
      if (tempBeginningPot.state == "#") {
        potsToAddAtBeginning = 5 - i;
        break;
      } else if (tempBeginningPot.state == ".") {}
      tempBeginningPot = tempBeginningPot.next;
    }
    for (var i = 0; i < potsToAddAtBeginning; ++i) {
      var firstPotNumber = currentGeneration.first.number;
      currentGeneration.addFirst(Pot(firstPotNumber - 1, "."));
    }

    // Process pots in currentGeneration.  Create nextGeneration with
    // results from currentGeneration.
    for (var currentPot in currentGeneration) {
      var sb = StringBuffer();
      sb.write(currentPot.previous?.previous?.state ?? ".");
      sb.write(currentPot.previous?.state ?? ".");
      sb.write(currentPot.state);
      sb.write(currentPot.next?.state ?? ".");
      sb.write(currentPot.next?.next?.state ?? ".");
      var pattern = sb.toString();
      Pot newPot;
      newPot = Pot(currentPot.number, '.');
      if (yesRules.contains(pattern)) {
        newPot.state = "#";
      } else if (noRules.contains(pattern)) {
        newPot.state = ".";
      }
      nextGeneration.add(newPot);
    }

    // Ensure 5 empty pots at end
    int potsToAddAtEnd = 0;
    var tempEndPot = nextGeneration.last;
    for (var i = 0; i < 5; ++i) {
      if (tempEndPot.state == "#") {
        potsToAddAtEnd = 5 - i;
        break;
      }
      tempEndPot = tempEndPot.previous;
    }
    for (var i = 0; i < potsToAddAtEnd; ++i) {
      var lastPotNumber = currentGeneration.last.number;
      nextGeneration.add(Pot(lastPotNumber + 1 + i, "."));
    }

    // Unlink extra empty pots at beginning.  Keeps Garden
    // from growing large with empty pots.
    while (beginningHasSixEmptyPots(nextGeneration)) {
      nextGeneration.first.unlink();
    }

    if (DEBUG && gen % 1000 == 0) {
      print("Generation ${(gen / 1000).truncate()}M .. "
          "currentGeneration.length: ${currentGeneration.length} "
          "sum: ${sumOfGarden(currentGeneration)}");
    }

    currentGeneration = nextGeneration;
  }

  int sum = sumOfGarden(currentGeneration);
  print("Sum of generation ${numberOfGenerations}: ${sum}");

  // Assertions to catch regressions when refactoring
  if (!USE_SAMPLE_DATA && numberOfGenerations == 20) assert(sum == 2995);
  if (USE_SAMPLE_DATA && numberOfGenerations == 20) assert(sum == 325);
}

/// Return string representation of [Garden] between two indices.
/// Used to ensure [Pot]s are in correct order.  See also [Garden].toString().
String gardenToString(Garden<Pot> pots, {int beginning = -2, int end = 35}) {
  var sb = StringBuffer();
  for (var pot in pots) {
    if (pot.number >= beginning && pot.number <= end) {
      sb.write("${pot.number},");
    }
  }
  return sb.toString();
}

/// Return sum of [Pot] numbers containing plants in [Garden]
int sumOfGarden(Garden<Pot> pots) {
  int sum = 0;
  for (var pot in pots) {
    if (pot.state == "#") sum += pot.number;
  }
  return sum;
}

/// Check if [Garden] has 6 empty [Pot]s at the beginning.
/// Not succinct code, but clear.
bool beginningHasSixEmptyPots(Garden garden) {
  if (garden?.first?.state == '.' &&
      garden?.first?.next?.state == '.' &&
      garden?.first?.next?.next?.state == '.' &&
      garden?.first?.next?.next?.next?.state == '.' &&
      garden?.first?.next?.next?.next?.next?.state == '.' &&
      garden?.first?.next?.next?.next?.next?.next?.state == '.') {
    return true;
  } else {
    return false;
  }
}
