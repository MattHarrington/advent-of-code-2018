// https://adventofcode.com/2018/day/14

const USE_SAMPLE_DATA = false;

main() {
  var puzzleInput = (USE_SAMPLE_DATA ? '2018' : '554401');
  var recipes = [3, 7];
  var elfOnePosition = 0;
  var elfTwoPosition = 1;

// TODO Loop until part 2 answer found
  while (recipes.length < 25000000) {
    var valueAtElfOnePosition = recipes[elfOnePosition];
    var valueAtElfTwoPosition = recipes[elfTwoPosition];

    var combinedRecipe = valueAtElfOnePosition + valueAtElfTwoPosition;

    var firstNewRecipe = ((combinedRecipe % 100) / 10).truncate(); // tens digit
    var secondNewRecipe = (combinedRecipe % 10).truncate(); // ones digit

    if (firstNewRecipe != 0) recipes.add(firstNewRecipe);
    recipes.add(secondNewRecipe);

    // Calculate new positions
    elfOnePosition =
        (elfOnePosition + 1 + valueAtElfOnePosition) % recipes.length;
    elfTwoPosition =
        (elfTwoPosition + 1 + valueAtElfTwoPosition) % recipes.length;
  }

  var sb = StringBuffer();
  for (var recipe in recipes) {
    sb.write(recipe);
  }

  var partOneAnswer = sb
      .toString()
      .substring(int.parse(puzzleInput), int.parse(puzzleInput) + 10);
  print("Part one answer: $partOneAnswer");

  var partTwoAnswer = sb.toString().indexOf(puzzleInput.toString());
  print("Part two answer: $partTwoAnswer");

  if (!USE_SAMPLE_DATA) {
    assert(partOneAnswer == '3610281143');
    assert(partTwoAnswer == 20211326);
  }
}
