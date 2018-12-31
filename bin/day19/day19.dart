// https://adventofcode.com/2018/day/19

import 'dart:io';

const USE_SAMPLE_DATA = false;

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
  var puzzleInputFilename = USE_SAMPLE_DATA
      ? File('day_19_sample_input.txt')
      : File('day_19_input.txt');
  var instructions = parsePuzzleInput(puzzleInputFilename);
  var ip = int.parse(puzzleInputFilename.readAsLinesSync().first.split(' ')[1]);

  var registers = [0, 0, 0, 0, 0, 0];

  while (registers[ip] < instructions.length) {
    var sb = StringBuffer();
    var instruction = instructions[registers[ip]];
    sb.write('ip=${registers[ip]} $registers $instruction ');
    registers = instruction
        .opcode([null, instruction.A, instruction.B, instruction.C], registers);

    sb.write(registers);
    print(sb.toString());
    ++registers[ip];
  }
  var partOneAnswer = registers[0];
  print('Part one: register 0 contains $partOneAnswer');
  assert(partOneAnswer == 878);
}

List<Instruction> parsePuzzleInput(File puzzleInputFilename) {
  var puzzleInput = puzzleInputFilename.readAsLinesSync();
  var instructions = List<Instruction>();
  for (var i = 1; i < puzzleInput.length; ++i) {
    var record = puzzleInput[i].split(' ');
    Function func;
    switch (record[0]) {
      case 'mulr':
        func = mulr;
        break;
      case 'muli':
        func = muli;
        break;
      case 'addi':
        func = addi;
        break;
      case 'seti':
        func = seti;
        break;
      case 'setr':
        func = setr;
        break;
      case 'addr':
        func = addr;
        break;
      case 'banr':
        func = banr;
        break;
      case 'bani':
        func = bani;
        break;
      case 'borr':
        func = borr;
        break;
      case 'bori':
        func = bori;
        break;
      case 'gtir':
        func = gtir;
        break;
      case 'gtri':
        func = gtri;
        break;
      case 'gtrr':
        func = gtrr;
        break;
      case 'eqir':
        func = eqir;
        break;
      case 'eqri':
        func = eqri;
        break;
      case 'eqrr':
        func = eqrr;
        break;
      default:
        throw ArgumentError;
        break;
    }
    var instruction = Instruction(
        func, int.parse(record[1]), int.parse(record[2]), int.parse(record[3]));
    instructions.add(instruction);
  }
  return instructions;
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
