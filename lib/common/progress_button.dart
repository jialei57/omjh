import 'package:flutter/material.dart';
import 'package:omjh/common/theme_style.dart';

class ProgressBarButton extends StatefulWidget {
  final double width;
  final double height;
  final String text;
  final Function onCompleted;

  const ProgressBarButton(
      {super.key,
      required this.width,
      required this.height,
      required this.text,
      required this.onCompleted});

  @override
  State<ProgressBarButton> createState() => _ProgressBarButtonState();
}

class _ProgressBarButtonState extends State<ProgressBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.05;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.05,
      upperBound: 1.0,
    )..addListener(() {
        setState(() {
          _progress = _controller.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressStart() {
    _controller.forward();
  }

  void _handlePressEnd() {
    if (_controller.value >= 1.0) {
      widget.onCompleted();
    } else {
      // If released before 100%, reset the progress to 0
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
          color: ThemeStyle.unselectedColor,
          border: Border.all(color: ThemeStyle.bgColor, width: 2)),
      child: GestureDetector(
        onTapDown: (_) => _handlePressStart(),
        onTapUp: (_) => _handlePressEnd(),
        onTapCancel: () => _handlePressEnd(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            LinearProgressIndicator(
                value: _progress / 1.0,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                backgroundColor: Colors.grey,
                minHeight: widget.height),
            Text(widget.text,
                style: ThemeStyle.textStyle
                    .copyWith(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
