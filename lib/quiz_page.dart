import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/quiz_provider.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/text_with_style.dart';

/// Displays the quiz page, including questions, progress, and answer options.
///
/// Manages the UI for the quiz interaction, relying on [QuizProvider] for state management.
class QuizzPage extends StatelessWidget {
  const QuizzPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain QuizProvider and current question from the context.
    final QuizProvider quizProvider = Provider.of<QuizProvider>(context);
    final Question question = quizProvider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        // Title displays the current score, dynamically updated.
        title: Text('Score : ${quizProvider.score}'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(8), // Consistent margin around the card.
          child: Padding(
            padding: const EdgeInsets.all(8), // Consistent padding inside the card.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between elements.
              children: [
                // Displays the current question number and total questions.
                TextWithStyle(
                  data: "Question numero: ${quizProvider.currentIndex + 1} / ${quizProvider.questionsLength}",
                  color: Colors.deepOrange,
                  style: FontStyle.italic,
                ),
                // Progress bar showing quiz progress.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: LinearProgressIndicator(
                    value: (quizProvider.currentIndex + 1) / quizProvider.questionsLength,
                    backgroundColor: Colors.grey[300], // Background color for the progress bar.
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Color of the progress itself.
                  ),
                ),
                // Displays the current question text, allowing scrolling for long questions.
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextWithStyle(
                        data: question.questionText,
                        size: 20,
                        weight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Displays the image associated with the current question, scaled appropriately.
                Expanded(
                  flex: 2, // Gives more space to the image compared to other flexible widgets.
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35, // Max height relative to screen.
                        maxWidth: MediaQuery.of(context).size.width * 0.8,   // Max width relative to screen.
                      ),
                      child: FittedBox(
                        fit: BoxFit.contain, // Ensures the image fits while maintaining aspect ratio.
                        child: Image.asset(question.getImage()), // Dynamically loads the question image.
                      ),
                    ),
                  ),
                ),
                // Row containing the answer buttons ('Vrai' and 'Faux').
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max, // Row takes full width.
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space buttons.
                    children: [
                      Expanded(child: answerButton(context, false)), // 'False' answer button.
                      const SizedBox(width: 10), // Spacer between buttons.
                      Expanded(child: answerButton(context, true)),  // 'True' answer button.
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an answer button (True or False) with dynamic styling based on quiz state.
  ///
  /// [context]: The build context.
  /// [buttonValue]: The boolean value this button represents (true for 'Vrai', false for 'Faux').
  Widget answerButton(BuildContext context, bool buttonValue) {
    final QuizProvider quizProvider = Provider.of<QuizProvider>(context, listen: true);
    final bool? userAnswerCorrect = quizProvider.userAnswerCorrect;
    final bool? userChoice = quizProvider.userChoice;
    final Question currentQuestion = quizProvider.currentQuestion;

    Color buttonColor; // Default color is determined by the feedback phase.

    // Determine button color based on feedback state from QuizProvider.
    if (userAnswerCorrect != null) { // Feedback phase: an answer has been submitted.
      if (buttonValue == currentQuestion.answer) { // This button is the correct answer.
        buttonColor = Colors.green;
      } else if (userChoice == buttonValue) { // This button was chosen by the user and is incorrect.
        buttonColor = Colors.red;
      } else { // This button is incorrect and was not chosen.
        buttonColor = Colors.grey.shade300; // Dimmed color.
      }
    } else { // Normal phase: awaiting user answer.
      buttonColor = buttonValue ? Colors.greenAccent.shade100 : Colors.redAccent.shade100; // Default button colors.
    }

    return ElevatedButton(
      // Disable button during feedback phase to prevent multiple submissions.
      onPressed: (userAnswerCorrect != null)
          ? null // Disabled if feedback is active.
          : () {
              // Handle answer submission via QuizProvider.
              quizProvider.handleAnswer(buttonValue, context, _showAnswerDialog, _showResultDialog);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor, // Dynamically set button color.
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Button padding.
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Button text style.
      ),
      child: Text(buttonValue ? 'Vrai' : 'Faux'), // Text on the button.
    );
  }

  /// Displays a dialog showing if the answer was correct, along with an explanation.
  ///
  /// [context]: The build context for the dialog.
  /// [isCorrect]: Boolean indicating if the user's answer was correct.
  /// [onDismissed]: Callback to execute when the dialog is dismissed by the user.
  Future<void> _showAnswerDialog(BuildContext context, bool isCorrect, VoidCallback onDismissed) async {
    final QuizProvider quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final Question question = quizProvider.currentQuestion;
    final String title = isCorrect ? 'Bonne reponse' : 'Mauvaise reponse';
    final String imageToShow = isCorrect ? 'vrai.jpg' : 'faux.jpg'; // Image name based on correctness.
    final String path = 'images/$imageToShow'; // Full path to the image.

    return await showDialog(
      barrierDismissible: false, // User must tap the button to dismiss.
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextWithStyle(data: title, textAlign: TextAlign.center), // Dialog title.
          ),
          contentPadding: const EdgeInsets.all(12.0), // Padding for dialog content.
          children: [
            // Image illustrating correct/incorrect answer.
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.25),
              child: FittedBox(fit: BoxFit.contain, child: Image.asset(path)),
            ),
            const SizedBox(height: 10), // Spacer.
            // Explanation text for the answer.
            Flexible(
              child: SingleChildScrollView(
                child: TextWithStyle(data: question.explication, textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 10), // Spacer.
            // Button to dismiss dialog and continue the quiz.
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog.
                onDismissed(); // Execute the callback to proceed (e.g., next question).
              },
              child: const TextWithStyle(data: "Continuer", textAlign: TextAlign.center),
            )
          ],
        );
      },
    );
  }

  /// Displays the final results dialog with the user's score.
  ///
  /// [context]: The build context for the dialog.
  Future<void> _showResultDialog(BuildContext context) async {
    final QuizProvider quizProvider = Provider.of<QuizProvider>(context, listen: false);
    return await showDialog(
      barrierDismissible: false, // User must tap the button to dismiss.
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const TextWithStyle(data: 'Resultat du quiz', textAlign: TextAlign.center), // Dialog title.
          // Content displays the final score.
          content: TextWithStyle(data: 'Votre score est de ${quizProvider.score} / ${quizProvider.questionsLength}', textAlign: TextAlign.center),
          actions: [
            // Button to close the quiz and go back to the previous screen (likely HomePage).
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Dismiss the results dialog.
                quizProvider.resetQuiz();    // Reset quiz state for a potential new game.
                Navigator.of(context).pop(); // Pop QuizzPage from navigation stack.
              },
              child: const TextWithStyle(data: "Terminer", textAlign: TextAlign.center),
            )
          ],
        );
      },
    );
  }
}