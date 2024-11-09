import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterapp/models/task.dart';
import 'package:flutterapp/pages/task-detail.dart';
import 'package:flutterapp/pages/three-js-view.dart';
import 'package:flutterapp/providers/web3_auth.provider.dart';
import 'package:flutterapp/utils/dart_defines.dart';
import 'package:flutterapp/widgets/AppCard.dart';
import 'package:flutterapp/widgets/KeyboardHider.dart';
import 'package:flutterapp/widgets/VideoBackground.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _stretch = true;
  DataPaginate paginate = DataPaginate.empty();
  bool _loading = false;
  bool _canLoadMore = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  static const double _endReachedThreshold =
      200; 
  @override
  void initState() {
    super.initState();
    //   final web3AuthProvider =
    //     Provider.of<Web3AuthProvider>(context, listen: false);

    fetchTasks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardHider(
      child: NestedScrollView(
        physics: BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: false,
            stretch: _stretch,
            onStretchTrigger: () async {
              // Triggers when stretching
            },
            // [stretchTriggerOffset] describes the amount of overscroll that must occur
            // to trigger [onStretchTrigger]
            //
            // Setting [stretchTriggerOffset] to a value of 300.0 will trigger
            // [onStretchTrigger] when the user has overscrolled by 300.0 pixels.
            stretchTriggerOffset: 200,
            expandedHeight: 250.0,
            collapsedHeight: 32 + MediaQuery.of(context).padding.top,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(
                    viewHintText: "Search",
                    headerHintStyle:
                        TextStyle(color: Colors.white.withOpacity(.6)),
                    isFullScreen: false,
                    builder:
                        (BuildContext context, SearchController controller) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: 5.0,
                            sigmaY: 5.0,
                          ),
                          child: SearchBar(
                            elevation: WidgetStateProperty.all(0),
                            backgroundColor: WidgetStateProperty.all(
                                Color(0xff000000).withOpacity(.3)),
                            controller: controller,
                            padding: const WidgetStatePropertyAll<EdgeInsets>(
                              EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            onTap: () {
                              controller.openView();
                            },
                            onChanged: (_) {
                              controller.openView();
                            },
                            leading: const Icon(Icons.search),
                            hintText: "Search",
                            hintStyle: WidgetStateProperty.all(
                                TextStyle(color: Colors.white.withOpacity(.6))),
                          ),
                        ),
                      );
                    },
                    suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      return List<ListTile>.generate(5, (int index) {
                        final String item = 'item $index';
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            setState(() {
                              controller.closeView(item);
                            });
                          },
                        );
                      });
                    }),
              ),
              // background:  Container(
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //         image: AssetImage("assets/images/bg-1.jpg"),
              //         fit: BoxFit.cover),
              //   ),
              // ),
              background: Stack(
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      // child: VideobackgroundWidget(),
                      child: Image.asset("assets/images/bg-3.jpg"),
                    ),
                  ),
                  Center(
                    child: Text(
                      "3D Tasks",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (_loading) return false;

            final thresholdReached = scrollInfo.metrics.extentAfter <
                _endReachedThreshold; 
            if (thresholdReached) {
              // Load more!
              fetchTasks();
            }
            return false;
          },
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              color: Theme.of(context).primaryColor,
              child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16)
                            .copyWith(top: 32, bottom: 6),
                        child: Text(
                          "Recently created models",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(.8)),
                        ),
                      ),
                      Builder(builder: (context) {
                        if (paginate == null)
                          return new Container(
                            child:
                                Center(child: new CircularProgressIndicator()),
                          );
                        else if (paginate.data.length <= 0) {
                          if (_loading) {
                            return GridView.count(
                              semanticChildCount: 10,
                              primary: false,
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              physics: NeverScrollableScrollPhysics(),
                              children: List.generate(10, (int index) => index)
                                  .map((item) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.white.withOpacity(.1),
                                  highlightColor: Colors.white.withOpacity(.3),
                                  child: Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }

                          return Container(
                            padding: EdgeInsets.all(100),
                            alignment: Alignment.center,
                            child: _loading
                                ? Text(
                                    "Loading...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(.8),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        "No data available!",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(.8),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Press ",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  Colors.white.withOpacity(.8),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            child: Icon(
                                              Icons.add,
                                              size: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            " to start.",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  Colors.white.withOpacity(.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          );
                        }

                        return GridView.count(
                          primary: false,
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          physics: NeverScrollableScrollPhysics(),
                          children: paginate.data.map((item) {
                            return AppCardWidget(
                              padding: EdgeInsets.all(0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  // MaterialPageRoute(
                                  //   builder: (context) => TaskDetailScreen(
                                  //     taskId: item.id,
                                  //   ),
                                  MaterialPageRoute(
                                    builder: (context) => ResultViewer3D(
                                      task: item,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.all(6),
                                clipBehavior: Clip.antiAlias,
                                child: Text(
                                  '${DateFormat('hh:mm dd MMM yyyy').format(item.createdAt)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  image: DecorationImage(
                                      image: item.files.first.thumbnail,
                                      fit: BoxFit.cover),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      _canLoadMore
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : SizedBox(),
                    ],
                  )),
            ),
            // ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _canLoadMore = true;
      paginate.clear();
    });

    await fetchTasks();
  }

  Future<void> fetchTasks() async {
    if (paginate.meta.currentPage >= paginate.meta.lastPage) {
      setState(() {
        _canLoadMore = false;
      });

      return;
    }

    if (_loading) return;

    Web3AuthProvider auth = context.read<Web3AuthProvider>();

    setState(() {
      _loading = true;
    });
    print("fetchTasks page:${paginate.meta.nextPage}");
    await Future.delayed(Duration(seconds: 2));

    try {
      http.Response res = await http.get(
          Uri.parse(
              '${DartDefines.apiUrl}/tasks/index?page=${paginate.meta.nextPage}'),
          headers: {
            "Authorization": auth.token.accessToken,
          });
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        var newPaginate = DataPaginate.fromJson(data);

        paginate.data = [
          ...paginate.data,
          ...newPaginate.data,
        ];

        paginate.meta = newPaginate.meta;

        print("paginate.data.length ${paginate.data.length}");

        if (newPaginate.data.length <= 0) {
          _canLoadMore = false;
        }
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        _loading = false;
        setState(() {});
      }
    }
  }
}

class DataPaginate {
  DataPaginateMeta meta;
  List<TaskItem> data;

  DataPaginate({required this.meta, required this.data});

  factory DataPaginate.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = json["data"];

    return DataPaginate(
      meta: DataPaginateMeta.fromJson(json["meta"]),
      data: dataList.map((item) {
        return TaskItem.fromJson(item);
      }).toList(),
    );
  }

  factory DataPaginate.empty() {
    return DataPaginate(data: [], meta: DataPaginateMeta.empty());
  }

  clear() {
    data = [];
    meta.currentPage = 0;
  }
}

class DataPaginateMeta {
  final int total;
  final int perPage;
  int currentPage;
  final int lastPage;
  final int firstPage;

  DataPaginateMeta(
      {required this.total,
      required this.perPage,
      required this.currentPage,
      required this.lastPage,
      required this.firstPage});

  int get nextPage {
    return currentPage + 1;
  }

  factory DataPaginateMeta.fromJson(Map<String, dynamic> json) {
    return DataPaginateMeta(
      total: json['total'],
      perPage: json['perPage'],
      currentPage: json['currentPage'],
      lastPage: json['lastPage'],
      firstPage: json['firstPage'],
    );
  }

  factory DataPaginateMeta.empty() {
    return DataPaginateMeta(
        currentPage: 0, lastPage: 1, firstPage: 1, total: 0, perPage: 10);
  }
}
