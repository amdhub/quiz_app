import 'package:flutter/material.dart';

class TextWithStyle extends Text {
  TextWithStyle({required String data,
    Color color = Colors.black,
    double size = 18,
    weight = FontWeight.normal,
    style = FontStyle.normal,
  }):super(
    data,
    style: TextStyle(
      color: color,
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
    ),
);
}