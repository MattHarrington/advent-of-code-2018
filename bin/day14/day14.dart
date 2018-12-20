// https://adventofcode.com/2018/day/14

import 'dart:io';

const USE_SAMPLE_DATA = true;

main() {
  var puzzleInput = (USE_SAMPLE_DATA ? '554401' : '554401');
  var recipes = [3, 7];
  var elfOnePosition = 0;
  var elfTwoPosition = 1;

  var sb = StringBuffer();
  while (sb.toString().indexOf(puzzleInput) == -1) {
//  while (recipes.length < 100000000) {
    sb.clear();
    var valueAtElfOnePosition = recipes[elfOnePosition];
    var valueAtElfTwoPosition = recipes[elfTwoPosition];

    var combinedRecipe = valueAtElfOnePosition + valueAtElfTwoPosition;

    var firstNewRecipe = ((combinedRecipe % 100) / 10).truncate(); // tens digit
    var secondNewRecipe = ((combinedRecipe % 10) / 1).truncate(); // ones digit

    if (firstNewRecipe != 0) recipes.add(firstNewRecipe);
    recipes.add(secondNewRecipe);

    // calculate new positions
    elfOnePosition =
        (elfOnePosition + 1 + valueAtElfOnePosition) % recipes.length;
    elfTwoPosition =
        (elfTwoPosition + 1 + valueAtElfTwoPosition) % recipes.length;
    for (var recipe in recipes) {
      sb.write(recipe);
    }
    if (recipes.length % 100 == 0) stdout.write('.');
    if (recipes.length % 1000 == 0) stdout.writeln();
  }

//  print(
//      "Part one answer: ${sb.toString().substring(puzzleInput, puzzleInput + 10)}");

  var partTwoAnswer = sb.toString().indexOf(puzzleInput.toString());

  print("Part two answer: $partTwoAnswer");
}

// Part 2: 1112 too low
