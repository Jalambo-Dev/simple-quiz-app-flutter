import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_quiz_app_flutter/models/question_model.dart';
import 'package:simple_quiz_app_flutter/screens/result_screen.dart';
import 'package:simple_quiz_app_flutter/widgets/next_button_widget.dart';
import 'package:simple_quiz_app_flutter/widgets/option_button_widget.dart';
import 'package:simple_quiz_app_flutter/widgets/progress_bar_widget.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  int _currentIndex = 0;
  QuestionModel _currentQuestion = quizData[0];
  bool isAnswered = false; // Tracks whether the user has answered
  int? selectedIndex; // Tracks the selected answer index
  bool isCorrect = false; // Tracks whether the selected answer is correct
  int score = 0;

  late double _percentage = 0.0;

  // Go to new question
  void nextQuestion() {
    setState(() {
      if (_currentIndex == 9) {
        getRusult();
      } else {
        _currentIndex++;
        _currentQuestion = quizData[_currentIndex];
        isAnswered = false; // Reset for the next question
        selectedIndex = null; // Clear the selected index
        _percentage += 0.1;
      }
    });
  }

  // Get Score in the result screen
  void getRusult() {
    Navigator.pushReplacement(
        context,
        CupertinoModalPopupRoute(
          builder: (context) => ResultScreen(score: score),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Simple Flutter Quiz'.toUpperCase()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Index of question
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          'Question: ${_currentQuestion.id}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 9),

                      // Progress Bar
                      ProgressBarWidget(
                        width: MediaQuery.of(context).size.width,
                        heigth: 2.5,
                        progress: _percentage,
                      ),

                      const SizedBox(height: 18),

                      // Question
                      Text(
                        _currentQuestion.question,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.start,
                      ),

                      const SizedBox(height: 18),

                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _currentQuestion.options.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) =>
                            _buildOptionButton(index),
                      ),
                    ],
                  ),
                ),
              ),

              // Button to go to the next question at the bottom
              Visibility(
                visible: isAnswered,
                replacement: NextButtonWidget(
                  onPressed: nextQuestion,
                  text: 'Skip',
                ),
                child: NextButtonWidget(
                  onPressed: nextQuestion,
                  text: 'Next',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    // Check if this option is selected
    bool isSelected = selectedIndex == index;
    // Check if this is the correct option
    bool isCorrectOption = index == _currentQuestion.answerIndex;

    return OptionButtonWidget(
      text: _currentQuestion.options[index],
      backgroundColor: _getBackgroundColor(isSelected, isCorrectOption),
      onTap:
          !isAnswered ? () => _handleOptionTap(index, isCorrectOption) : null,
      visible: true, // Ensure icon is visible
      iconData: _getIconData(isSelected, isCorrectOption),
      iconDataColor: _getIconDataColor(isSelected, isCorrectOption),
    );
  }

  Color _getBackgroundColor(bool isSelected, bool isCorrectOption) {
    if (isAnswered) {
      if (isSelected) {
        return isCorrect
            ? const Color.fromARGB(255, 32, 104, 36)
            : const Color.fromARGB(255, 122, 25, 18);
      } else {
        return isCorrectOption
            ? const Color.fromARGB(255, 32, 104, 36)
            : Theme.of(context).colorScheme.secondary;
      }
    }
    return Theme.of(context).colorScheme.secondary;
  }

  void _handleOptionTap(int index, bool isCorrectOption) {
    setState(() {
      selectedIndex = index; // Update selected index
      isAnswered = true; // Mark the question as answered
      isCorrect = isCorrectOption; // Check if selected option is correct
      if (isCorrect) {
        log("Correct Answer");
        score++;
      } else {
        log("Incorrect Answer");
      }
    });
  }

  IconData _getIconData(bool isSelected, bool isCorrectOption) {
    if (isAnswered) {
      if (isSelected) {
        return isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined;
      } else {
        return isCorrectOption
            ? Icons.check_circle_outline
            : CupertinoIcons.add_circled;
      }
    }
    return CupertinoIcons.add_circled;
  }

  Color _getIconDataColor(bool isSelected, bool isCorrectOption) {
    if (isAnswered) {
      if (isSelected) {
        return isCorrect ? Colors.green : Colors.red;
      } else {
        return isCorrectOption
            ? Colors.green
            : Theme.of(context).colorScheme.inverseSurface;
      }
    }
    return Theme.of(context).colorScheme.inverseSurface;
  }
}
