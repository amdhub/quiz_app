import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/home_page.dart';
import 'package:quiz_app/quiz_page.dart';
import 'package:quiz_app/providers/quiz_provider.dart';

void main() {
  // Helper function to pump HomePage with necessary ancestors
  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => QuizProvider(), // QuizzPage will need this when navigated to
        child: MaterialApp(
          home: HomePage(),
          // It's good to define routes if direct navigation is expected,
          // or have a way to push QuizzPage in tests.
          routes: {
            '/quiz': (context) => QuizzPage(),
          },
        ),
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('Initial UI elements are displayed correctly', (WidgetTester tester) async {
      await pumpHomePage(tester);

      // Verify AppBar title
      expect(find.widgetWithText(AppBar, 'Home Page'), findsOneWidget);

      // Verify main image (checking for Image widget; specific path is harder without more direct access)
      // This assumes 'images/cover.jpg' is the only Image.asset on this page directly.
      // A more robust way would be to use a Key on the Image widget.
      expect(find.byType(Image), findsOneWidget, reason: "Cover image should be displayed");
      // To be more specific about which image, if 'images/cover.jpg' is loaded by Image.asset:
      final Image image = tester.widget(find.byType(Image));
      expect((image.image as AssetImage).assetName, 'images/cover.jpg');


      // Verify welcome/description text
      // The text in home_page.dart is "Welcome to the Quiz App! Test your knowledge on various interesting topics."
      expect(find.text("Welcome to the Quiz App! Test your knowledge on various interesting topics."), findsOneWidget);


      // Verify "Commencer le quiz" button
      expect(find.widgetWithText(ElevatedButton, "Commencer le quiz"), findsOneWidget);
    });

    testWidgets('Tapping "Commencer le quiz" button navigates to QuizzPage', (WidgetTester tester) async {
      await pumpHomePage(tester);

      // Ensure HomePage is initially displayed
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(QuizzPage), findsNothing);

      // Tap the "Commencer le quiz" button
      await tester.tap(find.widgetWithText(ElevatedButton, "Commencer le quiz"));
      await tester.pumpAndSettle(); // pumpAndSettle to allow navigation to complete

      // Verify that QuizzPage is now displayed
      expect(find.byType(HomePage), findsNothing, reason: "HomePage should not be visible after navigation");
      expect(find.byType(QuizzPage), findsOneWidget, reason: "QuizzPage should be visible after navigation");
      
      // Also check for an element unique to QuizzPage, e.g., the score in AppBar
      // This requires QuizzPage to be properly set up with QuizProvider
      expect(find.widgetWithText(AppBar, RegExp(r'Score : \d+')), findsOneWidget, reason: "QuizzPage AppBar with score should be present");
    });
  });
}
