import 'dart:async';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:flutter/material.dart';

class TechText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Color cursorColor;

  const TechText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 50),
    this.cursorColor = AppColors.primary,
  });

  @override
  State<TechText> createState() => _TechTextState();
}

class _TechTextState extends State<TechText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  @override
  void didUpdateWidget(TechText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _currentIndex = 0;
      _displayedText = '';
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.style ?? Theme.of(context).textTheme.bodyLarge,
        children: [
          TextSpan(text: _displayedText),
          if (_currentIndex < widget.text.length || _showCursor)
            TextSpan(
              text: '_',
              style: TextStyle(
                color: widget.cursorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
