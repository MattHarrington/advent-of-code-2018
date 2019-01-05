// https://adventofcode.com/2018/day/24

import 'dart:io';

const USE_SAMPLE_DATA = true;

abstract class Combatant {
  List<Group> groups;
}

class ImmuneSystem extends Combatant {}

class Infection extends Combatant {}

class Group {
  List<Unit> units;
  int effectivePower;
}

class Unit {
  int hitPoints;
  int attackDamage;
  AttackType attackType;
  int initiative;
  List<AttackType> weaknesses;
  List<AttackType> immunities;
}

enum AttackType { fire, bludgeoning, slashing, cold, radiation }

main() {
  var gameOn = true;
  while (gameOn) {
    // Target selection

    // Attack
  }
}

List<ImmuneSystem> getImmuneSystem() {
  var puzzleInput = USE_SAMPLE_DATA
      ? File('day_24_sample_input.txt').readAsLinesSync()
      : File('day_24_input.txt').readAsLinesSync();
  for (var record in puzzleInput) {
    if (record == 'Immune System:') continue;
    if (record == 'Infection:') break;
    var regex = RegExp(
        r'(\d+) units each with (\d+) hit points (?:\(([a-z,; ]+)\))*\s*with an attack that does (\d+) ([a-z]+) damage at initiative (\d+)');
  }
}
