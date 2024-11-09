import 'package:flutter/material.dart';
import 'package:flutterapp/models/task.dart';
import 'package:flutterapp/pages/three-js-view.dart';

class LoadingRender3dWidget extends StatefulWidget {
  const LoadingRender3dWidget({super.key, required this.task});

  final TaskItem task;
  
  @override
  State<LoadingRender3dWidget> createState() => _LoadingRender3dWidgetState();
}

class _LoadingRender3dWidgetState extends State<LoadingRender3dWidget>
    with TickerProviderStateMixin {
  List<String> texts = [
    "Uploading image...",
    "Removing background...",
    "Extract feature...",
    "Creating pointcloud...",
    "Rendering model...",
    "Completed"
  ];

  int loadingStatusIndex = 0;

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    // controller.repeat(reverse: true);
    super.initState();
    loadingWatcher();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  loadingWatcher() {
    setState(() {
      loadingStatusIndex = 0;
    });
    controller
        .animateTo(.2, duration: const Duration(seconds: 2))
        .whenComplete(() {
      setState(() {
        loadingStatusIndex = 1;
      });

      controller
          .animateTo(.3, duration: const Duration(seconds: 3))
          .whenComplete(() {
        setState(() {
          loadingStatusIndex = 2;
        });

        controller
            .animateTo(.5, duration: const Duration(seconds: 5))
            .whenComplete(() {
          setState(() {
            loadingStatusIndex = 3;
          });

          controller
              .animateTo(.6, duration: const Duration(seconds: 10))
              .whenComplete(() {
            setState(() {
              loadingStatusIndex = 4;
            });

            controller
                .animateTo(1, duration: const Duration(seconds: 10))
                .whenComplete(() {
              setState(() {
                loadingStatusIndex = 5;
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  ResultViewer3D(
                          task: widget.task,
                        )),
              );
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Linear progress indicator',
              minHeight: 12,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              height: 24.0,
            ),
            Text(
              "${texts[loadingStatusIndex]}",
              style: TextStyle(
                fontSize: 14,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
