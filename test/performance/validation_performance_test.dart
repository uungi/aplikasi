import 'package:flutter_test/flutter_test.dart';
import 'package:visha2/utils/validators.dart';
import 'package:visha2/utils/input_sanitizer.dart';

void main() {
  group('Performance Tests', () {
    test('validation should be fast for normal inputs', () {
      final stopwatch = Stopwatch()..start();
      
      // Test 1000 validations
      for (int i = 0; i < 1000; i++) {
        Validators.validateName('John Doe $i');
        Validators.validateEmail('user$i@example.com');
        Validators.validatePhone('+1-555-123-${i.toString().padLeft(4, '0')}');
        Validators.validatePosition('Software Engineer $i');
      }
      
      stopwatch.stop();
      
      // Should complete in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      print('1000 validations completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('sanitization should be fast for large inputs', () {
      final largeInput = 'A' * 10000;
      final stopwatch = Stopwatch()..start();
      
      // Test 100 sanitizations of large input
      for (int i = 0; i < 100; i++) {
        InputSanitizer.sanitizeText(largeInput);
      }
      
      stopwatch.stop();
      
      // Should complete in less than 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      print('100 large input sanitizations completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('suspicious content detection should be fast', () {
      final suspiciousInputs = [
        '<script>alert("xss")</script>',
        'javascript:alert(1)',
        'onclick="malicious()"',
        'eval(dangerous)',
        'expression(hack)',
      ];
      
      final stopwatch = Stopwatch()..start();
      
      // Test 1000 suspicious content checks
      for (int i = 0; i < 1000; i++) {
        for (final input in suspiciousInputs) {
          InputSanitizer.containsSuspiciousContent(input);
        }
      }
      
      stopwatch.stop();
      
      // Should complete in less than 200ms
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      print('5000 suspicious content checks completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('memory usage should be reasonable', () {
      final inputs = List.generate(1000, (i) => 'Test input $i with some content');
      
      // Process all inputs
      final results = inputs.map((input) {
        final sanitized = InputSanitizer.sanitizeText(input);
        final isValid = Validators.validateRequired(sanitized, 'test') == null;
        return {'sanitized': sanitized, 'valid': isValid};
      }).toList();
      
      // Verify results are correct
      expect(results.length, equals(1000));
      expect(results.every((r) => r['valid'] == true), isTrue);
    });
  });
}
