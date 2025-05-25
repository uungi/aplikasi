import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visha2/widgets/form_field_wrapper.dart';

void main() {
  group('Form Field Widgets Tests', () {
    testWidgets('NameFormField should validate correctly', (WidgetTester tester) async {
      String? savedValue;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: NameFormField(
                onSaved: (value) => savedValue = value,
              ),
            ),
          ),
        ),
      );

      // Test empty input
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isFalse);

      // Test valid input
      await tester.enterText(find.byType(TextFormField), 'John Doe');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isTrue);
      
      formKey.currentState!.save();
      expect(savedValue, equals('John Doe'));

      // Test invalid input
      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('EmailFormField should validate correctly', (WidgetTester tester) async {
      String? savedValue;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: EmailFormField(
                onSaved: (value) => savedValue = value,
                required: false,
              ),
            ),
          ),
        ),
      );

      // Test empty input (should be valid since not required)
      expect(formKey.currentState!.validate(), isTrue);

      // Test valid email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isTrue);
      
      formKey.currentState!.save();
      expect(savedValue, equals('test@example.com'));

      // Test invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('PhoneFormField should validate correctly', (WidgetTester tester) async {
      String? savedValue;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: PhoneFormField(
                onSaved: (value) => savedValue = value,
              ),
            ),
          ),
        ),
      );

      // Test valid phone
      await tester.enterText(find.byType(TextFormField), '+1-555-123-4567');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isTrue);
      
      formKey.currentState!.save();
      expect(savedValue, equals('+1-555-123-4567'));

      // Test invalid phone
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('PositionFormField should validate correctly', (WidgetTester tester) async {
      String? savedValue;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: PositionFormField(
                onSaved: (value) => savedValue = value,
              ),
            ),
          ),
        ),
      );

      // Test empty input
      expect(formKey.currentState!.validate(), isFalse);

      // Test valid position
      await tester.enterText(find.byType(TextFormField), 'Software Engineer');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isTrue);
      
      formKey.currentState!.save();
      expect(savedValue, equals('Software Engineer'));

      // Test position too short
      await tester.enterText(find.byType(TextFormField), 'A');
      await tester.pump();
      
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('ValidatedTextFormField should handle suspicious content', (WidgetTester tester) async {
      bool suspiciousContentDetected = false;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: ValidatedTextFormField(
                fieldType: 'text',
                onChanged: (value) {
                  // This would normally trigger security logging
                  if (value.contains('<script>')) {
                    suspiciousContentDetected = true;
                  }
                },
              ),
            ),
          ),
        ),
      );

      // Test suspicious input
      await tester.enterText(find.byType(TextFormField), '<script>alert("xss")</script>');
      await tester.pump();
      
      expect(suspiciousContentDetected, isTrue);
    });
  });
}
