import 'package:flutter/material.dart';
import 'package:quiz_app/quiz_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Card(
          child: Column(
            children: [
              Image.asset('images/cover.jpg'),
              ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext ctx){
                          return QuizzPage();
                        }
                    ));
                  },
                  child: const Text("Commencer le quiz")
              )
            ],
          )
        ),
      ),
    );
  }
}