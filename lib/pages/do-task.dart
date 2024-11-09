import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/models/task.dart';
import 'package:flutterapp/pages/camera.dart';
import 'package:flutterapp/pages/three-js-view.dart';
import 'package:flutterapp/pages/video.dart';
import 'package:flutterapp/providers/web3_auth.provider.dart';
import 'package:flutterapp/utils/dart_defines.dart';
import 'package:flutterapp/widgets/LoadingRender3D.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

class DoTask3DScreen extends StatefulWidget {
  const DoTask3DScreen({super.key});

  @override
  State<DoTask3DScreen> createState() => _DoTask3DScreenState();
}

class _DoTask3DScreenState extends State<DoTask3DScreen> {
  bool ready = false;
  bool loading = true;
  bool isVideo = false;
  File? file;
  List<File> files = [];
  VideoPlayerController? controller;
  final ImagePicker _picker = ImagePicker();

  bool uploadLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(milliseconds: 100), () async {
      setState(() {
        ready = true;
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final web3AuthProvider =
        Provider.of<Web3AuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Create 3D Model"),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          // TextButton(
          //   onPressed: () {
          //     openLoadingHandle();
          //   },
          //   child: Text(
          //     "Save as Draft",
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 12,
          //     ),
          //   ),
          // )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            Positioned.fill(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      _handlePreview(),
                      SizedBox(
                        height: 12,
                      ),
                      _handlePreviewFileDetail(),
                      SizedBox(
                        height: 12,
                      ),
                      Builder(builder: (_) {
                        if (file != null || files.isNotEmpty)
                          return Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(80, 48),
                                    backgroundColor:
                                        Colors.white.withOpacity(.3),
                                  ),
                                  onPressed: () {
                                    deleteFileHandle();
                                  },
                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 48),
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      if (files.isNotEmpty) {
                                        uploadFilesHandle(web3AuthProvider);
                                      } else if (file != null) {
                                        uploadFileHandle(web3AuthProvider);
                                      }
                                    },
                                    child: uploadLoading
                                        ? const SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: CircularProgressIndicator(),
                                          )
                                        : const Text(
                                            "SUBMIT",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );

                        return SizedBox();
                      }),
                      SizedBox(
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom,
              right: 12,
              child: AnimatedScale(
                scale: ready ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () {
                    pickMediaHandle();
                  },
                  child: Icon(Icons.add_photo_alternate_rounded,
                      color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                    backgroundColor: Colors.blue, // <-- Button color
                    foregroundColor: Colors.red, // <-- Splash color
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              right: 12,
              child: AnimatedScale(
                scale: ready ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () {
                    pickMultiImageHandle();
                  },
                  child: Icon(Icons.add_to_photos, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                    backgroundColor: Colors.blue, // <-- Button color
                    foregroundColor: Colors.red, // <-- Splash color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          elevation: 12,
          onPressed: () {
            _navigateToCamera(context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.camera_alt,
            size: 32,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Color(0xff20223D),
        child: Container(
          height: 75,
        ),
      ),
    );
  }

  deleteFileHandle() async {
    if (file != null) {
      try {
        await file!.delete();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Removed successfully!"),
        ));
      } catch (e) {}
      file = null;
      if (controller != null) {
        controller!.pause();
        controller!.dispose();
      }
      setState(() {});
    }
    if (files.isNotEmpty) {
      files = [];
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Removed successfully!"),
      ));
    }
  }

  uploadFileHandle(Web3AuthProvider web3AuthProvider) async {
    if (file == null) return;

    uploadLoading = true;
    setState(() {});

    Map<String, String> headers = {
      "Authorization": web3AuthProvider.token.accessToken
    };

    var stream = new http.ByteStream(DelegatingStream.typed(file!.openRead()));
    var length = await file!.length();

    var uri = Uri.parse("${DartDefines.apiUrl}/tasks/create");

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: p.basename(file!.path));

    request.files.add(multipartFile);
    request.headers.addAll(headers);

    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    print(response.statusCode);

    var body = jsonDecode(response.body);
    var task = TaskItem.fromJson(body["task"]);

    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: "/3d-loading"),
        builder: (context) => LoadingRender3dWidget(task: task),
      ),
    );
  }

  uploadFilesHandle(Web3AuthProvider web3AuthProvider) async {
    if (files.isEmpty) return;

    uploadLoading = true;
    setState(() {});

    Map<String, String> headers = {
      "Authorization": web3AuthProvider.token.accessToken
    };

    var uri = Uri.parse("${DartDefines.apiUrl}/tasks/create");

    var request = new http.MultipartRequest("POST", uri);

    request.headers.addAll(headers);

    await Future.forEach(
      files,
      (file) async => {
        request.files.add(
          http.MultipartFile(
            'files',
            (http.ByteStream(file.openRead())).cast(),
            await file.length(),
            filename: p.basename(file.path),
          ),
        )
      },
    );

    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    print(response.statusCode);

    var body = jsonDecode(response.body);
    var task = TaskItem.fromJson(body["task"]);

    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: "/3d-loading"),
        builder: (context) => LoadingRender3dWidget(
          task: task,
        ),
      ),
    );
  }

  Widget _handlePreviewFileDetail() {
    return SizedBox();
    if (file == null) {
      return SizedBox();
    }

    return Text(file!.path);
  }

  pickMediaHandle() async {
    files = [];
    loading = true;

    final XFile? _file = await _picker.pickMedia();
    if (_file != null) {
      final ext = p.extension(_file.path);
      print("ext $ext");

      bool _isImage = ['.png', '.jpg'].contains(ext);
      bool _isVideo = ['.mp4', '.mov'].contains(ext);

      if (_isVideo || _isImage) {
        file = File(_file.path);

        isVideo = _isVideo;
        if (isVideo) {
          await initVideo(_file.path);
        }
        setState(() {});
      }
    }
    loading = false;
  }

  pickMultiImageHandle() async {
    loading = true;

    final List<XFile> _files = await _picker.pickMultiImage();
    if (_files.isNotEmpty) {
      files = _files.map((el) {
        return File(el.path);
      }).toList();
      await initMultiImage();
      setState(() {});
    }
    loading = false;
  }

  Widget _handlePreview() {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Builder(builder: (_) {
          if (files.isNotEmpty) {
            return Container(
              // height: 400,
              padding: EdgeInsets.all(12),
              child: GridView.count(
                key: ValueKey<String>("imgs"),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: 2,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: files.map((fileItem) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 12,
                          offset: Offset(0, 0),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      fileItem,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const Center(
                            child: Text('This image type is not supported'));
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }

          if (file != null) {
            if (isVideo) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 12,
                        offset: Offset(0, 0),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatioVideo(controller),
                ),
                key: ValueKey<String>(file!.path),
              );
            }

            return Container(
              key: ValueKey<String>(file!.path),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 400,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 12,
                      offset: Offset(0, 0),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(file!.path),
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return const Center(
                        child: Text('This image type is not supported'));
                  },
                ),
              ),
            );
          }

          return SizedBox(
            key: Key("empty"),
          );
        }));
  }

  Future<void> _navigateToCamera(BuildContext context) async {
    final CameraResult result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    if (!context.mounted) return;

    if (result != null) {
      isVideo = result.isVideo;

      file = File(result.file.path);
      if (isVideo) {
        await initVideo(result.file.path);
      }

      setState(() {});
    }
  }

  initVideo(_path) async {
    controller = VideoPlayerController.file(File(_path));
    await controller!.setVolume(0);
    await controller!.initialize();
    await controller!.setLooping(true);
    await controller!.play();
  }

  initMultiImage() async {}
}
