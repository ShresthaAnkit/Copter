import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/my_copter.dart';
import '../components/cloud.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static double _heliYaxis = 0;
  double _time = 0;
  double _height = 0;
  double _initialHeight = _heliYaxis;
  bool _gameHasStarted = false;
  bool _throttlePressed = false;
  static const _GRAVITY = 9.8;
  static const _VELOCITY = 1.5;

  double _cloudXaxis = -1.9;
  double _cloudSpeed = 0.02;
  double _cloudYaxis = 0;

  double _scoreXaxis = -1.9;
  double _scoreSpeed = 0.02;
  double _scoreYaxis = 0;

  double _score = 0;
  double _gameTime = 0;
  double _difficultyCalculator = 0;

  bool _imageState = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void jumpUp() {
    setState(() {
      _time = 0;
      _initialHeight = _heliYaxis;
    });
  }

  void cancelThrottle() {
    _throttlePressed = false;
  }

  void throttleUp() {
    _throttlePressed = true;
    Timer.periodic(Duration(milliseconds: 60), (timer) {
      jumpUp();
      if (!_throttlePressed) {
        timer.cancel();
      }
    });
  }

  void startGame() {
    _gameHasStarted = true;
    _difficultyCalculator = 0;
    _score = 0;
    Timer.periodic(Duration(milliseconds: 30), (timer) {
      _difficultyCalculator += 0.025;
      _gameTime += 0.025;
      _time += 0.02;
      _score += 0.025;
      _height = (-(_GRAVITY / 2) * _time * _time + _VELOCITY * _time);
      setState(() {
        _heliYaxis = _initialHeight - _height;
      });

      setState(() {
        if (_cloudXaxis < -1.8) {
          Random random = Random();
          Random randomAxis = Random();
          if (randomAxis.nextBool()) {
            _cloudYaxis = random.nextDouble();
          } else {
            _cloudYaxis = -random.nextDouble();
          }
          _cloudXaxis += 3;
        } else {
          _cloudXaxis -= _cloudSpeed;
        }
        if (_scoreXaxis < -1.8) {
          Random random = Random();
          Random randomAxis = Random();
          if (randomAxis.nextBool()) {
            _scoreYaxis = random.nextDouble();
          } else {
            _scoreYaxis = -random.nextDouble();
          }
          _scoreXaxis += 3;
        } else {
          _scoreXaxis -= _scoreSpeed;
        }
        if (double.parse(_score.toStringAsFixed(2)) % 5 == 0 && _score != 0) {
          _cloudSpeed += 0.01;
          _scoreSpeed += 0.005;
          _imageState = !_imageState;
        }
      });

      if (_scoreYaxis.toStringAsFixed(1) == _heliYaxis.toStringAsFixed(1) &&
          _scoreXaxis.round() == 0) {
        _score++;
        _scoreXaxis += 2;
      }

      if (_cloudYaxis.toStringAsFixed(1) == _heliYaxis.toStringAsFixed(1) &&
          _cloudXaxis.round() == 0) {
        timer.cancel();
        _gameHasStarted = false;
      }

      if (_heliYaxis > 1 || _heliYaxis < -1) {
        timer.cancel();
        _gameHasStarted = false;
      }
      if (!_gameHasStarted) {
        endGame();
      }
    });
  }

  Widget build(context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                child: Stack(
                  children: [
                    AnimatedCrossFade(
                      crossFadeState: _imageState
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 800),
                      sizeCurve: Curves.ease,
                      firstChild: Image.asset(
                        'assets/images/background1.png',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                      secondChild: Image.asset(
                        'assets/images/background2.jpg',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    AnimatedContainer(
                      alignment: Alignment(0, _heliYaxis),
                      duration: Duration(milliseconds: 0),
                      child: MyCopter(),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 0),
                      alignment: Alignment(_cloudXaxis, _cloudYaxis),
                      child:
                          Image.asset("assets/images/fireball.png", scale: 4),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 0),
                      alignment: Alignment(_scoreXaxis, _scoreYaxis),
                      child: Image.asset("assets/images/star.png", scale: 7),
                    ),
                    Container(
                      alignment: Alignment(-0.9, -0.9),
                      child: Text('SCORE: ${_score.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Container(
                      alignment: Alignment(0, -0.5),
                      child: Text(_gameHasStarted ? '' : 'TAP TO PLAY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
                onTap: (_gameHasStarted) ? jumpUp : startGame,
                onTapDown: (_) {
                  throttleUp();
                },
                onTapUp: (_) {
                  cancelThrottle();
                },
                onHorizontalDragEnd: (_) {
                  cancelThrottle();
                },
                onVerticalDragEnd: (_) {
                  cancelThrottle();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void endGame() {
    _heliYaxis = 0;
    _time = 0;
    _height = 0;
    _initialHeight = _heliYaxis;
    _gameHasStarted = false;
    _throttlePressed = false;
    _cloudXaxis = -1.9;
    _cloudYaxis = 0;
    _cloudSpeed = 0.02;
    _scoreXaxis = -1.9;
    _scoreYaxis = 0;
    _scoreSpeed = 0.02;
    _gameTime = 0;
  }

  // Widget buildCloud() {
  //   return Wrap(
  //     children: [
  //       Column(
  //         children: [
  //           Cloud(),
  //           Cloud(),
  //         ],
  //       ),
  //       Column(
  //         children: [
  //           Cloud(),
  //           Cloud(),
  //           Cloud(),
  //         ],
  //       ),
  //       Column(
  //         children: [
  //           Cloud(),
  //           Cloud(),
  //           Cloud(),
  //           Cloud(),
  //         ],
  //       ),
  //       Column(
  //         children: [
  //           Cloud(),
  //           Cloud(),
  //           Cloud(),
  //         ],
  //       ),
  //       Column(
  //         children: [
  //           Cloud(),
  //           Cloud(),
  //         ],
  //       ),
  //     ],
  //   );
  // }
}
