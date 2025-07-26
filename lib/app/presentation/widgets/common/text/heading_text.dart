import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;
  final double height;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const HeadingText({
    super.key,
    required this.text,
    this.fontSize = 36,
    this.fontWeight = FontWeight.w700,
    this.color = Colors.white,
    this.letterSpacing = 0.2,
    this.height = 1.0,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Clash Display Variable',
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
