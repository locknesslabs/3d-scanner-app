import 'package:flutter/material.dart';
import 'package:flutterapp/pages/camera.dart';
import 'package:flutterapp/pages/dashboard.dart';
import 'package:flutterapp/pages/do-task.dart';
import 'package:flutterapp/pages/setting.dart';
import 'package:flutterapp/pages/tasks.dart';
import 'package:flutterapp/pages/video.dart';
import 'package:flutterapp/pages/three-js-view.dart';
import 'package:flutterapp/providers/web3_auth.provider.dart';
import 'package:flutterapp/widgets/AppFooter.dart';
import 'package:flutterapp/widgets/KeepAlivePage.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _myPage = PageController(initialPage: 0, keepPage: true);

  PageStorageKey dashboardKey = new PageStorageKey("dashboard");
  PageStorageKey videoKey = new PageStorageKey("video");
  PageStorageKey profileKey = new PageStorageKey("profile");

  int page = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _myPage.addListener(() {
      setState(() {
        page = _myPage.page!.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final web3AuthProvider =
        Provider.of<Web3AuthProvider>(context, listen: true);

    return Scaffold(
        body: PageView(
          controller: _myPage,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            KeepAlivePage(
              key: dashboardKey,
              child: const DashboardScreen(),
            ),
            KeepAlivePage(
              key: videoKey,
              child: TasksScreen(),
            ),
            KeepAlivePage(
              key: profileKey,
              child: SettingScreen(),
            ),
            // KeepAlivePage(
            //   child: const Text('Empty Body 3'),
            // )
          ], // Comment this if you need to use Swipe.
        ),
        bottomNavigationBar: AppFooterWidget(
          controller: _myPage,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        extendBody: true,
        floatingActionButton: page == 1
            ? Container(
                height: 68.0,
                width: 68.0,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {
                      // CameraScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoTask3DScreen(),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.add),
                  ),
                ),
              )
            : null);
  }
}
