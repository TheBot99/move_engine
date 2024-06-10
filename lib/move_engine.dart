library move_engine;

import 'type_chart.dart';
import 'move_data_from_name.dart';
import 'move.dart';
import 'dart:math';

class Pokemon {
  String name;
  int level;
  int hp;
  int attack;
  int defense;
  int specialAttack;
  int specialDefense;
  int speed;
  List<String> type;
  String ability;

  Pokemon(
    this.name,
    this.level,
    this.hp,
    this.attack,
    this.defense,
    this.specialAttack,
    this.specialDefense,
    this.speed,
    this.type,
    this.ability,
  );
}

// Function to calculate type effectiveness
double calculateEffectiveness(String attackType, String defenseType1,
    [String? defenseType2]) {
  double effectiveness1 = typeChart[attackType]?[defenseType1] ?? 1.0;
  double effectiveness2 = defenseType2 != null
      ? (typeChart[attackType]?[defenseType2] ?? 1.0)
      : 1.0;
  return effectiveness1 * effectiveness2;
}

// Function to get random factor
double getRandomFactor() {
  return (Random().nextInt(16) + 85) / 100.0;
}

// Function to get STAB multiplier
double getSTAB(String moveType, List<String> userTypes, String ability) {
  bool hasSTAB = userTypes.contains(moveType);
  if (hasSTAB) {
    if (ability == 'Adaptability') {
      return 2.0;
    }
    return 1.5;
  }
  return 1.0;
}

double calculateDamage(
    Pokemon attacker, Pokemon defender, Move move, bool isCrit,
    {bool isMultiTarget = false,
    bool isSecondStrikeOfParentalBond = false,
    String weather = '',
    bool targetUsedGlaiveRush = false,
    bool isZMove = false,
    bool isTeraShieldActive = false,
    bool isAttackerTerastallized = false,
    bool isSameTeraType = false,
    bool isBurned = false}) {
  int level = attacker.level;
  int power = move.power;
  int A =
      move.category == 'physical' ? attacker.attack : attacker.specialAttack;
  int D =
      move.category == 'physical' ? defender.defense : defender.specialDefense;

  if (isCrit) {
    A = max(A, attacker.attack); // Ignoring negative stat stages for crit
    D = min(D, defender.defense); // Ignoring positive stat stages for crit
  }

  double targets = isMultiTarget ? 0.75 : 1.0;
  double PB = isSecondStrikeOfParentalBond ? 0.25 : 1.0;
  double weatherMultiplier = getWeatherMultiplier(move.type, weather);
  double glaiveRush = targetUsedGlaiveRush ? 2.0 : 1.0;
  double critical = isCrit ? 1.5 : 1.0;
  double randomFactor = getRandomFactor();
  double STAB = getSTAB(move.type, attacker.type, attacker.ability);
  double typeEffectiveness = calculateEffectiveness(move.type, defender.type[0],
      defender.type.length > 1 ? defender.type[1] : null);
  double burn =
      (isBurned && move.category == 'physical' && attacker.ability != 'Guts')
          ? 0.5
          : 1.0;
  double other =
      1.0; // This would be calculated based on specific in-battle effects, left as 1.0 for now.
  double zMove = isZMove ? 0.25 : 1.0;
  double teraShield = isTeraShieldActive
      ? (isAttackerTerastallized ? (isSameTeraType ? 0.75 : 0.35) : 0.2)
      : 1.0;

  double modifier = targets *
      PB *
      weatherMultiplier *
      glaiveRush *
      critical *
      randomFactor *
      STAB *
      typeEffectiveness *
      burn *
      other *
      zMove *
      teraShield;

  double baseDamage =
      (((((2 * level / 5 + 2) * power * A / D) / 50) + 2) * modifier)
          .floorToDouble();

  return baseDamage;
}

// Dummy function to get weather multiplier based on the type of move and current weather
double getWeatherMultiplier(String moveType, String weather) {
  if (weather == 'rain') {
    if (moveType == 'Water') return 1.5;
    if (moveType == 'Fire') return 0.5;
  } else if (weather == 'harsh sunlight') {
    if (moveType == 'Fire' || moveType == 'Hydro Steam') return 1.5;
    if (moveType == 'Water' && moveType != 'Hydro Steam') return 0.5;
  }
  return 1.0;
}

double calculateSingleBattleDamage(
    Pokemon p1, Pokemon p2, String moveName, bool isCrit) {
  // p1 will always be the attacking Pokémon
  // p2 will always be the defending Pokémon
  Move moveData = getMoveData(moveName);
  double damage = calculateDamage(p1, p2, moveData, isCrit);
  print("Move: ${moveData.name}, Damage: $damage");
  return damage;
}
