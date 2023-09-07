import 'package:flutter/material.dart';
import 'package:quiz_app/datas.dart';
import 'package:quiz_app/question.dart';

class QuizzPage extends StatefulWidget {
  @override
  QuizzPageState createState() => QuizzPageState();
}
class QuizzPageState extends State<QuizzPage>{

  List<Question> questions = Datas().listeQuestions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(

      )
    );
  }
}