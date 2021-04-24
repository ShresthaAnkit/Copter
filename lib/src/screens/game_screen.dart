import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/my_copter.dart';
import '../components/fireball.dart';
import '../components/background/change_background.dart';
import '../size_config.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static double _heliYaxis = SizeConfig.screenHeight / 2.2;
  double _time = 0;
  double _height = 0;
  double _initialHeight;
  bool _gameHasStarted = false;
  bool _throttlePressed = false;

  static const _GRAVITY = 9.8;
  static const _VELOCITY = 20;
  static const _TIMER_INCREASE = 0.25;

  static int _fireBallSpeedFactor = 80;
  static int _scoreSpeedFactor = 90;

  static var _fireballXaxis = [
    SizeConfig.screenWidth * 1.2,
    SizeConfig.screenWidth * 1.2
  ];
  double _fireballSpeed = SizeConfig.screenWidth / _fireBallSpeedFactor;
  static var _fireballYaxis = [
    Random().nextDouble() * (SizeConfig.screenHeight * 0.8),
    Random().nextDouble() * (SizeConfig.screenHeight * 0.8)
  ];

  static double _scoreXaxis = SizeConfig.screenWidth * 1.8;
  double _scoreSpeed = SizeConfig.screenWidth / _scoreSpeedFactor;
  static double _scoreYaxis =
      Random().nextDouble() * (SizeConfig.screenHeight * 0.8);

  double _heliTopPos;
  double _heliBottomPos;
  double _heliFrontPos;
  double _heliBackPos;

  var _fireballTopPos = [_fireballYaxis[0] + 25, _fireballYaxis[1] + 25];
  var _fireballBottomPos = [_fireballYaxis[0] + 50, _fireballYaxis[1] + 50];
  var _fireballFrontPos = [_fireballXaxis[0] + 15, _fireballXaxis[1] + 15];
  var _fireballBackPos = [_fireballXaxis[0] + 70, _fireballXaxis[1] + 70];

  double _scoreTopPos = _scoreYaxis;
  double _scoreBottomPos = _scoreYaxis + 20;
  double _scoreFrontPos = _scoreXaxis;
  double _scoreBackPos = _scoreXaxis + 20;

  double _score = 0;
  double _gameTime = 0;

  bool _imageState = true;
  bool _visible = true;

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
    Timer.periodic(Duration(milliseconds: 30), (timer) {
      jumpUp();
      if (!_throttlePressed) {
        timer.cancel();
      }
    });
  }

  void startGame() {
    _gameHasStarted = true;
    _score = 0;
    Timer.periodic(Duration(milliseconds: 30), (timer) {
      _gameTime += 0.03;
      _time += _TIMER_INCREASE;
      _score += 0.03;
      _height = (-(_GRAVITY / 2) * _time * _time + _VELOCITY * _time);
      setState(() {
        _heliYaxis = _initialHeight - _height;
      });

      setState(() {
        changeFireballPos(0);
        changeFireballPos(1);

        changeScorePos();

        if (double.parse(_score.toStringAsFixed(2)) % 10 == 0 && _score != 0) {
          _fireBallSpeedFactor -= 2;
          _scoreSpeedFactor -= 2;
          _fireballSpeed = SizeConfig.screenWidth / _fireBallSpeedFactor;
          _imageState = !_imageState;
        }
      });
      // Calculate Helicopter Position
      reformHeliPos();

      if (checkScoreCollision()) {
        _score++;
        _visible = false;
      }

      if (checkObstacleCollision(0) || checkObstacleCollision(1)) {
        timer.cancel();
        _gameHasStarted = false;
      }

      if (_heliYaxis < 0 || _heliYaxis > (SizeConfig.screenHeight - 60)) {
        timer.cancel();
        _gameHasStarted = false;
      }
      if (!_gameHasStarted) {
        endGame();
      }
    });
  }

  void changeScorePos() {
    if (_scoreXaxis < -50) {
      // Check When score out of screen
      _visible = true;
      _scoreYaxis = Random().nextDouble() * (SizeConfig.screenHeight * 0.8);
      _scoreXaxis +=
          SizeConfig.screenWidth * 1.6; // place the score farther back
    } else {
      _scoreXaxis -= _scoreSpeed;
    }
  }

  void changeFireballPos(int num) {
    if (_fireballXaxis[num] < -50) {
      // Check When fireball out of screen
      _fireballYaxis[num] =
          Random().nextDouble() * (SizeConfig.screenHeight * 0.8);
      _fireballXaxis[num] += SizeConfig.screenWidth;
    } else {
      _fireballXaxis[num] -= _fireballSpeed;
    }
  }

  bool checkScoreCollision() {
    reformScorePos();
    if (_heliTopPos < _scoreBottomPos &&
        _heliBottomPos > _scoreTopPos &&
        _heliFrontPos > _scoreFrontPos &&
        _heliBackPos < _scoreBackPos) return true;

    return false;
  }

  bool checkObstacleCollision(int num) {
    reformFireballPos(num);
    if (_heliTopPos < _fireballBottomPos[num] &&
        _heliBottomPos > _fireballTopPos[num] &&
        _heliFrontPos > _fireballFrontPos[num] &&
        _heliBackPos < _fireballBackPos[num]) return true;

    return false;
  }

  void reformHeliPos() {
    _heliTopPos = _heliYaxis;
    _heliBottomPos = _heliYaxis + 35;
    _heliFrontPos = SizeConfig.screenWidth / 1.8;
    _heliBackPos = SizeConfig.screenWidth / 2.2;
  }

  void reformFireballPos(int num) {
    _fireballTopPos[num] = _fireballYaxis[num] + 25;
    _fireballBottomPos[num] = _fireballYaxis[num] + 50;
    _fireballFrontPos[num] = _fireballXaxis[num] + 15;
    _fireballBackPos[num] = _fireballXaxis[num] + 70;
  }

  void reformScorePos() {
    _scoreTopPos = _scoreYaxis;
    _scoreBottomPos = _scoreYaxis + 30;
    _scoreFrontPos = _scoreXaxis;
    _scoreBackPos = _scoreXaxis + 30;
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
                    ChangeBackground(imageState: _imageState),
                    AnimatedPositioned(
                      top: _heliYaxis,
                      left: (SizeConfig.screenWidth) / 2.2,
                      duration: Duration(milliseconds: 0),
                      child: MyCopter(),
                    ),
                    Fireball(
                      fireballYaxis: _fireballYaxis[0],
                      fireballXaxis: _fireballXaxis[0],
                    ),
                    Fireball(
                      fireballYaxis: _fireballYaxis[1],
                      fireballXaxis: _fireballXaxis[1],
                    ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 0),
                      top: _scoreYaxis,
                      left: _scoreXaxis,
                      child: Opacity(
                          opacity: (_visible) ? 1 : 0,
                          child:
                              Image.asset("assets/images/star.png", scale: 7)),
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
    _fireBallSpeedFactor = 80;
    _fireballSpeed = SizeConfig.screenWidth / _fireBallSpeedFactor;
    _scoreSpeedFactor = 90;
    _scoreSpeed = SizeConfig.screenWidth / _scoreSpeedFactor;

    _fireballXaxis[0] = SizeConfig.screenWidth + 100;
    _fireballXaxis[1] = SizeConfig.screenWidth + 300;
    _scoreXaxis = SizeConfig.screenWidth * 1.8;
    _heliYaxis = SizeConfig.screenHeight / 2.2;

    _time = 0;
    _height = 0;
    _initialHeight = _heliYaxis;
    _gameHasStarted = false;
    _throttlePressed = false;

    _gameTime = 0;
  }
}
