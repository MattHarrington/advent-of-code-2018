// https://adventofcode.com/2018/day/5

import 'dart:collection';
import 'dart:io';

main() {
  List<String> input = File("day_5_input.txt").readAsLinesSync();
  String polymer = input.first;
  assert(polymer.length == 50000);
  // Sample polymer: dabAcCaCBAcCcaDA

  print("Part one:");
  print("Result length computed naively: ${solvePartOneNaively(polymer)}");
  print("Result length computed with stack: ${solvePartOneWithStack(polymer)}");
  print("\n");

  print("Part two:");
  print("Shortest polymer length computed naively after removing"
      " faulty unit: ${solvePartTwoNaively(polymer)}");
  print("Shortest polymer length computed with stack after removing"
      " faulty unit: ${solvePartTwoWithStack(polymer)}");
}

String performReaction(String input) {
  const debug = false;
  var sb = StringBuffer();
  for (var i = 0; i < input.length; ++i) {
    if (i == input.length - 1) {
      // Handle end of polymer
      sb.write(input[i]);
      continue;
    }
    if (input[i].runes.first == input[i + 1].runes.first + 32 ||
        input[i].runes.first == input[i + 1].runes.first - 32) {
      // Reaction! Increment counter to skip ahead. Don't write to StringBuffer.
      if (debug == true) {
        print("Unit ${input[i]} reacted with unit ${input[i + 1]}");
      }
      ++i;
      continue;
    } else {
      sb.write(input[i]);
    }
  }
  return sb.toString();
}

String performReactionWithStack(String input) {
  var stack = Queue<String>();
  for(int i = 0; i < input.length; ++i) {
    if (stack.isEmpty) {
      stack.add(input[i]);
      continue;
    }
    if (input[i].runes.first == stack.last.runes.first + 32 ||
        input[i].runes.first == stack.last.runes.first - 32) {
      // Reaction!  Pop stack
      stack.removeLast();
      continue;
    }
    stack.add(input[i]);
  }
  var sb = StringBuffer();
  for (var unit in stack) {
    sb.write(unit);
  }
  return sb.toString();
}

int solvePartOneNaively(String input) {
  var previousResult = "";
  var result = input;

  // Not great time complexity...
  do {
    previousResult = result;
    result = performReaction(result);
  } while (result != previousResult);
  return result.length;
}

int solvePartOneWithStack(String input) {
  // Better time complexity...
  return performReactionWithStack(input).length;
}

int solvePartTwoNaively(String input) {
  var shortestPolymerLength = input.length + 1000; // Just make it large
  var polymerUnits = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  stdout.write("Removing polymer units...");
  for (var i = 0; i < polymerUnits.length; ++i) {
    stdout.write("${polymerUnits[i]}..");
    var exp = RegExp("${polymerUnits[i]}", caseSensitive: false);
    var modifiedInput = input.replaceAll(exp, '');

    var previousResult = "";
    var result = modifiedInput;

    // Not great time complexity...
    do {
      previousResult = result;
      result = performReaction(result);
    } while (result != previousResult);
    if (result.length < shortestPolymerLength) {
      shortestPolymerLength = result.length;
    }
  }
  stdout.writeln();  // Prints newline since stdout.write() doesn't
  return shortestPolymerLength;
}

int solvePartTwoWithStack(String input) {
  var shortestPolymerLength = input.length + 1000; // Just make it large
  var polymerUnits = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  stdout.write("Removing polymer units...");
  for (var i = 0; i < polymerUnits.length; ++i) {
    stdout.write("${polymerUnits[i]}..");
    var exp = RegExp("${polymerUnits[i]}", caseSensitive: false);
    var modifiedInput = input.replaceAll(exp, '');

    // Better time complexity...
    var result = performReactionWithStack(modifiedInput);
    if (result.length < shortestPolymerLength) {
      shortestPolymerLength = result.length;
    }
  }
  stdout.writeln();  // Prints newline since stdout.write() doesn't
  return shortestPolymerLength;
}
