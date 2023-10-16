import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({Key? key, required this.icon, required this.onPressed})
      : super(key: key);

  final void Function() onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      // ignore: sized_box_for_whitespace
      child: Container(
        width: 80.0,
        height: 80.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            elevation: 0,
            onPressed: onPressed,
            child: icon,
          ),
        ),
      ),
    );
  }
}
