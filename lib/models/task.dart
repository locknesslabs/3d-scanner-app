import 'package:flutter/material.dart';
import 'package:flutterapp/utils/dart_defines.dart';

class TaskItem {
  final int id;
  final String title;
  final String description;
  final int type;
  final List<FileItem> files;
  final DateTime createdAt;
  final String resultUrl;

  TaskItem(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.createdAt,
      required this.resultUrl,
      required this.files});

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = [];
    if (json["files"] != null) {
      dataList = json["files"];
    }

    return TaskItem(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['perPage'] ?? '',
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      resultUrl: json['resultUrl'] ?? '',
      files: dataList.map((item) {
        return FileItem.fromJson(item);
      }).toList(),
    );
  }

  factory TaskItem.empty() {
    return TaskItem(
        id: 0,
        title: "",
        description: "",
        type: 1,
        resultUrl: "",
        createdAt: DateTime.now(),
        files: []);
  }

  FileItem get file {
    return files.first;
  }
}

class FileItem {
  final int id;
  final String status;
  final String fileName;
  final String filePath;
  final ImageProvider<Object> thumbnail;
  final int fileType;
  final int fileSize;
  final int width;
  final int height;

  final List<VideoFrame> frames;

  FileItem({
    required this.id,
    required this.status,
    required this.fileName,
    required this.filePath,
    required this.thumbnail,
    required this.fileType,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.frames,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    var thumbnail;
    if (json['thumbnailPath'] != null) {
      thumbnail =
          NetworkImage("${DartDefines.apiUrl}/${json['thumbnailPath']}");
    } else {
      thumbnail = AssetImage("assets/images/cube.jpg");
    }

    List<dynamic> dataList = [];

    if (json["frames"] != null) {
      dataList = json["frames"];
    }

    return FileItem(
      id: json['id'],
      status: json['status'] ?? '',
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      thumbnail: thumbnail,
      fileType: json['fileType'] ?? 0,
      fileSize: json['fileSize'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      frames: dataList.map((item) {
        return VideoFrame.fromJson(item);
      }).toList(),
    );
  }
}

class VideoFrame {
  final int id;
  final int frameNumber;
  final int frameTimeSec;
  final ImageProvider<Object> img;
  final String status;

  VideoFrame(
      {required this.id,
      required this.frameNumber,
      required this.frameTimeSec,
      required this.img,
      required this.status});

  factory VideoFrame.fromJson(Map<String, dynamic> json) {
    var thumbnail;
    if (json['framePath'] != null) {
      thumbnail = NetworkImage(
          "${DartDefines.apiUrl}/${json['framePath'].toString().replaceAll('public/', '/').replaceAll('.png', '__tr.png')}");
    } else {
      thumbnail = AssetImage("assets/images/cube.jpg");
    }
    return VideoFrame(
        id: json['id'],
        frameNumber: json['frameNumber'] ?? 0,
        frameTimeSec: json['frameTimeSec'] ?? 0,
        img: thumbnail,
        status: json['status']);
  }
}
