import 'dart:ui' as ui;
import 'package:flutter/material.dart';

const defaultPadding = EdgeInsets.only(right: 12);

class AppCardWidget extends StatelessWidget {
  AppCardWidget(
      {super.key,
      required this.child,
      this.onTap,
      this.padding = defaultPadding});

  final Widget child;
  final EdgeInsets padding;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffffffff).withOpacity(.1),
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.antiAlias,
              padding: padding,
              child: child,
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                // splashColor: Colors.lightGreenAccent,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
