import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/my_copter.dart';
import '../components/fireball.dart';
import '../components/background/background_image.dart';
import '../size_config.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

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
    SizeConfig.screenWidth * 1.2,
    SizeConfig.screenWidth * 1.2,
    SizeConfig.screenWidth * 1.2,
  ];
  double _fireballSpeed = SizeConfig.screenWidth / _fireBallSpeedFactor;
  static var _fireballYaxis = [
    Random().nextDouble() * (SizeConfig.screenHeight * 0.8),
    Random().nextDouble() * (SizeConfig.screenHeight * 0.8),
    Random().nextDouble() * (SizeConfig.screenHeight * 0.8),
    Random().nextDouble() * (SizeConfig.screenHeight * 0.8),
  ];

  static double _scoreXaxis = SizeConfig.screenWidth * 1.8;
  double _scoreSpeed = SizeConfig.screenWidth / _scoreSpeedFactor;
  static double _scoreYaxis =
      Random().nextDouble() * (SizeConfig.screenHeight * 0.8);

  double _heliTopPos;
  double _heliBottomPos;
  double _heliFrontPos;
  double _heliBackPos;

  var _fireballTopPos = [
    _fireballYaxis[0] + 25,
    _fireballYaxis[1] + 25,
    _fireballYaxis[2] + 25,
    _fireballYaxis[3] + 25,
  ];
  var _fireballBottomPos = [
    _fireballYaxis[0] + 50,
    _fireballYaxis[1] + 50,
    _fireballYaxis[2] + 50,
    _fireballYaxis[3] + 50,
  ];
  var _fireballFrontPos = [
    _fireballXaxis[0] + 15,
    _fireballXaxis[1] + 15,
    _fireballXaxis[2] + 15,
    _fireballXaxis[3] + 15,
  ];
  var _fireballBackPos = [
    _fireballXaxis[0] + 70,
    _fireballXaxis[1] + 70,
    _fireballXaxis[2] + 70,
    _fireballXaxis[3] + 70,
  ];

  double _scoreTopPos = _scoreYaxis;
  double _scoreBottomPos = _scoreYaxis + 20;
  double _scoreFrontPos = _scoreXaxis;
  double _scoreBackPos = _scoreXaxis + 20;

  double _score = 0;
  static int _gameDifficulty = 1;

  int _highScore = 0;

  final List<String> _images = [
    'assets/images/background1.png',
    'assets/images/background2.jpg',
    'assets/images/background3.png',
    'assets/images/background4.jpg',
  ];
  // Counter for which image is being displayed
  int _imageStateCounter = 0;

  // Counter cause I can't use my brain for another solution for changing background
  int _counter = _gameDifficulty;

  bool _visible = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _checkHighScores();
  }

  void switchImage() {
    setState(() {
      _imageStateCounter =
          (_imageStateCounter == _images.length - 1) ? 0 : ++_imageStateCounter;
    });
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
      _time += _TIMER_INCREASE;
      _score += 0.03;
      _height = (-(_GRAVITY / 2) * _time * _time + _VELOCITY * _time);
      setState(() {
        _heliYaxis = _initialHeight - _height;
      });

      setState(() {
        changeFireballPos(0);
        if (_score > 50) {
          changeFireballPos(1);
          _gameDifficulty = 2;
        }

        if (_score > 100) {
          changeFireballPos(2);
          _gameDifficulty = 3;
        }

        if (_score > 200) {
          changeFireballPos(3);
          _gameDifficulty = 4;
        }
        if (_gameDifficulty != _counter) {
          switchImage();
          _counter = _gameDifficulty;
        }

        changeScorePos();

        if (double.parse(_score.toStringAsFixed(2)) % 15 == 0 && _score != 0) {
          _fireBallSpeedFactor -= 2;
          _scoreSpeedFactor -= 2;
          _fireballSpeed = SizeConfig.screenWidth / _fireBallSpeedFactor;
          _scoreSpeed = SizeConfig.screenWidth / _scoreSpeedFactor;
        }
      });
      // Calculate Helicopter Position
      reformHeliPos();

      if (checkScoreCollision()) {
        _score++;
        _visible = false;
        _scoreXaxis -= 40;
      }

      if (checkObstacleCollision(0) ||
          checkObstacleCollision(1) ||
          checkObstacleCollision(2) ||
          checkObstacleCollision(3)) {
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
                    AnimatedSwitcher(
                      child: BackgroundImage(
                          key: ValueKey<int>(_imageStateCounter),
                          url: _images[_imageStateCounter]),
                      duration: Duration(milliseconds: 2000),
                    ),
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
                    Fireball(
                      fireballYaxis: _fireballYaxis[2],
                      fireballXaxis: _fireballXaxis[2],
                    ),
                    Fireball(
                      fireballYaxis: _fireballYaxis[3],
                      fireballXaxis: _fireballXaxis[3],
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
                      child: Text('SCORE: ${_score.toInt()}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 2000),
                      alignment: Alignment(0.9, -0.9),
                      child: Text('HIGH SCORE: $_highScore',
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

  void _checkHighScores() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = _prefs.getInt('highScore') ?? 0;
      if (_highScore < _score) {
        _highScore = _score.toInt();
        _prefs.setInt('highScore', _score.toInt());
      }
    });
  }

  void endGame() {
    _checkHighScores();
    _fireBallSpeedFactor = 80;
    _fireballSpeed = SizeConfig.screenWidth / _fireBallSpeedFactor;
    _scoreSpeedFactor = 90;
    _scoreSpeed = SizeConfig.screenWidth / _scoreSpeedFactor;

    for (int i = 0; i < _fireballXaxis.length; i++) {
      _fireballXaxis[i] = SizeConfig.screenWidth + 200;
    }
    _scoreXaxis = SizeConfig.screenWidth * 1.8;
    _heliYaxis = SizeConfig.screenHeight / 2.2;

    _time = 0;
    _height = 0;
    _initialHeight = _heliYaxis;
    _gameHasStarted = false;
    _throttlePressed = false;

    _gameDifficulty = 0;
    _counter = _gameDifficulty;
    _imageStateCounter = 0;
  }
}
