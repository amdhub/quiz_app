import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/quiz_page.dart';
import 'package:quiz_app/utils/datas.dart'; // For accessing question data directly if needed for verification

// Helper function to pump QuizzPage with necessary ancestors
Future<void> pumpQuizzPage(WidgetTester tester, {QuizProvider? quizProvider}) async {
  final provider = quizProvider ?? QuizProvider();
  await tester.pumpWidget(
    ChangeNotifierProvider<QuizProvider>.value(
      value: provider,
      child: MaterialApp(
        home: QuizzPage(),
        // Navigator observers can be added here if needed for more detailed nav testing
      ),
    ),
  );
}

void main() {
  group('QuizzPage Widget Tests', () {
    late QuizProvider quizProvider;
    final List<Question> allQuestions = Datas().listeQuestions; // Get all questions for reference

    setUp(() {
      quizProvider = QuizProvider(); // Fresh provider for each test
    });

    testWidgets('Initial UI elements are displayed correctly', (WidgetTester tester) async {
      await pumpQuizzPage(tester, quizProvider: quizProvider);

      // Verify AppBar title with initial score
      expect(find.widgetWithText(AppBar, 'Score : 0'), findsOneWidget);

      // Verify question number
      expect(find.text('Question numero: 1 / ${allQuestions.length}'), findsOneWidget);

      // Verify LinearProgressIndicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify first question's text
      expect(find.text(allQuestions.first.questionText), findsOneWidget);

      // Verify first question's image
      expect(find.byWidgetPredicate((widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == allQuestions.first.getImage()), findsOneWidget, reason: "First question's image should be displayed.");


      // Verify answer buttons
      expect(find.widgetWithText(ElevatedButton, 'Vrai'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Faux'), findsOneWidget);
    });

    testWidgets('Answering a question correctly updates UI and shows dialog', (WidgetTester tester) async {
      await pumpQuizzPage(tester, quizProvider: quizProvider);

      final Question firstQuestion = allQuestions.first;
      final bool correctAnswer = firstQuestion.answer; // True or False

      // Tap the correct answer button
      await tester.tap(find.widgetWithText(ElevatedButton, correctAnswer ? 'Vrai' : 'Faux'));
      await tester.pumpAndSettle(); // Allow UI to update and dialog to show

      // Verify score updates in AppBar
      expect(find.widgetWithText(AppBar, 'Score : 1'), findsOneWidget);

      // Verify that the answer dialog appears
      expect(find.byType(SimpleDialog), findsOneWidget);
      expect(find.text('Bonne reponse'), findsOneWidget); // Dialog title
      expect(find.text(firstQuestion.explication), findsOneWidget); // Explanation

      // Tap "Continuer" button in the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
      await tester.pumpAndSettle(); // Allow dialog to close and UI to update

      // Verify dialog is closed
      expect(find.byType(SimpleDialog), findsNothing);

      // Verify next question is displayed (if there is one)
      if (allQuestions.length > 1) {
        expect(find.text('Question numero: 2 / ${allQuestions.length}'), findsOneWidget);
        expect(find.text(allQuestions[1].questionText), findsOneWidget);
      } else {
        // If only one question, result dialog should show
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Resultat du quiz'), findsOneWidget);
      }
    });

    testWidgets('Answering a question incorrectly updates UI and shows dialog', (WidgetTester tester) async {
      await pumpQuizzPage(tester, quizProvider: quizProvider);

      final Question firstQuestion = allQuestions.first;
      final bool incorrectAnswer = !firstQuestion.answer; // Opposite of the correct answer

      // Tap the incorrect answer button
      await tester.tap(find.widgetWithText(ElevatedButton, incorrectAnswer ? 'Vrai' : 'Faux'));
      await tester.pumpAndSettle();

      // Verify score does NOT update in AppBar
      expect(find.widgetWithText(AppBar, 'Score : 0'), findsOneWidget);

      // Verify that the answer dialog appears
      expect(find.byType(SimpleDialog), findsOneWidget);
      expect(find.text('Mauvaise reponse'), findsOneWidget); // Dialog title
      expect(find.text(firstQuestion.explication), findsOneWidget); // Explanation

      // Tap "Continuer" button in the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(SimpleDialog), findsNothing);

      // Verify next question is displayed (if there is one)
      if (allQuestions.length > 1) {
        expect(find.text('Question numero: 2 / ${allQuestions.length}'), findsOneWidget);
      } else {
        expect(find.byType(AlertDialog), findsOneWidget); // Result dialog
      }
    });

    testWidgets('Quiz completion shows result dialog and navigates back on "Terminer"', (WidgetTester tester) async {
      // This test assumes there are at least 2 questions to properly test progression.
      // If not, adjust or skip parts. For this example, we'll assume enough questions.
      if (allQuestions.length < 1) return; // Skip if no questions

      await pumpQuizzPage(tester, quizProvider: quizProvider);

      // Answer all questions
      for (int i = 0; i < allQuestions.length; i++) {
        final Question currentQuestion = allQuestions[i];
        final bool answer = currentQuestion.answer; // Just answer correctly to proceed quickly

        // Tap the answer button
        await tester.tap(find.widgetWithText(ElevatedButton, answer ? 'Vrai' : 'Faux'));
        await tester.pumpAndSettle();

        // If it's not the last question's answer dialog, dismiss it
        if (i < allQuestions.length -1) {
             expect(find.byType(SimpleDialog), findsOneWidget, reason: "Answer dialog should appear for question ${i+1}");
             await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
             await tester.pumpAndSettle();
        } else {
            // After answering the last question and dismissing its SimpleDialog (if any, depends on provider logic)
            // The QuizProvider's logic should lead to the result dialog.
            // The current handleAnswer logic shows SimpleDialog first, then _clearAnswerFeedbackAndProceed calls showResultDialog.
            expect(find.byType(SimpleDialog), findsOneWidget, reason: "Answer dialog for last question ${i+1}");
            await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
            await tester.pumpAndSettle();

            // Now the result dialog should appear
            expect(find.byType(AlertDialog), findsOneWidget, reason: "Result dialog should appear after last question's answer dialog");
        }
      }
      
      // Verify result dialog is present
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Resultat du quiz'), findsOneWidget);
      // Since all questions are answered correctly in this test loop:
      expect(find.text('Votre score est de ${allQuestions.length} / ${allQuestions.length}'), findsOneWidget, reason: "Final score should be perfect as all answers were correct.");


      // Tap "Terminer" button
      expect(find.widgetWithText(TextButton, "Terminer"), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Terminer'));
      await tester.pumpAndSettle(); // Allow navigation to complete

      // Verify dialog is closed and QuizzPage is no longer visible
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(QuizzPage), findsNothing, reason: "QuizzPage should be popped after 'Terminer'");
      // Depending on how navigation is set up, it might go back to HomePage or just an empty space if HomePage wasn't pushed first.
      // In this test setup, it will go to an empty MaterialApp home if not handled.
      // For a real app, you'd verify it lands on the expected previous screen.
    });
  });
}
