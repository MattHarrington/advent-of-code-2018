// https://adventofcode.com/2018/day/24

import 'dart:io';

const USE_SAMPLE_DATA = false;

abstract class Combatant {
  List<Group> groups;
}

class ImmuneSystem extends Combatant {
  ImmuneSystem() {
    groups = List<Group>();
  }
}

class Infection extends Combatant {
  Infection() {
    groups = List<Group>();
  }
}

class Group extends Comparable<Group> {
  static int damageSort(Group attacker, Group a, Group b) {
    if (attacker.getDamage(a) == attacker.getDamage(b)) {
      // todo: compare effective power, then initiative
      return 0;
    } else if (attacker.getDamage(a) > attacker.getDamage(b))
      return 1;
    else
      return -1;
  }

  static int decreasingInitiativeSort(Group a, Group b) {
    if (a.units.first.initiative == b.units.first.initiative)
      return 0;
    else if (a.units.first.initiative < b.units.first.initiative)
      return 1;
    else
      return -1;
  }

  List<Unit> units;
  Type armyType;
  bool selectedForAttack = false;
  Group target;
  bool alive = true;

  /// Number of units in group multiplied by their attack damage
  int get effectivePower => units.length * units.first.attackDamage;

  Group(this.armyType) {
    units = List<Unit>();
  }

  int getDamage(Group defender) {
    if (defender.units.first.immunities?.contains(units.first.attackType) ??
        false)
      return 0;
    else if (defender.units.first.weaknesses
            ?.contains(units.first.attackType) ??
        false)
      return 2 * effectivePower;
    else
      return effectivePower;
  }

  void attack(Group defender) {
    int damage = getDamage(defender);
    int defenderUnitsKilled = (damage / defender.units.first.hitPoints).floor();
    if (defenderUnitsKilled >= defender.units.length) {
      defender.alive = false;
      defender.units.clear();
      return;
    }
    defender.units = defender.units.sublist(defenderUnitsKilled);
  }

  @override
  int compareTo(Group other) {
    if (effectivePower == other.effectivePower) {
      if (units.first.initiative == other.units.first.initiative)
        return 0;
      else if (units.first.initiative > other.units.first.initiative)
        return 1;
      else
        return -1;
    } else if (effectivePower > other.effectivePower)
      return 1;
    else
      return -1;
  }

  @override
  toString() => '$armyType group contains ${units.length} units';
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

/// Helper function to parse strings into enums
AttackType stringToAttackType(String s) {
  AttackType attackType;
  switch (s) {
    case 'fire':
      attackType = AttackType.fire;
      break;
    case 'bludgeoning':
      attackType = AttackType.bludgeoning;
      break;
    case 'slashing':
      attackType = AttackType.slashing;
      break;
    case 'cold':
      attackType = AttackType.cold;
      break;
    case 'radiation':
      attackType = AttackType.radiation;
      break;
    default:
      throw ArgumentError.value(s);
  }
  return attackType;
}

main() {
  var puzzleInput = USE_SAMPLE_DATA
      ? File('day_24_sample_input.txt').readAsLinesSync()
      : File('day_24_input.txt').readAsLinesSync();
  var immuneRecordsEnd = USE_SAMPLE_DATA ? 3 : 11;
  var infectionsRecordsStart = USE_SAMPLE_DATA ? 5 : 13;
  var immuneRecords = puzzleInput.sublist(1, immuneRecordsEnd);
  var immuneSystemArmy = getArmy(ImmuneSystem, immuneRecords);
  var infectionRecords = puzzleInput.sublist(infectionsRecordsStart);
  var infectionArmy = getArmy(Infection, infectionRecords);

  var gameOn = true;
  while (gameOn) {
    // Target selection
    List<Group> allGroups = List.of(immuneSystemArmy.groups, growable: true);
    allGroups.addAll(infectionArmy.groups);
    allGroups = allGroups.where((group) => group.alive).toList();
    allGroups.sort(); // TODO reverse sort
    allGroups = allGroups.reversed.toList();
    allGroups.forEach((group) => group.selectedForAttack = false);

    for (var attacker in allGroups) {
      Group target;
      int maxDamage = 0;
      for (var defender in allGroups) {
        if (attacker.armyType == defender.armyType ||
            defender.selectedForAttack) continue;
        if (attacker.getDamage(defender) > maxDamage) {
          maxDamage = attacker.getDamage(defender);
          target = defender;
        }
        ;
      }
      target?.selectedForAttack = true;
      attacker.target = target;
    }

    // Attack in decreasing order of initiative
    allGroups.sort(Group.decreasingInitiativeSort);
    for (var group in allGroups) {
      // group may have been killed by earlier attack in this loop
      if (!group.alive || group.target == null) continue;
      group.attack(group.target);
    }
    if (immuneSystemArmy.groups.any((group) => group.alive) &&
        infectionArmy.groups.any((group) => group.alive)) continue;
    gameOn = false;
  }

  int partOneAnswer;

  if (immuneSystemArmy.groups.any((group) => group.alive)) {
    partOneAnswer = immuneSystemArmy.groups
        .fold(0, (prev, element) => prev + element.units.length);
  } else {
    partOneAnswer = infectionArmy.groups
        .fold(0, (prev, element) => prev + element.units.length);
  }
  print('partOneAnswer: $partOneAnswer units remaining');
  if (USE_SAMPLE_DATA)
    assert(partOneAnswer == 5216);
  else
    assert(partOneAnswer == 22676);
}

Combatant getArmy(Type type, List<String> records) {
  var combatant = (type == ImmuneSystem) ? ImmuneSystem() : Infection();
  var regex = RegExp(
      r'(\d+) units each with (\d+) hit points (?:\((?:(?:weak to ([a-z,\s]+));?\s?(?:immune to ([a-z,\s]+))*;?\s?|(?:immune to ([a-z,\s]+));?\s?(?:weak to ([a-z,\s]+))*;?\s?)\))*\s?with an attack that does (\d+) ([a-z]+) damage at initiative (\d+)');
  for (var record in records) {
    var matches = regex.allMatches(record).first;

    var unit = Unit();
    unit.hitPoints = int.parse(matches.group(2));
    unit.attackDamage = int.parse(matches.group(7));
    unit.attackType = stringToAttackType(matches.group(8));
    unit.initiative = int.parse(matches.group(9));

    var weaknessesString = matches.group(3) ?? matches.group(6);
    if (weaknessesString != null) {
      var weaknesses = List<AttackType>();
      for (var weakness in weaknessesString.split(',')) {
        weaknesses.add(stringToAttackType(weakness.trim()));
      }
      unit.weaknesses = weaknesses;
    }

    var immunitiesString = matches.group(4) ?? matches.group(5);
    if (immunitiesString != null) {
      var immunities = List<AttackType>();
      for (var immunity in immunitiesString.split(',')) {
        immunities.add(stringToAttackType(immunity.trim()));
      }
      unit.immunities = immunities;
    }

    int numberOfUnits = int.parse(matches.group(1));
    var group = Group(type);
    group.units = List<Unit>.filled(numberOfUnits, unit, growable: true);
    combatant.groups.add(group);
  }
  return combatant;
}
