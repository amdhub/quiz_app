import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/utils/datas.dart'; // Import Datas to access the question list directly for verification

void main() {
  group('QuizProvider', () {
    late QuizProvider quizProvider;

    setUp(() {
      quizProvider = QuizProvider();
    });

    test('Initial values are correct', () {
      expect(quizProvider.currentIndex, 0);
      expect(quizProvider.score, 0);
      expect(quizProvider.userAnswerCorrect, null);
      expect(quizProvider.userChoice, null);
      expect(quizProvider.questionsLength, greaterThan(0), reason: "Question list should be loaded and not empty."); 
      expect(quizProvider.currentQuestion, isA<Question>(), reason: "Initial current question should be a Question object.");
      
      // Verify the first question's content if possible
      if (Datas().listeQuestions.isNotEmpty) {
        final Question expectedFirstQuestion = Datas().listeQuestions.first;
        expect(quizProvider.currentQuestion.questionText, expectedFirstQuestion.questionText, reason: "Initial current question should match the first question from Datas.");
        expect(quizProvider.currentQuestion.answer, expectedFirstQuestion.answer);
      }
    });

    group('checkAnswer', () {
      test('correct answer increments score and sets feedback', () {
        final initialScore = quizProvider.score;
        final Question firstQuestion = quizProvider.currentQuestion;
        final bool correctAnswer = firstQuestion.answer;

        final bool result = quizProvider.checkAnswer(correctAnswer);

        expect(result, isTrue);
        expect(quizProvider.score, initialScore + 1);
        expect(quizProvider.userAnswerCorrect, isTrue);
        expect(quizProvider.userChoice, correctAnswer);
      });

      test('incorrect answer does not increment score and sets feedback', () {
        final initialScore = quizProvider.score;
        final Question firstQuestion = quizProvider.currentQuestion;
        final bool incorrectAnswer = !firstQuestion.answer;

        final bool result = quizProvider.checkAnswer(incorrectAnswer);

        expect(result, isFalse);
        expect(quizProvider.score, initialScore);
        expect(quizProvider.userAnswerCorrect, isFalse);
        expect(quizProvider.userChoice, incorrectAnswer);
      });
    });

    group('nextQuestion', () {
      test('increments currentIndex and updates currentQuestion', () {
        final int initialIndex = quizProvider.currentIndex;
        if (quizProvider.questionsLength > 1) {
          final Question initialQuestion = quizProvider.currentQuestion;
          quizProvider.nextQuestion();
          expect(quizProvider.currentIndex, initialIndex + 1);
          expect(quizProvider.currentQuestion, isNot(equals(initialQuestion)));
          expect(quizProvider.userAnswerCorrect, null); // Should reset feedback
          expect(quizProvider.userChoice, null);      // Should reset feedback
        } else {
          // Test behavior if only one question or no questions - nextQuestion might not change index
           quizProvider.nextQuestion();
           expect(quizProvider.currentIndex, initialIndex); // Stays the same
        }
      });

      test('does not increment currentIndex beyond the last question', () {
        // Navigate to the last question
        while (quizProvider.currentIndex < quizProvider.questionsLength - 1) {
          quizProvider.nextQuestion();
        }
        final int lastIndex = quizProvider.currentIndex;
        quizProvider.nextQuestion(); // Try to go beyond
        expect(quizProvider.currentIndex, lastIndex); // Should remain at the last question
      });
    });
    
    group('handleAnswer (simplified testing focusing on state changes before dialogs)', () {
      // Mocking BuildContext and dialog functions is complex without a proper framework.
      // We will test the immediate state changes that occur within handleAnswer
      // before it calls the dialog functions. The progression logic is in _clearAnswerFeedbackAndProceed.

      test('correct answer updates score and feedback state via handleAnswer', () {
        final initialScore = quizProvider.score;
        final Question firstQuestion = quizProvider.currentQuestion;
        final bool correctAnswer = firstQuestion.answer;

        // We can't easily test the full flow with dialogs here,
        // so we're checking the state *after* handleAnswer is called,
        // but *before* the dialog's onDismissed would trigger further changes.
        quizProvider.handleAnswer(correctAnswer, MockBuildContext(), (a,b,c){}, (d){});

        expect(quizProvider.score, initialScore + 1);
        expect(quizProvider.userAnswerCorrect, isTrue);
        expect(quizProvider.userChoice, correctAnswer);
        // Note: _clearAnswerFeedbackAndProceed is not called yet in this simplified test setup
      });

      test('incorrect answer updates feedback state (score unchanged yet) via handleAnswer', () {
        final initialScore = quizProvider.score;
        final Question firstQuestion = quizProvider.currentQuestion;
        final bool incorrectAnswer = !firstQuestion.answer;

        quizProvider.handleAnswer(incorrectAnswer, MockBuildContext(), (a,b,c){}, (d){});
        
        expect(quizProvider.score, initialScore); // Score is not changed by incorrect answer itself
        expect(quizProvider.userAnswerCorrect, isFalse);
        expect(quizProvider.userChoice, incorrectAnswer);
      });
    });

    group('_clearAnswerFeedbackAndProceed (tested implicitly via handleAnswer + manual call)',(){
      test('resets feedback and proceeds to next question', (){
        final int initialIndex = quizProvider.currentIndex;
        quizProvider.handleAnswer(true, MockBuildContext(), (ctx, isCorrect, onDismissed) {
          // Simulate dismissing the answer dialog, which calls the onDismissed callback
          onDismissed(); 
        }, (ctx) {
          // This is the showResultDialog, should not be called if not last question
        });

        // After onDismissed (which is _clearAnswerFeedbackAndProceed) is called:
        expect(quizProvider.userAnswerCorrect, null);
        expect(quizProvider.userChoice, null);
        if (quizProvider.questionsLength > 1 && initialIndex < quizProvider.questionsLength -1) {
            expect(quizProvider.currentIndex, initialIndex + 1);
        } else {
            expect(quizProvider.currentIndex, initialIndex); // Or should go to result. Test result separately.
        }
      });

       test('resets feedback and calls showResultDialog on last question', (){
        bool showResultCalled = false;
        
        // Go to the last question
        quizProvider.resetQuiz(); // Ensure a clean state before navigating
        while(quizProvider.currentIndex < quizProvider.questionsLength - 1) {
          quizProvider.nextQuestion();
        }
        // At this point, quizProvider.currentIndex should be questionsLength - 1

        // Provide an answer to the last question
        // The actual answer (true/false) doesn't matter much for this specific test's focus (calling showResultDialog)
        // but it's good practice to use a valid answer.
        final bool answerToLastQuestion = quizProvider.currentQuestion.answer;
        
        final int lastQuestionIndex = quizProvider.currentIndex; // Should be questionsLength - 1
        expect(lastQuestionIndex, quizProvider.questionsLength - 1, reason: "Test setup: Should be on the last question.");

        quizProvider.handleAnswer(answerToLastQuestion, MockBuildContext(), (ctx, isCorrect, onDismissed) {
          onDismissed(); 
        }, (ctx) {
          showResultCalled = true;
        });

        expect(quizProvider.userAnswerCorrect, null);
        expect(quizProvider.userChoice, null);
        expect(quizProvider.currentIndex, lastQuestionIndex); // Stays on last question index
        expect(showResultCalled, isTrue);
      });
    });

    test('resetQuiz resets state correctly', () {
      // Modify state first
      if (quizProvider.questionsLength > 1) quizProvider.nextQuestion();
      quizProvider.checkAnswer(true); // arbitrary answer
      
      quizProvider.resetQuiz();

      expect(quizProvider.currentIndex, 0);
      expect(quizProvider.score, 0);
      expect(quizProvider.userAnswerCorrect, null);
      expect(quizProvider.userChoice, null);
      if (quizProvider.questionsLength > 0) {
        expect(quizProvider.currentQuestion, isA<Question>());
        // Could also compare to Datas().listeQuestions.first again if needed
      }
    });
  });
}

