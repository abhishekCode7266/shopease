import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starshop/widgets/custom_button.dart';
import 'package:starshop/widgets/custom_text_field.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('CustomButton renders text and triggers callback',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Add to Cart',
              onPressed: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Verify text is displayed
      expect(find.text('Add to Cart'), findsOneWidget);

      // Tap button
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('CustomButton displays progress indicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit Order',
              isLoading: true,
            ),
          ),
        ),
      );

      // Verify circular progress indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Button text should not be visible when loading
      expect(find.text('Submit Order'), findsNothing);
    });

    testWidgets('CustomTextField renders label, hint and accepts text input',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: 'Email Address',
              hintText: 'Enter your email',
            ),
          ),
        ),
      );

      // Verify label and hint text
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'test@starshop.com');
      await tester.pump();

      expect(controller.text, 'test@starshop.com');
    });
  });
}
