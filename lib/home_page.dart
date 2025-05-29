import 'package:flutter/material.dart';
import 'package:quiz_app/quiz_page.dart';

/// Displays the home page of the quiz application.
///
/// Includes a cover image, a welcome message/description,
/// and a button to start the quiz.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery to get screen dimensions for responsive design.
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      // Body is wrapped in a Container to apply a background gradient.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.shade200, // Starting color of the gradient
              Colors.deepOrange.shade400, // Ending color of the gradient
            ],
            begin: Alignment.topLeft, // Gradient starts at the top-left corner
            end: Alignment.bottomRight, // Gradient ends at the bottom-right corner
          ),
        ),
        child: Center(
          child: Card(
            color: Colors.deepOrange.shade100.withOpacity(0.95), // Card background color with slight opacity
            elevation: 10, // Shadow effect for the card
            child: Column(
              mainAxisSize: MainAxisSize.min, // Column takes minimum vertical space
              children: [
                // Padding around the cover image
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: height * 0.5, // Image max height is 50% of screen height
                      maxWidth: width * 0.85,   // Image max width is 85% of screen width
                    ),
                    child: const Image.asset(
                      'images/cover.jpg', // Path to the cover image
                      fit: BoxFit.contain, // Image scaling strategy
                    ),
                  ),
                ),
                // Padding for the descriptive text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Text(
                    "Welcome to the Quiz App! Test your knowledge on various interesting topics.",
                    textAlign: TextAlign.center, // Center-align the text
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87, // Text color
                      fontWeight: FontWeight.w500, // Text boldness
                    ),
                  ),
                ),
                // Padding for the start button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                      onPressed: (){
                        // Navigate to the QuizzPage when the button is pressed.
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext ctx){
                            return const QuizzPage(); // QuizzPage is const
                          }
                      ));
                    },
                    child: const Text("Commencer le quiz") // Text for the button
                ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}