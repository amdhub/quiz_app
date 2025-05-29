import 'package:flutter/material.dart';

class TextWithStyle extends Text {
  const TextWithStyle({
    super.key, // It's good practice to pass the key
    required String data,
    Color color = Colors.black,
    double size = 18,
    FontWeight weight = FontWeight.normal, // Explicitly type FontWeight
    FontStyle style = FontStyle.normal,   // Explicitly type FontStyle
    TextAlign textAlign = TextAlign.start, // Add textAlign if it's commonly needed
  }) : super(
          data,
          textAlign: textAlign,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            fontStyle: style,
          ),
        );
}