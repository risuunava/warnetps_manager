import 'package:flutter/material.dart';

class RetroCrtMonitor extends StatelessWidget {
  final Color screenColor;
  final bool isPowerOn;
  final double width;
  final double height;

  const RetroCrtMonitor({
    super.key,
    required this.screenColor,
    required this.isPowerOn,
    this.width = 48.0,
    this.height = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: RetroCrtMonitorPainter(
        screenColor: screenColor,
        isPowerOn: isPowerOn,
      ),
    );
  }
}

class RetroCrtMonitorPainter extends CustomPainter {
  final Color screenColor;
  final bool isPowerOn;

  RetroCrtMonitorPainter({required this.screenColor, required this.isPowerOn});

  @override
  void paint(Canvas canvas, Size size) {
    final shellPaint = Paint()..color = const Color(0xFFD4D0C8); // Classic PC beige/gray
    final shadowPaint = Paint()..color = const Color(0xFF808080);
    final highlightPaint = Paint()..color = const Color(0xFFFFFFFF);
    final blackPaint = Paint()..color = const Color(0xFF000000);
    final screenPaint = Paint()..color = const Color(0xFF1A1A1A); // Dark CRT screen
    final activeScreenPaint = Paint()..color = screenColor;

    // 1. Draw Stand (base)
    final standPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.85)
      ..lineTo(size.width * 0.7, size.height * 0.85)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..close();
    canvas.drawPath(standPath, shellPaint);
    canvas.drawPath(standPath, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1);

    // 2. Draw Neck
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.4, size.height * 0.75, size.width * 0.6, size.height * 0.86),
      shellPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.4, size.height * 0.75, size.width * 0.6, size.height * 0.86),
      Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1,
    );

    // 3. Draw Outer Shell (body of monitor)
    final shellRect = Rect.fromLTRB(0, 0, size.width, size.height * 0.78);
    canvas.drawRect(shellRect, shellPaint);
    
    // Outer shell outline
    canvas.drawRect(shellRect, blackPaint..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Shell Bevel Highlight (top & left)
    canvas.drawLine(const Offset(1, 1), Offset(size.width - 1, 1), highlightPaint..strokeWidth = 1);
    canvas.drawLine(const Offset(1, 1), Offset(1, size.height * 0.78 - 1), highlightPaint..strokeWidth = 1);

    // Shell Bevel Shadow (bottom & right)
    canvas.drawLine(Offset(1, size.height * 0.78 - 1), Offset(size.width - 1, size.height * 0.78 - 1), shadowPaint..strokeWidth = 1);
    canvas.drawLine(Offset(size.width - 1, 1), Offset(size.width - 1, size.height * 0.78 - 1), shadowPaint..strokeWidth = 1);

    // 4. Draw Inner Bevel Frame for Screen
    final screenFrameRect = Rect.fromLTRB(
      size.width * 0.08,
      size.height * 0.08,
      size.width * 0.92,
      size.height * 0.65,
    );
    canvas.drawRect(screenFrameRect, Paint()..color = const Color(0xFF808080)); // Sunken border
    
    // Screen glass
    final glassRect = Rect.fromLTRB(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 0.63,
    );
    canvas.drawRect(glassRect, screenPaint);

    // Draw active glow display
    if (isPowerOn) {
      canvas.drawRect(
        Rect.fromLTRB(
          size.width * 0.14,
          size.height * 0.14,
          size.width * 0.86,
          size.height * 0.59,
        ),
        activeScreenPaint,
      );
      
      // Draw screen scanlines
      final scanlinePaint = Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..strokeWidth = 1;
      for (double y = size.height * 0.14; y < size.height * 0.59; y += 3) {
        canvas.drawLine(Offset(size.width * 0.14, y), Offset(size.width * 0.86, y), scanlinePaint);
      }

      // Draw screen reflection highlights (glare)
      final glarePaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      final glarePath = Path()
        ..moveTo(size.width * 0.14, size.height * 0.14)
        ..lineTo(size.width * 0.4, size.height * 0.14)
        ..lineTo(size.width * 0.14, size.height * 0.4)
        ..close();
      canvas.drawPath(glarePath, glarePaint);
    }

    // 5. Draw Power LED
    final ledColor = isPowerOn ? const Color(0xFF00FF00) : const Color(0xFF555555); // Green if on, else dark gray
    final ledPaint = Paint()..color = ledColor;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.72), 1.5, ledPaint);
  }

  @override
  bool shouldRepaint(covariant RetroCrtMonitorPainter oldDelegate) {
    return oldDelegate.screenColor != screenColor || oldDelegate.isPowerOn != isPowerOn;
  }
}
