// https://adventofcode.com/2018/day/12

import 'dart:io';
import 'dart:collection';

const DEBUG = false;
const USE_SAMPLE_DATA = false;
//const numberOfGenerations = 50000000000;
const numberOfGenerations = 20;
//const numberOfGenerations = 1000;

class Pot<T> extends LinkedListEntry<Pot> {
  int number;
  T state;

  Pot(this.number, this.state);

  @override
  String toString() => '${number}: ${state}';
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

  List<String> puzzleInput;
  if (USE_SAMPLE_DATA) {
    puzzleInput = File("day_12_sample_input.txt").readAsLinesSync();
  } else {
    puzzleInput = File("day_12_input.txt").readAsLinesSync();
  }

  var initialState = puzzleInput[0].split(" ")[2];
  print("initialState.length: ${initialState.length}");

  for (var i = 2; i < puzzleInput.length; ++i) {
    var splitRecord = puzzleInput[i].split(" ");
    if (splitRecord[2] == ".") noRules.add(splitRecord[0]);
    if (splitRecord[2] == "#") yesRules.add(splitRecord[0]);
  }

  if (!USE_SAMPLE_DATA) {
    assert(yesRules.length == 16);
    assert(noRules.length == 16);
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
    for (var i = 0; i < 5; ++i) {
      if (tempBeginningPot.state == "#") {
        potsToAddAtBeginning = 5 - i;
        break;
      } else if (tempBeginningPot.state == ".") {}
      tempBeginningPot = tempBeginningPot.next;
    }
    for (var i = 0; i < potsToAddAtBeginning; ++i) {
      var firstPotNumber = currentGeneration.first.number;
      currentGeneration.addFirst(Pot(firstPotNumber - 1 - i, "."));
    }

    var iteration = 0;
    for (var currentPot in currentGeneration) {
      var sb = StringBuffer();
      sb.write(currentPot.previous?.previous?.state ?? ".");
      sb.write(currentPot.previous?.state ?? ".");
      sb.write(currentPot.state);
      sb.write(currentPot.next?.state ?? ".");
      sb.write(currentPot.next?.next?.state ?? ".");
      var pattern = sb.toString();
      Pot newPot;
      if (USE_SAMPLE_DATA) newPot = Pot(currentPot.number, '.');
      if (!USE_SAMPLE_DATA) newPot = Pot(currentPot.number, currentPot.state);
      if (yesRules.contains(pattern)) {
        newPot.state = "#";
      } else if (noRules.contains(pattern)) {
        newPot.state = ".";
      }
      nextGeneration.add(newPot);
      ++iteration;
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
    var lastPotCurrentGeneration = currentGeneration.last;
    var lastPotNextGeneration = nextGeneration.last;
    var currentGenerationSum = sumOfGarden(currentGeneration);

    currentGeneration = nextGeneration;
  }

  int sum = sumOfGarden(currentGeneration);

  print("Sum of generation ${numberOfGenerations}: ${sum}");

  print("Number of last pot: ${currentGeneration.last.number}");
  print("Current generation: ${potsToString(currentGeneration)}");
  if (!USE_SAMPLE_DATA && numberOfGenerations == 20) assert(sum == 2995);
  if (USE_SAMPLE_DATA && numberOfGenerations == 20) assert(sum == 325);
}

String potsToString(Garden<Pot> pots, {int beginning = -200, int end = 200}) {
  var sb = StringBuffer();
  for (var pot in pots) {
    if (pot.number >= beginning && pot.number <= end) {
      sb.write("${pot.number},");
    }
  }
  return sb.toString();
}

int sumOfGarden(Garden<Pot> pots) {
  int sum = 0;
  for (var pot in pots) {
    if (pot.state == "#") sum += pot.number;
  }
  return sum;
}
