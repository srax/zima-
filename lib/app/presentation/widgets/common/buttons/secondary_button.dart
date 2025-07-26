import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets? padding;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        padding: padding,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: isLoading
                ? CupertinoActivityIndicator(color: textColor ?? Colors.white)
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
