import 'package:flutter/material.dart';

class AppFooterWidget extends StatefulWidget {
  const AppFooterWidget({super.key, this.controller});
  final PageController? controller;

  @override
  State<AppFooterWidget> createState() => _AppFooterWidgetState();
}

class _AppFooterWidgetState extends State<AppFooterWidget> {
  int page = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.controller!.addListener(() {
      setState(() {
        page = widget.controller!.page!.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Color(0xff20223D),
      child: Container(
        height: 75,
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              iconSize: 30.0,
              icon: Icon(Icons.home),
              color: page == 0
                  ? Theme.of(context).primaryColor
                  : Color.fromRGBO(255, 255, 255, .4),
              onPressed: () {
                setState(() {
                  widget.controller!.jumpToPage(0);
                });
              },
            ),
            page != 1
                ? IconButton(
                    iconSize: 30.0,
                    icon: Icon(Icons.add_box),
                    color: page == 1
                        ? Theme.of(context).primaryColor
                        : Color.fromRGBO(255, 255, 255, .4),
                    onPressed: () {
                      setState(() {
                        widget.controller!.jumpToPage(1);
                      });
                    },
                  )
                : SizedBox(),
            IconButton(
              iconSize: 30.0,
              icon: Icon(Icons.settings),
              color: page == 2
                  ? Theme.of(context).primaryColor
                  : Color.fromRGBO(255, 255, 255, .4),
              onPressed: () {
                setState(() {
                  widget.controller!.jumpToPage(2);
                });
              },
            ),
            // IconButton(
            //   iconSize: 30.0,
            //   icon: Icon(Icons.list),
            //   color: page == 3
            //       ? Theme.of(context).primaryColor
            //       : Color.fromRGBO(255, 255, 255, .4),
            //   onPressed: () {
            //     setState(() {
            //       widget.controller!.jumpToPage(3);
            //     });
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
