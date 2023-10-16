import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake/control_panel.dart';
import 'package:snake/direction.dart';
import 'package:snake/piece.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int? upperBoundX, upperBoundY, lowerBoundX, lowerBoundY;
  double? screenWidth, screenHeight;
  int step = 30;
  int length = 5;
  List<Offset> positiones = [];
  Direction direction = Direction.right;
  Timer? timer;
  Offset? foodPosition;
  late Piece food;
  int score = 5;
  double speed = 1.0;

  void changeSpeed() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: 200 ~/ speed), (timer) {
      setState(() {});
    });
  }

  Widget getControls() {
    return ControlPanel(onTapped: (Direction newDirection) {
      direction = newDirection;
    });
  }

  Direction getRandomDirection() {
    int val = Random().nextInt(4);
    direction = Direction.values[val];
    return direction;
  }

  void restart() {
    length = 5;
    score = 0;
    speed = 1;
    positiones = [];
    direction = getRandomDirection();
    changeSpeed();
  }

  @override
  void initState() {
    super.initState();
    restart();
  }

  int getNearestTens(int number) {
    int output;
    output = (number ~/ step) * step;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  Offset getRandomPosition() {
    Offset position;
    int posX = Random().nextInt(upperBoundX!) + lowerBoundX!;
    int posY = Random().nextInt(upperBoundY!) + lowerBoundY!;
    position = Offset(
        getNearestTens(posX).toDouble(), getNearestTens(posY).toDouble());
    return position;
  }

  void draw() async {
    // ignore: prefer_is_empty
    if (positiones.length == 0) {
      positiones.add(getRandomPosition());
    }
    while (length > positiones.length) {
      positiones.add(positiones[positiones.length - 1]);
    }
    for (var i = positiones.length - 1; i > 0; i--) {
      positiones[i] = positiones[i - 1];
    }
    positiones[0] = await getNextPosition(positiones[0]);
  }

  bool detectCollision(Offset position) {
    if (position.dx >= upperBoundX! && direction == Direction.right) {
      return true;
    } else if (position.dx <= upperBoundX! && direction == Direction.left) {
      return true;
    } else if (position.dy >= upperBoundY! && direction == Direction.down) {
      return true;
    } else if (position.dy <= upperBoundY! && direction == Direction.up) {
      return true;
    }
    return false;
  }

  void showGameOverDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.red,
            shape: const RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.blue,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: const Text(
              "Game over",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: Text(
              "Your game is over, you played well, your score is ${score.toString()}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    restart();
                  },
                  child: const Text(
                    "Restart",
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w400),
                  ))
            ],
          );
        });
  }

  Future<Offset> getNextPosition(Offset position) async {
    Offset next = position;
    if (direction == Direction.right) {
      next = Offset(position.dx + step, position.dy);
    } else if (direction == Direction.left) {
      next = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      next = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      next = Offset(position.dx, position.dy + step);
    }
    if (detectCollision(position)) {
      if (timer != null && timer!.isActive) {
        timer!.cancel();
      }
      await Future.delayed(
          const Duration(milliseconds: 200), () => showGameOverDialog());
      return position;
    }
    return next;
  }

  void drawFood() {
    if (foodPosition == null) {
      foodPosition = getRandomPosition();
    }

    if (foodPosition == positiones[0]) {
      length++;
      score = score + 5;
      speed = speed + 0.25;
      foodPosition = getRandomPosition();
    }

    food = Piece(
      posX: foodPosition!.dx.toInt(),
      posY: foodPosition!.dy.toInt(),
      size: step,
      color: Colors.red,
    );
  }

  List<Piece> getPieces() {
    final pieces = <Piece>[];
    draw();
    drawFood();
    for (var i = 0; i < length; i++) {
      if (i >= positiones.length) {
        continue;
      }
      pieces.add(Piece(
        posX: positiones[i].dx.toInt(),
        posY: positiones[i].dy.toInt(),
        size: step,
        color: i.isEven ? Colors.red : Colors.green,
        isAnimated: true,
      ));
    }
    return pieces;
  }

  Widget getScore() {
    return Positioned(
        top: 80.0,
        right: 50.0,
        child: Text(
          "Score : ${score.toString()}",
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    lowerBoundY = step;
    lowerBoundX = step;
    upperBoundY = getNearestTens(screenHeight!.toInt() - step);
    upperBoundX = getNearestTens(screenWidth!.toInt() - step);
    return Scaffold(
      body: Container(
        color: Colors.amber,
        child: Stack(
          children: [
            Stack(
              children: getPieces(),
            ),
            getControls(),
            food,
            getScore(),
          ],
        ),
      ),
    );
  }
}
