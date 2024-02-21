import 'dart:math';

import 'package:flutter/material.dart';

class DragDeleteItem extends StatefulWidget {
  final Widget child;

  const DragDeleteItem({required this.child, super.key});

  @override
  State<StatefulWidget> createState() {
    return _DragDeleteItem();
  }
}

class _DragDeleteItem extends State<DragDeleteItem> {
  double dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragUpdate: (detail) {
          dragOffset += detail.delta.dx;
          if (dragOffset < -100) {
            setState(() {
              dragOffset = -100;
            });
            return;
          }
          if (dragOffset > 0) {
            setState(() {
              dragOffset = 0;
            });
          }
        },
        child: dragOffset == -100
            ? Row(children: [
                Flexible(flex: 7, child: widget.child),
                Flexible(
                    flex: 3,
                    child: ElevatedButton(
                        onPressed: () {}, child: const Text("Delete")))
              ])
            : widget.child);
  }
}
