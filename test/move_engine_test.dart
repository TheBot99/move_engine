import 'package:flutter_test/flutter_test.dart';

import 'package:move_engine/move_engine.dart';

void main() {
  Pokemon p1 = Pokemon(
      "Charizard", 50, 100, 100, 100, 100, 100, 100, ["Fire, Flying"], "Blaze");

  Pokemon p2 = Pokemon("Venusaur", 50, 100, 100, 100, 100, 100, 100,
      ["Grass, Poison"], "Chlorophyll");

  test('pokemon name', () {
    expect(p1.name, "Charizard");
  });

  test('type effectiveness', () {
    expect(calculateEffectiveness("Electric", "Fire", "Flying"), 2.0);
    expect(calculateEffectiveness("Rock", "Fire", "Flying"), 4.0);
    expect(calculateEffectiveness("Fire", "Grass", null), 2.0);
  });

  test('calc single battle', () {
    expect(calculateSingleBattleDamage(p1, p2, "Flamethrower", false), 38.0);
  });
}
