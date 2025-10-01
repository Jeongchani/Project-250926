
import 'package:flutter/material.dart';

class HeartButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  const HeartButton({super.key, required this.color, required this.onTap});

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _pulse() async { await _c.forward(); await _c.reverse(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { _pulse(); widget.onTap(); },
      child: ScaleTransition(
        scale: _scale,
        child: Icon(Icons.favorite, size: 140, color: widget.color),
      ),
    );
  }
}
