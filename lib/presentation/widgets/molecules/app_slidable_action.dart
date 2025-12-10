import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AppSlidableAction extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final int flex;

  const AppSlidableAction({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.foregroundColor,
    this.backgroundColor = Colors.white,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      onPressed: (_) => onPressed(),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: icon,
      flex: flex,
      autoClose: true,
    );
  }
}
