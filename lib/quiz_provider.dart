import 'package:flutter/material.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/utils/datas.dart';

/// Manages the state of the quiz.
///
/// This includes the list of questions, the current question index, the user's score,
/// and feedback on the user's answers.
class QuizProvider extends ChangeNotifier {
  final List<Question> _questions = Datas().listeQuestions;
  int _currentIndex = 0;
  int _score = 0;

  bool? _userAnswerCorrect;
  bool? _userChoice; // Tracks the boolean value of the user's choice (true for 'Vrai', false for 'Faux')

  /// The index of the current question.
  int get currentIndex => _currentIndex;

  /// The user's current score.
  int get score => _score;

  /// The current [Question] object.
  Question get currentQuestion => _questions[_currentIndex];

  /// The total number of questions in the quiz.
  int get questionsLength => _questions.length;

  /// True if the user's last answer was correct, false if incorrect, null if no answer yet or feedback is cleared.
  bool? get userAnswerCorrect => _userAnswerCorrect;

  /// The user's last choice (true for 'Vrai', false for 'Faux'), null if no choice made or feedback is cleared.
  bool? get userChoice => _userChoice;

  /// Handles the user's answer submission and coordinates UI updates for feedback.
  ///
  /// [userAnswer]: The boolean value of the answer chosen by the user.
  /// [context]: The build context, used for showing dialogs.
  /// [showAnsDialog]: Callback function to show the answer explanation dialog.
  ///   It's expected to take `(BuildContext context, bool isCorrect, VoidCallback onDismissed)` as arguments.
  /// [showResDialog]: Callback function to show the results dialog.
  ///   It's expected to take `(BuildContext context)` as an argument.
  void handleAnswer(
    bool userAnswer,
    BuildContext context,
    Function showAnsDialog, // Consider using typedefs for complex function signatures
    Function showResDialog,
  ) {
    _userChoice = userAnswer;
    final bool correctAnswer = _questions[_currentIndex].answer; // Make local var final
    _userAnswerCorrect = (userAnswer == correctAnswer);

    if (_userAnswerCorrect!) {
      _score++;
    }
    notifyListeners(); // Notify for UI changes (e.g., button colors)

    // Show the explanation dialog and then proceed after it's dismissed.
    showAnsDialog(context, _userAnswerCorrect!, () {
      _clearAnswerFeedbackAndProceed(context, showResDialog);
    });
  }

  /// Clears the answer feedback state and proceeds to the next question or shows results.
  ///
  /// This method is typically called after the user has seen the explanation for their answer.
  /// [context]: The build context (currently unused here but kept for consistency or future use).
  /// [showResDialog]: Callback function to show the results dialog.
  void _clearAnswerFeedbackAndProceed(BuildContext context, Function showResDialog) {
    _userAnswerCorrect = null;
    _userChoice = null;

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners(); // Notify for next question
    } else {
      // Last question: ensure UI is up-to-date before showing results.
      notifyListeners(); 
      showResDialog(context);
    }
  }
  
  /// Synchronously checks an answer. Updates score and internal feedback state.
  ///
  /// **Note:** `handleAnswer` is generally preferred for the main UI flow as it includes dialog interactions
  /// and a more complete state management cycle. This `checkAnswer` method might be useful for specific
  /// scenarios where immediate, synchronous checking without further UI side-effects (like dialogs) is needed.
  /// The caller is responsible for any UI updates based on the returned value if this method is used directly.
  bool checkAnswer(bool answer) {
    final bool correctAnswer = _questions[_currentIndex].answer; // Make local var final
    _userAnswerCorrect = (answer == correctAnswer);
    _userChoice = answer;
    if (_userAnswerCorrect!) {
      _score++;
    }
    // Note: Listeners are not notified here as this is intended for synchronous checks.
    // The calling context should handle UI updates if needed.
    return _userAnswerCorrect!;
  }

  /// Advances to the next question if available.
  /// Also clears any temporary answer feedback state.
  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _userAnswerCorrect = null; // Clear feedback state
      _userChoice = null;
      notifyListeners();
    }
  }

  /// Resets the quiz to its initial state (first question, score 0).
  /// Also clears any temporary answer feedback state.
  void resetQuiz() {
    _currentIndex = 0;
    _score = 0;
    _userAnswerCorrect = null;
    _userChoice = null;
    notifyListeners();
  }
}
