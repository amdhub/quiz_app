class Question{
  String questionText;
  bool questionAnswer;
  String explication;
  String imagePath;

Question({
  required this.questionText,
  required this.questionAnswer,
  required this.explication,
  required this.imagePath
});

String getImage() => 'images/$imagePath';
}