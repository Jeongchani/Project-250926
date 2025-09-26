import 'package:flutter/material.dart';

class HeartWidget extends StatefulWidget {
  final VoidCallback onTap;

  const HeartWidget({super.key, required this.onTap});

  @override
  State<HeartWidget> createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: GestureDetector(
        onTap: widget.onTap,
        child: const Icon(
          Icons.favorite,
          color: Colors.red,
          size: 120,
        ),
      ),
    );
  }
}
