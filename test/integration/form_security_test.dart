import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:visha2/main.dart' as app;
import 'package:visha2/screens/input_screen.dart';
import 'package:visha2/screens/api_key_setup_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Form Security Integration Tests', () {
    testWidgets('Input Screen should handle malicious input safely', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to input screen
      await tester.tap(find.text('Create Resume'));
      await tester.pumpAndSettle();

      // Test XSS attempt in name field
      await tester.enterText(
        find.byKey(const Key('name_field')), 
        '<script>alert("xss")</script>John Doe'
      );
      await tester.pump();

      // Test SQL injection attempt in position field
      await tester.enterText(
        find.byKey(const Key('position_field')), 
        "'; DROP TABLE users; --"
      );
      await tester.pump();

      // Test HTML injection in experience field
      await tester.enterText(
        find.byKey(const Key('experience_field')), 
        '<img src="x" onerror="alert(1)">'
      );
      await tester.pump();

      // Try to submit form
      await tester.tap(find.text('Generate Resume'));
      await tester.pump();

      // Verify that malicious content is either rejected or sanitized
      // The form should either show validation errors or sanitize the input
      expect(find.text('Invalid characters detected'), findsAnyWidget);
    });

    testWidgets('API Key Setup should validate key format', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to API key setup
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('API Key Management'));
      await tester.pumpAndSettle();

      // Test invalid API key formats
      final invalidKeys = [
        'invalid-key',
        'ak-1234567890', // Wrong prefix
        'sk-123', // Too short
        '<script>alert("xss")</script>',
        'javascript:alert(1)',
      ];

      for (final invalidKey in invalidKeys) {
        await tester.enterText(find.byType(TextFormField), invalidKey);
        await tester.pump();
        
        await tester.tap(find.text('Save API Key'));
        await tester.pump();
        
        // Should show validation error
        expect(find.textContaining('Invalid'), findsAnyWidget);
        
        // Clear the field
        await tester.enterText(find.byType(TextFormField), '');
        await tester.pump();
      }

      // Test valid API key
      await tester.enterText(
        find.byType(TextFormField), 
        'sk-1234567890abcdef1234567890abcdef1234567890abcdef'
      );
      await tester.pump();
      
      await tester.tap(find.text('Save API Key'));
      await tester.pump();
      
      // Should show success message
      expect(find.textContaining('saved'), findsAnyWidget);
    });

    testWidgets('Template Editor should sanitize template content', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to template editor
      await tester.tap(find.text('Templates'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Test malicious template name
      await tester.enterText(
        find.byKey(const Key('template_name_field')), 
        '<script>alert("xss")</script>Malicious Template'
      );
      await tester.pump();

      // Test malicious template description
      await tester.enterText(
        find.byKey(const Key('template_description_field')), 
        'javascript:alert(1)//Description'
      );
      await tester.pump();

      // Try to save template
      await tester.tap(find.text('Save Template'));
      await tester.pump();

      // Should either reject or sanitize the input
      expect(find.textContaining('Invalid'), findsAnyWidget);
    });

    testWidgets('Feedback form should handle large input safely', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Scroll to feedback section
      await tester.scrollUntilVisible(
        find.text('Feedback'),
        500.0,
      );

      // Test extremely large input
      final largeInput = 'A' * 5000;
      await tester.enterText(
        find.byKey(const Key('feedback_field')), 
        largeInput
      );
      await tester.pump();

      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();

      // Should show length validation error
      expect(find.textContaining('too long'), findsAnyWidget);
    });
  });
}
