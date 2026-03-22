import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart' as app;

void main() {
  group('grading logic', () {
    test('grade boundaries', () {
      expect(app.grade(95), 'A');
      expect(app.grade(85), 'B');
      expect(app.grade(75), 'C');
      expect(app.grade(65), 'D');
      expect(app.grade(50), 'F');
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
      final scores = app.extractScores(rows);
      expect(scores, containsAll(<double>[92.0, 78.5]));
      expect(scores.length, 2);
    });
  });
}
