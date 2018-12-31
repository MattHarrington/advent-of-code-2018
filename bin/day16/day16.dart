// https://adventofcode.com/2018/day/16

import 'dart:io';
import 'package:quiver/collection.dart';

const USE_SAMPLE_DATA = false;

enum Opcode {
  addr,
  addi,
  mulr,
  muli,
  banr,
  bani,
  borr,
  bori,
  setr,
  seti,
  gtir,
  gtri,
  gtrr,
  eqir,
  eqri,
  eqrr
}

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

  // Test each sample on each opcode. Count number of valid
  // opcodes per sample.  Store possible instructions for each opcode in map.
  var opcodeTotals = List<int>();
  var opcodeMap = Map<int, Set<Opcode>>();
  for (var r in rules) {
    var opcodeCount = 0;
    if (listsEqual(addr(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.addr);
    }
    if (listsEqual(addi(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.addi);
    }
    if (listsEqual(mulr(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.mulr);
    }
    if (listsEqual(muli(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.muli);
    }
    if (listsEqual(banr(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.banr);
    }
    if (listsEqual(bani(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.bani);
    }
    if (listsEqual(borr(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.borr);
    }
    if (listsEqual(bori(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.bori);
    }
    if (listsEqual(setr(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.setr);
    }
    if (listsEqual(seti(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.seti);
    }
    if (listsEqual(gtir(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.gtir);
    }
    if (listsEqual(gtri(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.gtri);
    }
    if (listsEqual(gtrr(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.gtrr);
    }
    if (listsEqual(eqir(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.eqir);
    }
    if (listsEqual(eqri(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.eqri);
    }
    if (listsEqual(eqrr(r.instruction, r.before), r.after)) {
      ++opcodeCount;
      (opcodeMap[r.instruction[0]] ??= Set<Opcode>()).add(Opcode.eqrr);
    }
    opcodeTotals.add(opcodeCount);
  }

  final partOneAnswer = opcodeTotals.where((d) => d >= 3).length;
  print('Part 1: # of samples which behave like >= 3 opcodes: $partOneAnswer');
  assert(partOneAnswer == 612);

  // For part 2.  Print out map.  Through process of elimination,
  // mentally determine which instruction corresponds to which opcode.
  // Alternatively, key (opcode) with a single value (instruction) ensures
  // that opcode corresponds to that instruction.  One could iterate through
  // the map and eliminate that instruction from other entries.  Repeat
  // process on entry which then has one value.  Continue until all opcodes
  // have been determined.
  print('\nKey: opcode, Value: possible instructions');
  opcodeMap.forEach((k, v) {
    stdout.write('$k: ');
    v.forEach((opcode) => stdout.write('${opcode.toString()}, '));
    stdout.writeln();
  });
  print('\n');

  // Parse the instructions into a program.  Run the program on an
  // initial list of registers.
  final program = parseProgram(puzzleInput);
  const initialRegisters = [0, 0, 0, 0];
  final finalRegisters = runProgram(program, initialRegisters);

  print('Part 2: register 0 contains ${finalRegisters[0]}');
  assert(finalRegisters[0] == 485);
}

/// Parse puzzleInput from line 3106 onwards.  Each line is
/// an instruction.
List<List<int>> parseProgram(List<String> puzzleInput) {
  var program = List<List<int>>();
  var regex = RegExp(r'\d+');
  for (var i = 3106; i < puzzleInput.length; ++i) {
    var digitMatches = regex.allMatches(puzzleInput[i]);

    var match1 = digitMatches.elementAt(0);
    var match2 = digitMatches.elementAt(1);
    var match3 = digitMatches.elementAt(2);
    var match4 = digitMatches.elementAt(3);

    var instruction = List<int>();
    instruction.add(int.parse(match1.group(0)));
    instruction.add(int.parse(match2.group(0)));
    instruction.add(int.parse(match3.group(0)));
    instruction.add(int.parse(match4.group(0)));
    program.add(instruction);
  }
  return program;
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

/// Run a list of instructions in a program on a given list of
/// initial registers.  Return final registers.
List<int> runProgram(List<List<int>> program, List<int> initialRegisters) {
  var registers = initialRegisters.toList();
  for (var instruction in program) {
    switch (instruction[0]) {
      case 0:
        registers = addi(instruction, registers);
        break;
      case 1:
        registers = bani(instruction, registers);
        break;
      case 2:
        registers = gtir(instruction, registers);
        break;
      case 3:
        registers = borr(instruction, registers);
        break;
      case 4:
        registers = eqrr(instruction, registers);
        break;
      case 5:
        registers = bori(instruction, registers);
        break;
      case 6:
        registers = gtrr(instruction, registers);
        break;
      case 7:
        registers = setr(instruction, registers);
        break;
      case 8:
        registers = muli(instruction, registers);
        break;
      case 9:
        registers = seti(instruction, registers);
        break;
      case 10:
        registers = banr(instruction, registers);
        break;
      case 11:
        registers = gtri(instruction, registers);
        break;
      case 12:
        registers = eqir(instruction, registers);
        break;
      case 13:
        registers = eqri(instruction, registers);
        break;
      case 14:
        registers = addr(instruction, registers);
        break;
      case 15:
        registers = mulr(instruction, registers);
        break;
      default:
        throw 'Should never be here';
        break;
    }
  }
  return registers;
}
