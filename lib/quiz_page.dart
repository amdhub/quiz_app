import 'package:flutter/material.dart';
import 'package:quiz_app/datas.dart';
import 'package:quiz_app/question.dart';
import 'package:quiz_app/text_with_style.dart';

class QuizzPage extends StatefulWidget {
  @override
  QuizzPageState createState() => QuizzPageState();
}
class QuizzPageState extends State<QuizzPage>{

  List<Question> questions = Datas().listeQuestions;
  int index = 0;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    final Question question = questions[index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Score : $score'),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWithStyle(data: "Question numero: ${index + 1} / ${questions.length}", color: Colors.deepOrange, style: FontStyle.italic,),
                TextWithStyle(data:question.questionText, size:21, weight: FontWeight.bold,),
                Image.asset(question.getImage()),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    answerButton(false),
                    answerButton(true),
                  ],
                )
              ],
            ),
          )
        ),
      )
    );
  }

  ElevatedButton answerButton(bool b){
    return ElevatedButton(
      onPressed: (){
        if(b == questions[index].questionAnswer){
          score++;
        }
        setState(() {
          index++;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: b ? Colors.greenAccent : Colors.redAccent,
        minimumSize: const Size(100, 50),
      ),
      child: Text(b ? 'Vrai' : 'Faux')
    );
  }
}