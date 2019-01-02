// https://adventofcode.com/2018/day/21

import 'dart:io';

class Instruction {
  Function opcode;
  int A, B, C;

  Instruction(this.opcode, this.A, this.B, this.C);

  @override
  toString() {
    var regex = RegExp(r"\'([a-z]+)\'");
    var opcodeName = regex.firstMatch(opcode.toString()).group(1);
    return '$opcodeName $A $B $C';
  }
}

main() {
  final puzzleInputFilename = File('day_21_input.txt');
  final instructions = parsePuzzleInput(puzzleInputFilename);
  final ipRegister =
      int.parse(puzzleInputFilename.readAsLinesSync().first.split(' ')[1]);

  int registerZeroInitialValue = -3;
  var registers = [registerZeroInitialValue, 0, 0, 0, 0, 0];
  var ip = registers[ipRegister];

  while (ip < instructions.length) {
    var sb = StringBuffer();
    var instruction = instructions[ip];
    sb.write('ip=$ip $registers $instruction ');

    registers[ipRegister] = ip;
    registers = instruction.opcode(instruction, registers);
    ip = registers[ipRegister];

    sb.write(registers);
    print(sb.toString());
    ++ip;
  }
  print('Program halted');
  print('Register 0: $registerZeroInitialValue');
}

List<Instruction> parsePuzzleInput(File puzzleInputFilename) {
  var puzzleInput = puzzleInputFilename.readAsLinesSync();
  var instructions = List<Instruction>();
  var operations = {
    'mulr': mulr,
    'muli': muli,
    'addi': addi,
    'seti': seti,
    'setr': setr,
    'addr': addr,
    'banr': banr,
    'bani': bani,
    'borr': borr,
    'bori': bori,
    'gtir': gtir,
    'gtri': gtri,
    'gtrr': gtrr,
    'eqir': eqir,
    'eqri': eqri,
    'eqrr': eqrr
  };
  for (var i = 1; i < puzzleInput.length; ++i) {
    var record = puzzleInput[i].split(' ');
    var instruction = Instruction(operations[record[0]], int.parse(record[1]),
        int.parse(record[2]), int.parse(record[3]));
    instructions.add(instruction);
  }
  return instructions;
}

/// mulr (multiply register) stores into register C the result of
/// multiplying register A and register B.
List<int> mulr(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] * before[B];

  return after;
}

/// muli (multiply immediate) stores into register C the
/// result of multiplying register A and value B.
List<int> muli(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] * B;

  return after;
}

/// addi (add immediate) stores into register C the result
/// of adding register A and value B.
List<int> addi(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] + B;

  return after;
}

/// seti (set immediate) stores value A into
/// register C. (Input B is ignored.)
List<int> seti(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int C = instruction.C;

  after[C] = A;

  return after;
}

/// setr (set register) copies the contents of register A
/// into register C. (Input B is ignored.)
List<int> setr(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int C = instruction.C;

  after[C] = before[A];

  return after;
}

/// addr (add register) stores into register C the
/// result of adding register A and register B.
List<int> addr(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] + before[B];

  return after;
}

/// banr (bitwise AND register) stores into register C the
/// result of the bitwise AND of register A and register B.
List<int> banr(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] & before[B];

  return after;
}

/// bani (bitwise AND immediate) stores into register C
/// the result of the bitwise AND of register A and value B.
List<int> bani(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] & B;

  return after;
}

/// borr (bitwise OR register) stores into register C the
/// result of the bitwise OR of register A and register B.
List<int> borr(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] | before[B];

  return after;
}

/// bori (bitwise OR immediate) stores into register C the
/// result of the bitwise OR of register A and value B.
List<int> bori(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = before[A] | B;

  return after;
}

/// gtir (greater-than immediate/register) sets register C to 1
/// if value A is greater than register B. Otherwise,
/// register C is set to 0.
List<int> gtir(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = (A > before[B] ? 1 : 0);

  return after;
}

/// gtri (greater-than register/immediate) sets register
/// C to 1 if register A is greater than value B. Otherwise,
/// register C is set to 0.
List<int> gtri(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = (before[A] > B ? 1 : 0);

  return after;
}

/// gtrr (greater-than register/register) sets register C to 1
/// if register A is greater than register B. Otherwise,
/// register C is set to 0.
List<int> gtrr(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = (before[A] > before[B] ? 1 : 0);

  return after;
}

/// eqir (equal immediate/register) sets register C to 1
/// if value A is equal to register B. Otherwise, register C
/// is set to 0.
List<int> eqir(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = (A == before[B] ? 1 : 0);

  return after;
}

/// eqri (equal register/immediate) sets register C to 1 if
/// register A is equal to value B. Otherwise, register C is set to 0.
List<int> eqri(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = (before[A] == B ? 1 : 0);

  return after;
}

/// eqrr (equal register/register) sets register C to 1 if register A
/// is equal to register B. Otherwise, register C is set to 0.
List<int> eqrr(Instruction instruction, List<int> before) {
  var after = List<int>.from(before);

  int A = instruction.A;
  int B = instruction.B;
  int C = instruction.C;

  after[C] = (before[A] == before[B] ? 1 : 0);

  return after;
}
