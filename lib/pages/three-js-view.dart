import 'package:flutter/material.dart';
import 'package:flutterapp/models/task.dart';
import 'package:flutterapp/pages/home.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'package:flutter/services.dart';
import 'package:three_js_helpers/three_js_helpers.dart' as three_helpers;

class ResultViewer3D extends StatefulWidget {
  const ResultViewer3D({super.key, required this.task});

  final TaskItem task;

  @override
  _ResultViewer3DState createState() => _ResultViewer3DState();
}

class _ResultViewer3DState extends State<ResultViewer3D>
    with SingleTickerProviderStateMixin {
  late three.ThreeJS threeJs;

  late three.OrbitControls orbit;
  bool ready = false;

  late Animation<double> animation;
  late AnimationController controller;
  late three.Group obj;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    threeJs = three.ThreeJS(
      onSetupComplete: () async {
        ready = true;
        setState(() {});

        await Future.delayed(Duration(seconds: 1));
        //

        animation = Tween<double>(begin: 0, end: 20).animate(controller)
          ..addListener(() {
            // obj.scale = three.Vector3(
            //   animation.value / 10,
            //   animation.value / 10,
            //   animation.value / 10,
            // );
            // threeJs.render();
          });

        if (controller.isAnimating) {
          controller.forward();
        }
      },
      setup: setup,
    );
  }

  @override
  void dispose() {
    orbit.dispose();
    obj.dispose();
    controller.dispose();
    threeJs.dispose();
    three.loading.clear();
    // joystick?.dispose();
    super.dispose();
  }

  readyHandle() {
    print("Ready");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // backgroundColor: Colors.black,
        title: Text("Result viewer"),
        leading: IconButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                ModalRoute.withName('/'),
              );
            },
            icon: Icon(Icons.chevron_left)),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  obj.position.setZ(8.0);
                  // obj.scale.setValues(1, 1);
                  threeJs.render();
                });
              },
              child: Text("Refresh"))
        ],
      ),
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: Duration(seconds: 2),
            opacity: ready ? 1.0 : 0,
            child: threeJs.build(),
          ),
          
        ready? SizedBox():  Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }

  Map<LogicalKeyboardKey, bool> keyStates = {
    LogicalKeyboardKey.space: false,
    LogicalKeyboardKey.arrowUp: false,
    LogicalKeyboardKey.arrowLeft: false,
    LogicalKeyboardKey.arrowDown: false,
    LogicalKeyboardKey.arrowRight: false,
  };

  double gravity = 30;
  int stepsPerFrame = 5;
  // three.Joystick? joystick;

  Future<void> setup() async {
    await Future.delayed(Duration(milliseconds: 400));

    // joystick = threeJs.width < 850
    //     ? three.Joystick(
    //         size: 150,
    //         margin: const EdgeInsets.only(left: 35, bottom: 35),
    //         screenSize: Size(threeJs.width, threeJs.height),
    //         listenableKey: threeJs.globalKey)
    //     : null;
    threeJs.camera =
        three.PerspectiveCamera(45, threeJs.width / threeJs.height, 1, 2200);
    threeJs.camera.position.setValues(0, 0, 10);

    threeJs.scene = three.Scene();

    final ambientLight = three.AmbientLight(0xffffff, 1);
    threeJs.scene.add(ambientLight);

    final pointLight = three.PointLight(0xffffff, 0.1);

    pointLight.position.setValues(0, 0, 0);

    threeJs.camera.add(pointLight);
    threeJs.scene.add(threeJs.camera);
    threeJs.scene.add(three_helpers.AxesHelper());

    // three.GLTFLoader loader = three.GLTFLoader(flipY: true).setPath('assets/');
    // three.Loader loader = three.OBJLoader().setPath('assets/');
    three.Loader loader = three.OBJLoader();
    // three.Loader loader = three.FBXLoader().setPath('assets/');

    // obj = await loader.fromAsset('banana-3.obj');
    // obj = await loader.fromAsset('charge.obj');
    print("obj path: ${widget.task.resultUrl}");

    obj = (await loader.fromNetwork(Uri.parse(widget.task.resultUrl)));

    print(obj.children);
    // obj.scale = three.Vector3.zero();
    obj.position.setZ(8.0);
    // obj.position.setZ(5.0);
    threeJs.scene.add(obj);

    // threeJs.camera.lookAt(obj.position);

    orbit = three.OrbitControls(threeJs.camera, threeJs.globalKey);

    orbit.update();
    orbit.addEventListener('change', (event) {
      threeJs.render();
    });

    // threeJs.addAnimationEvent((dt) {
    //   joystick?.update();
    // });

    threeJs.renderer?.autoClear =
        false; // To allow render overlay on top of sprited sphere
    // if (joystick != null) {
    //   threeJs.postProcessor = ([double? dt]) {
    //     threeJs.renderer!.setViewport(0, 0, threeJs.width, threeJs.height);
    //     threeJs.renderer!.clear();
    //     threeJs.renderer!.render(threeJs.scene, threeJs.camera);
    //     threeJs.renderer!.clearDepth();
    //     threeJs.renderer!.render(joystick!.scene, joystick!.camera);
    //   };
    // }
  }
}

enum PlayerAction { blink, idle, walk, run }
