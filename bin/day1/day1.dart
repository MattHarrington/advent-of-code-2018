import 'dart:io';

main(List<String> arguments) {

  // Because input can only be retrieved when authenticated,
  // copy/paste into text file instead of reading with HTTP GET.
  var frequency_changes_strings = File("day_1_input.txt").readAsLinesSync();
  assert(frequency_changes_strings.length == 1000);

  var accumulator = 0;
  var frequency_changes = List<int>();
  for (var frequency_change in frequency_changes_strings) {
    accumulator += int.parse(frequency_change);
    frequency_changes.add(int.parse(frequency_change));
  }
  print("Final frequency computed with for loop: ${accumulator}");
  print("Final frequency computed with reduce: ${frequency_changes.reduce((a, b) => a + b)}");

  var frequency = 0;
  // var observed_frequencies = List<int>();
  var observed_frequencies = Set<int>();

  for (var i = 0; i < frequency_changes.length; i++) {
    frequency += frequency_changes[i];
    if (observed_frequencies.contains(frequency)) {
      print("First repeated frequency: ${frequency}");
      break;
    }

    observed_frequencies.add(frequency);

    if (i == frequency_changes.length - 1) {
      i = -1;
    }
  }
  print("observed_frequencies.length: ${observed_frequencies.length}");
}
