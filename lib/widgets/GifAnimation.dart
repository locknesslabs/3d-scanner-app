import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/task.dart';

class GifAnimation extends StatefulWidget {
  const GifAnimation({super.key, required this.frames});

  final List<VideoFrame> frames;

  @override
  _GifAnimationState createState() => _GifAnimationState();
}

class _GifAnimationState extends State<GifAnimation> {
  int currentFrame = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

   
    int fps = 10;
    int frameDuration =
        (1000 / fps).round(); 
    timer = Timer.periodic(Duration(milliseconds: frameDuration), (timer) {
      setState(() {
        currentFrame = (currentFrame + 1) % widget.frames.length;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Dừng timer khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image(image: widget.frames[currentFrame].img),
    );
  }
}
