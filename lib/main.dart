import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  ui.Image _testImage;
  var _y = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final image = await _loadImage(context, AssetImage('images/test.png'));
      setState(() => _testImage = image);
      createTicker((_) => _move()).start();
    });
  }

  void _move() {
    setState(() => _y += 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _testImage == null
          ? SizedBox()
          : Transform.scale(
              scale: 0.5,
              child: Center(
                  child: CustomPaint(painter: TestPainter(_testImage, _y)))),
    );
  }
}

class TestPainter extends CustomPainter {
  final ui.Image testImage;
  final double y;

  TestPainter(this.testImage, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(0, 64, 64, 64);
    final dst = Rect.fromLTWH(0, y, 64, 64);
    canvas.drawImageRect(testImage, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Future<ui.Image> _loadImage(BuildContext context, ImageProvider provider) {
  final completer = Completer<ui.Image>();
  final configuration = createLocalImageConfiguration(context);
  final stream = provider.resolve(configuration);
  final listener = ImageStreamListener(
    (imageInfo, synchronous) {
      completer.complete(imageInfo.image);
    },
    onError: (error, stackTrace) {
      completer.completeError(error);
    },
  );
  stream.addListener(listener);

  return completer.future;
}
