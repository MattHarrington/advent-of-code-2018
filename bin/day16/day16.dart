// https://adventofcode.com/2018/day/16

import 'dart:collection';
import 'dart:io';
import 'package:quiver/collection.dart';

const USE_SAMPLE_DATA = false;

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

  for (var i = 0; i < puzzleInput.length; ++i) {
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

      digitMatches = regex.allMatches(puzzleInput[++i]);
      match1 = digitMatches.elementAt(0);
      match2 = digitMatches.elementAt(1);
      match3 = digitMatches.elementAt(2);
      match4 = digitMatches.elementAt(3);

      instruction.add(int.parse(match1.group(0)));
      instruction.add(int.parse(match2.group(0)));
      instruction.add(int.parse(match3.group(0)));
      instruction.add(int.parse(match4.group(0)));

      digitMatches = regex.allMatches(puzzleInput[++i]);
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

  if (!USE_SAMPLE_DATA) assert(rules.length == 776);

  if (USE_SAMPLE_DATA) {
    var answerMulr = mulr(rules[0].instruction, rules[0].before);
    assert(listsEqual(answerMulr, rules[0].after));

    var answerAddi = addi(rules[0].instruction, rules[0].before);
    assert(listsEqual(answerAddi, rules[0].after));

    var answerSeti = seti(rules[0].instruction, rules[0].before);
    assert(listsEqual(answerSeti, rules[0].after));
  }

  var opcodeTotals = List<int>();
  for (var r in rules) {
    var opcodeCount = 0;
    if (listsEqual(addr(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(addi(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(mulr(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(muli(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(banr(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(bani(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(borr(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(bori(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(setr(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(seti(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(gtir(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(gtri(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(gtrr(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(eqir(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(eqri(r.instruction, r.before), r.after)) ++opcodeCount;
    if (listsEqual(eqrr(r.instruction, r.before), r.after)) ++opcodeCount;
    opcodeTotals.add(opcodeCount);
  }
  print('Part 1: Number of samples which behave like >= 3 opcodes: '
      '${opcodeTotals.where((d) => d >= 3).length}');
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

/// muli (multiply immediate) stores into register C the
/// result of multiplying register A and value B.
List<int> muli(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] * B;

  return after;
}

/// addi (add immediate) stores into register C the result
/// of adding register A and value B.
List<int> addi(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] + B;

  return after;
}

/// seti (set immediate) stores value A into
/// register C. (Input B is ignored.)
List<int> seti(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = A;

  return after;
}

/// setr (set register) copies the contents of register A
/// into register C. (Input B is ignored.)
List<int> setr(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A];

  return after;
}

/// addr (add register) stores into register C the
/// result of adding register A and register B.
List<int> addr(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] + before[B];

  return after;
}

/// banr (bitwise AND register) stores into register C the
/// result of the bitwise AND of register A and register B.
List<int> banr(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] & before[B];

  return after;
}

/// bani (bitwise AND immediate) stores into register C
/// the result of the bitwise AND of register A and value B.
List<int> bani(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] & B;

  return after;
}

/// borr (bitwise OR register) stores into register C the
/// result of the bitwise OR of register A and register B.
List<int> borr(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] | before[B];

  return after;
}

/// bori (bitwise OR immediate) stores into register C the
/// result of the bitwise OR of register A and value B.
List<int> bori(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = before[A] | B;

  return after;
}

/// gtir (greater-than immediate/register) sets register C to 1
/// if value A is greater than register B. Otherwise,
/// register C is set to 0.
List<int> gtir(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = (A > before[B] ? 1 : 0);

  return after;
}

/// gtri (greater-than register/immediate) sets register
/// C to 1 if register A is greater than value B. Otherwise,
/// register C is set to 0.
List<int> gtri(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = (before[A] > B ? 1 : 0);

  return after;
}

/// gtrr (greater-than register/register) sets register C to 1
/// if register A is greater than register B. Otherwise,
/// register C is set to 0.
List<int> gtrr(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = (before[A] > before[B] ? 1 : 0);

  return after;
}

/// eqir (equal immediate/register) sets register C to 1
/// if value A is equal to register B. Otherwise, register C
/// is set to 0.
List<int> eqir(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = (A == before[B] ? 1 : 0);

  return after;
}

/// eqri (equal register/immediate) sets register C to 1 if
/// register A is equal to value B. Otherwise, register C is set to 0.
List<int> eqri(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = (before[A] == B ? 1 : 0);

  return after;
}

/// eqrr (equal register/register) sets register C to 1 if register A
/// is equal to register B. Otherwise, register C is set to 0.
List<int> eqrr(List<int> instruction, List<int> before) {
  var after = List<int>.from(before);
  var opcode = instruction[0];

  int A = instruction[1];
  int B = instruction[2];
  int C = instruction[3];

  after[C] = (before[A] == before[B] ? 1 : 0);

  return after;
}
