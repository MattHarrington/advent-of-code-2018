// https://adventofcode.com/2018/day/16

import 'dart:collection';
import 'dart:io';

const USE_SAMPLE_DATA = true;

class Rule {
  List<int> before;
  List<int> instruction;
  List<int> after;

  Rule(this.before, this.instruction, this.after);
}

main() {
  var sampleInput = ['Before: [3, 2, 1, 1]', '9 2 1 2', 'After:  [3, 2, 2, 1]'];
  var puzzleInput = (USE_SAMPLE_DATA
      ? sampleInput
      : File("day_16_input.txt").readAsLinesSync());

  var rules = List<Rule>();

  for (var i = 0; i < puzzleInput.length; i += 3) {
    if (puzzleInput[i].startsWith('Before:')) {
      var before = List<int>();
      var instruction = List<int>();
      var after = List<int>();

      var regex = RegExp(r'\d+');
      var digitMatches = regex.allMatches(puzzleInput[i]);

      var match1 = digitMatches.elementAt(0);
      var match2 = digitMatches.elementAt(1);
      var match3 = digitMatches.elementAt(2);
      var match4 = digitMatches.elementAt(3);

      before.add(int.parse(match1.group(0)));
      before.add(int.parse(match2.group(0)));
      before.add(int.parse(match3.group(0)));
      before.add(int.parse(match4.group(0)));

      digitMatches = regex.allMatches(puzzleInput[i + 1]);
      match1 = digitMatches.elementAt(0);
      match2 = digitMatches.elementAt(1);
      match3 = digitMatches.elementAt(2);
      match4 = digitMatches.elementAt(3);

      instruction.add(int.parse(match1.group(0)));
      instruction.add(int.parse(match2.group(0)));
      instruction.add(int.parse(match3.group(0)));
      instruction.add(int.parse(match4.group(0)));

      digitMatches = regex.allMatches(puzzleInput[i + 2]);
      match1 = digitMatches.elementAt(0);
      match2 = digitMatches.elementAt(1);
      match3 = digitMatches.elementAt(2);
      match4 = digitMatches.elementAt(3);

      after.add(int.parse(match1.group(0)));
      after.add(int.parse(match2.group(0)));
      after.add(int.parse(match3.group(0)));
      after.add(int.parse(match4.group(0)));

      rules.add(Rule(before, instruction, after));
    }
  }
  var answer = mulr(rules[0].instruction, rules[0].before);

  assert(areEqual(answer, rules[0].after));
  print("The End");
}

bool areEqual(List<int> first, List<int> second) {
  if (first.length != second.length) return false;
  for (var i = 0; i < first.length; ++i) {
    if (first[i] != second[i]) return false;
  }
  return true;
}

/// mulr (multiply register) stores into register C the result of
/// multiplying register A and register B.
List<int> mulr(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] * before[B];

  return after;
}
