import 'package:flutter/material.dart';

class RetroBevelContainer extends StatelessWidget {
  final Widget child;
  final bool isSunken;
  final double borderWidth;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const RetroBevelContainer({
    super.key,
    required this.child,
    this.isSunken = false,
    this.borderWidth = 1.0,
    this.color,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Win95 highlights and shadows
    const Color highlightColor = Color(0xFFFFFFFF);
    const Color shadowColor = Color(0xFF808080);
    const Color deepShadowColor = Color(0xFF000000);

    final Border border = isSunken
        ? Border(
            top: BorderSide(color: shadowColor, width: borderWidth),
            left: BorderSide(color: shadowColor, width: borderWidth),
            bottom: BorderSide(color: highlightColor, width: borderWidth),
            right: BorderSide(color: highlightColor, width: borderWidth),
          )
        : Border(
            top: BorderSide(color: highlightColor, width: borderWidth),
            left: BorderSide(color: highlightColor, width: borderWidth),
            bottom: BorderSide(color: shadowColor, width: borderWidth),
            right: BorderSide(color: shadowColor, width: borderWidth),
          );

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE0E0E0), // Standard Win95 gray
        border: border,
      ),
      child: child,
    );
  }
}
