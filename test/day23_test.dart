// Kudos to L for the testing tutorial

import 'package:test/test.dart';
import '../bin/day23/day23.dart';

void main() {
  Nanobot a, b;
  setUp(() {
    a = Nanobot(0, 0, 0, 5);
    b = Nanobot(12, 12, 12, 10);
  });
  
  test('manhattan distance', () {
    expect(a.manhattanDistanceTo(b), 36);
  });
}
