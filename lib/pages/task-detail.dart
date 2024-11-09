import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterapp/models/task.dart';
import 'package:flutterapp/providers/web3_auth.provider.dart';
import 'package:flutterapp/utils/dart_defines.dart';
import 'package:flutterapp/widgets/GifAnimation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});
  final int taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _loading = false;
  TaskItem task = TaskItem.empty();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Builder(builder: (context) {
          if (_loading) return Text("Loading...");

          return Column(
            children: [
              Text("Task ${task.id}"),
              // Image(image: task.file.thumbnail),
              SizedBox(
                height: 32,
              ),
              Container(
                width: 100,
                child: GifAnimation(
                  frames: task.file.frames,
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  fetchData() async {
    Web3AuthProvider auth = context.read<Web3AuthProvider>();

    setState(() {
      _loading = true;
    });
    try {
      http.Response res = await http.get(
          Uri.parse('${DartDefines.apiUrl}/tasks/${widget.taskId}'),
          headers: {
            "Authorization": auth.token.accessToken,
          });
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        task = TaskItem.fromJson(data["data"]);
        print("fetchData ${data["data"]}");
        print(task.files);
      }
    } catch (e) {
      print(e);
    } finally {
      _loading = false;
      setState(() {});
    }
  }
}
