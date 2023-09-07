import 'package:flutter/material.dart';
import 'package:quiz_app/quiz_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width  = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Card(
          color: Colors.deepOrange.shade100,
          elevation: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: EdgeInsets.all(10.0),
                child: Image.asset('images/cover.jpg', height: height / 2, width: width * 0.8, fit: BoxFit.cover, ),
              ),
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