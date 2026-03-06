import 'package:test/test.dart';
import '../lib/main.dart' as app;

void main() {
  group('grading logic', () {
    test('grade boundaries', () {
      expect(app._grade(95), 'A');
      expect(app._grade(85), 'B');
      expect(app._grade(75), 'C');
      expect(app._grade(65), 'D');
      expect(app._grade(50), 'F');
    });
  });

  group('score extraction', () {
    test('numeric detection', () {
      final rows = [
        ['Name', 'Score'],
        ['Alice', '92'],
        ['Bob', 78.5],
        ['Carol', null],
        ['Dave', 'not a number'],
      ];
      final scores = app._extractScores(rows);
      expect(scores, containsAll(<double>[92.0, 78.5]));
      expect(scores.length, 2);
    });
  });
}
