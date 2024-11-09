import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideobackgroundWidget extends StatefulWidget {
  const VideobackgroundWidget({super.key});

  @override
  State<VideobackgroundWidget> createState() => _VideobackgroundWidgetState();
}

class _VideobackgroundWidgetState extends State<VideobackgroundWidget> {
  late VideoPlayerController _videoController;


  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/images/video-1.mp4');

    _videoController.addListener(() {
      // setState(() {});
    });
    _videoController.setLooping(true);
    _videoController.initialize().then((_) => setState(() {}));
    _videoController.play();
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: _videoController.value.size.width,
      height: _videoController.value.size.height,
      child: VideoPlayer(_videoController),
    );
  }
}