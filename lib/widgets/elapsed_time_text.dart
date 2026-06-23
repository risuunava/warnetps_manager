import 'dart:async';
import 'package:flutter/material.dart';

class ElapsedTimeText extends StatefulWidget {
  final DateTime startTime;
  final TextStyle? style;

  const ElapsedTimeText({
    super.key,
    required this.startTime,
    this.style,
  });

  @override
  State<ElapsedTimeText> createState() => _ElapsedTimeTextState();
}

class _ElapsedTimeTextState extends State<ElapsedTimeText> {
  Timer? _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _calculateElapsed();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ElapsedTimeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateElapsed();
  }

  void _calculateElapsed() {
    _elapsed = DateTime.now().difference(widget.startTime);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateElapsed();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(_elapsed),
      style: widget.style ?? const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
