import 'package:flutter/material.dart';

class Piece extends StatefulWidget {
  final bool isAnimated;
  final int posX, posY, size;
  final Color color;
  const Piece(
      {Key? key,
      this.isAnimated = false,
      required this.posX,
      required this.posY,
      required this.size,
      required this.color})
      : super(key: key);

  @override
  State<Piece> createState() => _PieceState();
}

class _PieceState extends State<Piece> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        lowerBound: 0.25,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 1000),
        vsync: this);
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController!.reset();
      } else if (status == AnimationStatus.dismissed) {
        _animationController!.forward();
      }
    });
    _animationController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.posY.toDouble(),
      left: widget.posX.toDouble(),
      child: Opacity(
        opacity: widget.isAnimated ? 1 : _animationController!.value,
        child: Container(
          width: widget.size.toDouble(),
          height: widget.size.toDouble(),
          decoration: BoxDecoration(
              color: widget.color,
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(
                width: 2.0,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}
