// https://adventofcode.com/2018/day/24

import 'dart:io';

const USE_SAMPLE_DATA = true;

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
  List<Unit> units;
  Type armyType;
  bool selectedForAttack = false;

  // the number of units in that group multiplied by their attack damage
  int get effectivePower => units.length * units.first.attackDamage;

  Group(this.armyType) {
    units = List<Unit>();
  }

  int getDamage(Group defender) {
    if (defender.units.first.immunities.contains(units.first.attackType))
      return 0;
    else if (defender.units.first.weaknesses.contains(units.first.attackType))
      return 2 * effectivePower;
    else
      return effectivePower;
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
    allGroups.sort();
    print(allGroups.length);
    for (var attacker in allGroups.reversed) {
      // TODO check if attacker is tied with next attacker. Rewrite as for loop?
      for (var defender in allGroups) {
        if (attacker.armyType == defender.armyType ||
            defender.selectedForAttack) continue;
      }
    }

    // Attack

    gameOn = false;
  }
}

Combatant getArmy(Type type, List<String> records) {
  var combatant = (type == ImmuneSystem) ? ImmuneSystem() : Infection();
  var betterRegex1 = RegExp(
      r'(\d+) units each with (\d+) hit points (?:\((?:(weak to [a-z,\s]+);?\s?(immune to [a-z,\s]+)*;?\s?|(immune to [a-z,\s]+);?\s?(weak to [a-z,\s]+)*;?\s?)\))*\s?with an attack that does (\d+) ([a-z]+) damage at initiative (\d+)');
  var betterRegex = RegExp(
      r'(\d+) units each with (\d+) hit points (?:\((?:(?:weak to ([a-z,\s]+));?\s?(?:immune to ([a-z,\s]+))*;?\s?|(?:immune to ([a-z,\s]+));?\s?(?:weak to ([a-z,\s]+))*;?\s?)\))*\s?with an attack that does (\d+) ([a-z]+) damage at initiative (\d+)');
  for (var record in records) {
    var matches = betterRegex.allMatches(record).first;

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
    group.units = List<Unit>.filled(numberOfUnits, unit);
    combatant.groups.add(group);
  }
  return combatant;
}