// Basic mock for BuildContext if needed by methods, though QuizProvider doesn't use it directly.
class MockBuildContext implements BuildContext {
  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object aspect = const Object()}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeElement(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    throw UnimplementedError();
  }

  @override
  RenderObject? findRenderObject() {
    throw UnimplementedError();
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {
  }

  @override
  void visitChildElements(ElementVisitor visitor) {
  }
  
  @override
  // TODO: implement mounted
  bool get mounted => throw UnimplementedError();
  
  @override
  // TODO: implement owner
  BuildOwner? get owner => throw UnimplementedError();
  
  @override
  // TODO: implement widget
  Widget get widget => throw UnimplementedError();
  
  @override
  BuildContext? get ancestorBuildContext => throw UnimplementedError();
  
  @override
  InheritedElement? get ancestorInheritedElementForWidgetOfExactType => throw UnimplementedError();
  
  @override
  RenderObject? get ancestorRenderObject => throw UnimplementedError();
  
  @override
  State<StatefulWidget>? get ancestorState => throw UnimplementedError();
  
  @override
  StatefulElement? get ancestorStatefulElementForWidgetOfExactType => throw UnimplementedError();
  
  @override
  Widget? get ancestorWidget => throw UnimplementedError();
  
  @override
  // TODO: implement devicePixelRatio
  double get devicePixelRatio => throw UnimplementedError();
  
  @override
  // TODO: implement package
  String? get package => throw UnimplementedError();
  
  @override
  // TODO: implement renderView
  RenderView get renderView => throw UnimplementedError();
  
  @override
  // TODO: implement size
  Size? get size => throw UnimplementedError();
  
  @override
  // TODO: implement valid
  bool get valid => throw UnimplementedError();
}
