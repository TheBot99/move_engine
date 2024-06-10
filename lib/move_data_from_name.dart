import 'package:move_engine/moves.dart';

dynamic getMoveData(String moveName) {
  switch (moveName) {
    case 'Flamethrower':
      return Flamethrower();
    default:
      throw Exception('Class $moveName not found.');
  }
}
