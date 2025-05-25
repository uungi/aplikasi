import 'package:flutter_test/flutter_test.dart';
import 'package:visha2/utils/validators.dart';
import 'package:visha2/utils/input_sanitizer.dart';

void main() {
  group('Validators Tests', () {
    group('validateName', () {
      test('should accept valid names', () {
        expect(Validators.validateName('John Doe'), isNull);
        expect(Validators.validateName('Mary Jane Smith'), isNull);
        expect(Validators.validateName("O'Connor"), isNull);
        expect(Validators.validateName('Jean-Pierre'), isNull);
        expect(Validators.validateName('Dr. Smith'), isNull);
        expect(Validators.validateName('José María'), isNull);
      });

      test('should reject empty or null names', () {
        expect(Validators.validateName(null), isNotNull);
        expect(Validators.validateName(''), isNotNull);
        expect(Validators.validateName('   '), isNotNull);
      });

      test('should reject names that are too short', () {
        expect(Validators.validateName('A'), isNotNull);
        expect(Validators.validateName('X'), isNotNull);
      });

      test('should reject names that are too long', () {
        final longName = 'A' * 51;
        expect(Validators.validateName(longName), isNotNull);
      });

      test('should reject names with invalid characters', () {
        expect(Validators.validateName('John123'), isNotNull);
        expect(Validators.validateName('John@Doe'), isNotNull);
        expect(Validators.validateName('John#Doe'), isNotNull);
        expect(Validators.validateName('John<script>'), isNotNull);
        expect(Validators.validateName('John&Doe'), isNotNull);
      });

      test('should handle edge cases', () {
        expect(Validators.validateName('A B'), isNull); // Minimum valid
        expect(Validators.validateName('A' * 50), isNull); // Maximum valid
      });
    });

    group('validateEmail', () {
      test('should accept valid email addresses', () {
        expect(Validators.validateEmail('user@example.com'), isNull);
        expect(Validators.validateEmail('test.email@domain.co.uk'), isNull);
        expect(Validators.validateEmail('user+tag@example.org'), isNull);
        expect(Validators.validateEmail('123@example.com'), isNull);
        expect(Validators.validateEmail('user@sub.domain.com'), isNull);
      });

      test('should accept empty email (optional field)', () {
        expect(Validators.validateEmail(null), isNull);
        expect(Validators.validateEmail(''), isNull);
        expect(Validators.validateEmail('   '), isNull);
      });

      test('should reject invalid email formats', () {
        expect(Validators.validateEmail('invalid-email'), isNotNull);
        expect(Validators.validateEmail('user@'), isNotNull);
        expect(Validators.validateEmail('@domain.com'), isNotNull);
        expect(Validators.validateEmail('user@domain'), isNotNull);
        expect(Validators.validateEmail('user.domain.com'), isNotNull);
        expect(Validators.validateEmail('user@domain.'), isNotNull);
        expect(Validators.validateEmail('user space@domain.com'), isNotNull);
      });

      test('should reject malicious email attempts', () {
        expect(Validators.validateEmail('user@domain.com<script>'), isNotNull);
        expect(Validators.validateEmail('javascript:alert()@domain.com'), isNotNull);
      });
    });

    group('validatePhone', () {
      test('should accept valid phone numbers', () {
        expect(Validators.validatePhone('1234567890'), isNull);
        expect(Validators.validatePhone('+1 (555) 123-4567'), isNull);
        expect(Validators.validatePhone('555-123-4567'), isNull);
        expect(Validators.validatePhone('+62 812 3456 7890'), isNull);
        expect(Validators.validatePhone('08123456789'), isNull);
      });

      test('should accept empty phone (optional field)', () {
        expect(Validators.validatePhone(null), isNull);
        expect(Validators.validatePhone(''), isNull);
        expect(Validators.validatePhone('   '), isNull);
      });

      test('should reject invalid phone numbers', () {
        expect(Validators.validatePhone('123'), isNotNull); // Too short
        expect(Validators.validatePhone('12345678901234567890'), isNotNull); // Too long
        expect(Validators.validatePhone('abc1234567'), isNotNull); // Contains letters
        expect(Validators.validatePhone('123-456-789a'), isNotNull); // Contains letters
      });
    });

    group('validatePosition', () {
      test('should accept valid positions', () {
        expect(Validators.validatePosition('Software Engineer'), isNull);
        expect(Validators.validatePosition('Senior Frontend Developer'), isNull);
        expect(Validators.validatePosition('Product Manager'), isNull);
        expect(Validators.validatePosition('UI/UX Designer'), isNull);
        expect(Validators.validatePosition('Data Scientist'), isNull);
      });

      test('should reject empty positions', () {
        expect(Validators.validatePosition(null), isNotNull);
        expect(Validators.validatePosition(''), isNotNull);
        expect(Validators.validatePosition('   '), isNotNull);
      });

      test('should reject positions that are too short or long', () {
        expect(Validators.validatePosition('A'), isNotNull);
        expect(Validators.validatePosition('A' * 101), isNotNull);
      });
    });

    group('validateApiKey', () {
      test('should accept valid OpenAI API keys', () {
        expect(Validators.validateApiKey('sk-1234567890abcdef1234567890abcdef1234567890abcdef'), isNull);
        expect(Validators.validateApiKey('sk-proj-1234567890abcdef'), isNull);
      });

      test('should reject invalid API keys', () {
        expect(Validators.validateApiKey(null), isNotNull);
        expect(Validators.validateApiKey(''), isNotNull);
        expect(Validators.validateApiKey('   '), isNotNull);
        expect(Validators.validateApiKey('invalid-key'), isNotNull);
        expect(Validators.validateApiKey('ak-1234567890'), isNotNull); // Wrong prefix
        expect(Validators.validateApiKey('sk-123'), isNotNull); // Too short
      });
    });

    group('validateContact', () {
      test('should accept valid contact information', () {
        expect(Validators.validateContact('john@example.com | +1-555-123-4567'), isNull);
        expect(Validators.validateContact('Phone: 555-123-4567, Email: john@example.com'), isNull);
        expect(Validators.validateContact('123 Main St, City, State 12345'), isNull);
      });

      test('should reject empty contact', () {
        expect(Validators.validateContact(null), isNotNull);
        expect(Validators.validateContact(''), isNotNull);
        expect(Validators.validateContact('   '), isNotNull);
      });

      test('should reject contact that is too short or long', () {
        expect(Validators.validateContact('123'), isNotNull);
        expect(Validators.validateContact('A' * 501), isNotNull);
      });
    });

    group('validateTemplateName', () {
      test('should accept valid template names', () {
        expect(Validators.validateTemplateName('Modern Resume'), isNull);
        expect(Validators.validateTemplateName('Creative CV Template'), isNull);
        expect(Validators.validateTemplateName('Professional Layout'), isNull);
      });

      test('should reject invalid template names', () {
        expect(Validators.validateTemplateName(null), isNotNull);
        expect(Validators.validateTemplateName(''), isNotNull);
        expect(Validators.validateTemplateName('A'), isNotNull);
        expect(Validators.validateTemplateName('A' * 101), isNotNull);
      });
    });

    group('validateTemplateDescription', () {
      test('should accept valid descriptions', () {
        expect(Validators.validateTemplateDescription('A modern template for tech professionals'), isNull);
        expect(Validators.validateTemplateDescription('Creative design with bold colors'), isNull);
      });

      test('should reject invalid descriptions', () {
        expect(Validators.validateTemplateDescription(null), isNotNull);
        expect(Validators.validateTemplateDescription(''), isNotNull);
        expect(Validators.validateTemplateDescription('A' * 501), isNotNull);
      });
    });

    group('validateSectionName', () {
      test('should accept valid section names', () {
        expect(Validators.validateSectionName('Experience'), isNull);
        expect(Validators.validateSectionName('Education'), isNull);
        expect(Validators.validateSectionName('Skills'), isNull);
        expect(Validators.validateSectionName('Projects'), isNull);
      });

      test('should reject invalid section names', () {
        expect(Validators.validateSectionName(null), isNotNull);
        expect(Validators.validateSectionName(''), isNotNull);
        expect(Validators.validateSectionName('A'), isNotNull);
        expect(Validators.validateSectionName('A' * 51), isNotNull);
      });
    });

    group('validateContentLength', () {
      test('should accept content within limits', () {
        expect(Validators.validateContentLength('Short content'), isNull);
        expect(Validators.validateContentLength('A' * 5000), isNull);
        expect(Validators.validateContentLength('A' * 10000), isNull);
      });

      test('should reject content that is too long', () {
        expect(Validators.validateContentLength('A' * 10001), isNotNull);
        expect(Validators.validateContentLength('A' * 20000), isNotNull);
      });

      test('should accept empty content', () {
        expect(Validators.validateContentLength(null), isNull);
        expect(Validators.validateContentLength(''), isNull);
      });
    });

    group('validateFeedback', () {
      test('should accept valid feedback', () {
        expect(Validators.validateFeedback('Great app!'), isNull);
        expect(Validators.validateFeedback('The app works well but could use more templates.'), isNull);
      });

      test('should reject invalid feedback', () {
        expect(Validators.validateFeedback(null), isNotNull);
        expect(Validators.validateFeedback(''), isNotNull);
        expect(Validators.validateFeedback('   '), isNotNull);
        expect(Validators.validateFeedback('A' * 2001), isNotNull);
      });
    });
  });

  group('InputSanitizer Tests', () {
    group('sanitizeText', () {
      test('should remove dangerous characters', () {
        expect(InputSanitizer.sanitizeText('Hello<script>'), equals('Helloscript'));
        expect(InputSanitizer.sanitizeText('Test"quote'), equals('Testquote'));
        expect(InputSanitizer.sanitizeText("Test'quote"), equals('Testquote'));
        expect(InputSanitizer.sanitizeText('Test>arrow'), equals('Testarrow'));
      });

      test('should normalize whitespace', () {
        expect(InputSanitizer.sanitizeText('  Multiple   spaces  '), equals('Multiple spaces'));
        expect(InputSanitizer.sanitizeText('Tab\tand\nnewline'), equals('Tab and newline'));
      });

      test('should preserve safe characters', () {
        expect(InputSanitizer.sanitizeText('Hello World! 123'), equals('Hello World! 123'));
        expect(InputSanitizer.sanitizeText('Email@domain.com'), equals('Email@domain.com'));
        expect(InputSanitizer.sanitizeText('Price: $100'), equals('Price: $100'));
      });
    });

    group('sanitizeName', () {
      test('should only allow name characters', () {
        expect(InputSanitizer.sanitizeName('John123Doe'), equals('JohnDoe'));
        expect(InputSanitizer.sanitizeName('Mary@Jane'), equals('MaryJane'));
        expect(InputSanitizer.sanitizeName("O'Connor-Smith"), equals("O'Connor-Smith"));
        expect(InputSanitizer.sanitizeName('Dr. John'), equals('Dr. John'));
      });
    });

    group('sanitizeEmail', () {
      test('should only allow email characters', () {
        expect(InputSanitizer.sanitizeEmail('USER@DOMAIN.COM'), equals('user@domain.com'));
        expect(InputSanitizer.sanitizeEmail('test<script>@domain.com'), equals('testscript@domain.com'));
        expect(InputSanitizer.sanitizeEmail('user+tag@domain.com'), equals('user+tag@domain.com'));
      });
    });

    group('sanitizePhone', () {
      test('should only allow phone characters', () {
        expect(InputSanitizer.sanitizePhone('123-456-7890abc'), equals('123-456-7890'));
        expect(InputSanitizer.sanitizePhone('+1 (555) 123-4567'), equals('+1 (555) 123-4567'));
        expect(InputSanitizer.sanitizePhone('555.123.4567'), equals('555.123.4567'));
      });
    });

    group('containsSuspiciousContent', () {
      test('should detect script tags', () {
        expect(InputSanitizer.containsSuspiciousContent('<script>alert()</script>'), isTrue);
        expect(InputSanitizer.containsSuspiciousContent('<SCRIPT>'), isTrue);
        expect(InputSanitizer.containsSuspiciousContent('Hello <script'), isTrue);
      });

      test('should detect javascript protocol', () {
        expect(InputSanitizer.containsSuspiciousContent('javascript:alert()'), isTrue);
        expect(InputSanitizer.containsSuspiciousContent('JAVASCRIPT:'), isTrue);
      });

      test('should detect event handlers', () {
        expect(InputSanitizer.containsSuspiciousContent('onclick=alert()'), isTrue);
        expect(InputSanitizer.containsSuspiciousContent('onload ='), isTrue);
        expect(InputSanitizer.containsSuspiciousContent('onmouseover='), isTrue);
      });

      test('should detect eval and expression', () {
        expect(InputSanitizer.containsSuspiciousContent('eval(malicious)'), isTrue);
        expect(InputSanitizer.containsSuspiciousContent('expression('), isTrue);
      });

      test('should detect vbscript and data URLs', () {
        expect(InputSanitizer.containsSuspiciousContent('vbscript:'), isTrue);
        expect(InputSanitizer.containsSuspiciousContent('data:text/html'), isTrue);
      });

      test('should not flag safe content', () {
        expect(InputSanitizer.containsSuspiciousContent('Hello World'), isFalse);
        expect(InputSanitizer.containsSuspiciousContent('john@example.com'), isFalse);
        expect(InputSanitizer.containsSuspiciousContent('Software Engineer'), isFalse);
        expect(InputSanitizer.containsSuspiciousContent('I love JavaScript programming'), isFalse);
      });
    });

    group('isValidLength', () {
      test('should validate length correctly', () {
        expect(InputSanitizer.isValidLength('Hello', minLength: 3, maxLength: 10), isTrue);
        expect(InputSanitizer.isValidLength('Hi', minLength: 3, maxLength: 10), isFalse);
        expect(InputSanitizer.isValidLength('This is too long', minLength: 3, maxLength: 10), isFalse);
        expect(InputSanitizer.isValidLength('   Trimmed   ', minLength: 3, maxLength: 10), isTrue);
      });
    });
  });
}
