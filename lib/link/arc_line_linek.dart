import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_mind_map/adapter/i_link_adapter.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/link/i_link.dart';
import 'package:flutter_mind_map/mind_map.dart';

/// Oblique Broken Line
class ArcLineLink implements ILink {
  @override
  String getName() {
    return "ArcLineLink";
  }

  @override
  CustomPainter getPainter(IMindMapNode node) {
    return ArcLineLinkPainter(node: node);
  }
}

class ArcLineLinkPainter extends CustomPainter {
  ArcLineLinkPainter({required this.node});

  IMindMapNode node;

  @override
  void paint(Canvas canvas, Size size) {
    if (node.getExpanded() || !(node.getMindMap()?.getReadOnly() ?? false)) {
      switch (node.getMindMap()?.getMapType() ?? MapType.mind) {
        case MapType.mind:
          Offset? offset = node.getOffset();
          Size? s = node.getSize();
          if (offset != null && s != null) {
            if (node.getNodeType() != NodeType.right) {
              for (IMindMapNode item in node.getLeftItems()) {
                Paint paint = Paint()
                  ..color = item.getLinkColor()
                  ..style = PaintingStyle.stroke
                  ..strokeCap = StrokeCap.round
                  ..strokeWidth = item.getLinkWidth();

                Offset? itemOffset = item.getOffsetByParent();
                Size? itemSize = item.getSize();
                if (itemOffset != null && itemSize != null) {
                  double p = 0 - node.getLinkOutPadding();

                  double w = offset.dx - itemOffset.dx - itemSize.width + p;
                  double h =
                      (itemOffset.dy +
                          itemSize.height / 2 +
                          item.getLinkInOffset()) -
                      (offset.dy + s.height / 2 + node.getLinkOutOffset());

                  if (w > h.abs()) {
                    //Left HLine
                    if (h == 0) {
                      canvas.drawLine(
                        Offset(
                          itemOffset.dx + itemSize.width,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        Offset(
                          offset.dx,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        paint,
                      );
                    } else {
                      canvas.drawLine(
                        Offset(
                          itemOffset.dx + itemSize.width,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        Offset(
                          itemOffset.dx + itemSize.width + w - h.abs(),
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        paint,
                      );
                    }
                    //Arc Line
                    if (h < 0) {
                      canvas.drawArc(
                        Rect.fromLTRB(
                          itemOffset.dx + itemSize.width + w - h.abs() * 2,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                          itemOffset.dx + itemSize.width + w,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() +
                              h.abs(),
                        ),
                        3 * pi / 2,
                        pi / 2,
                        false,
                        paint,
                      );
                    } else {
                      canvas.drawArc(
                        Rect.fromLTRB(
                          itemOffset.dx + itemSize.width + w - h.abs() * 2,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() -
                              h.abs(),
                          itemOffset.dx + itemSize.width + w,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        0,
                        pi / 2,
                        false,
                        paint,
                      );
                    }
                  } else {
                    if (h < 0) {
                      final radius = (w * w + h.abs() * h.abs()) / (2 * w);
                      double angle = asin(h.abs() / radius);

                      canvas.drawArc(
                        Rect.fromLTRB(
                          offset.dx + p - radius * 2,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() -
                              radius,
                          offset.dx + p,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() +
                              radius,
                        ),
                        0 - angle,
                        angle,
                        false,
                        paint,
                      );
                    } else {
                      final radius = (w * w + h.abs() * h.abs()) / (2 * w);
                      double angle = asin(h.abs() / radius);

                      canvas.drawArc(
                        Rect.fromLTRB(
                          offset.dx + p - radius * 2,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() -
                              radius,
                          offset.dx + p,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() +
                              radius,
                        ),
                        0,
                        angle,
                        false,
                        paint,
                      );
                    }
                  }
                }
              }
            }
            if (node.getNodeType() != NodeType.left) {
              for (IMindMapNode item in node.getRightItems()) {
                Paint paint = Paint()
                  ..color = item.getLinkColor()
                  ..style = PaintingStyle.stroke
                  ..strokeCap = StrokeCap.round
                  ..strokeWidth = item.getLinkWidth();

                Offset? itemOffset = item.getOffsetByParent();
                Size? itemSize = item.getSize();
                if (itemOffset != null && itemSize != null) {
                  double p = 0 - node.getLinkOutPadding();

                  double w = itemOffset.dx - offset.dx - s.width + p;
                  double h =
                      (itemOffset.dy +
                          itemSize.height / 2 +
                          item.getLinkInOffset()) -
                      (offset.dy + s.height / 2 + node.getLinkOutOffset());

                  if (w > h.abs()) {
                    //Right HLine
                    if (h == 0) {
                      canvas.drawLine(
                        Offset(
                          itemOffset.dx,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        Offset(
                          offset.dx + s.width,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        paint,
                      );
                    } else {
                      canvas.drawLine(
                        Offset(
                          itemOffset.dx,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        Offset(
                          itemOffset.dx - (w - h.abs()),
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        paint,
                      );
                    }
                    //Arc Line
                    if (h < 0) {
                      canvas.drawArc(
                        Rect.fromLTRB(
                          offset.dx + s.width - p,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                          offset.dx + s.width - p + h.abs() * 2,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() +
                              h.abs(),
                        ),
                        pi,
                        pi / 2,
                        false,
                        paint,
                      );
                    } else {
                      canvas.drawArc(
                        Rect.fromLTRB(
                          offset.dx + s.width - p,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() -
                              h.abs(),
                          offset.dx + s.width - p + h.abs() * 2,
                          itemOffset.dy +
                              itemSize.height / 2 +
                              item.getLinkInOffset(),
                        ),
                        pi / 2,
                        pi / 2,
                        false,
                        paint,
                      );
                    }
                  } else {
                    if (h < 0) {
                      final radius = (w * w + h.abs() * h.abs()) / (2 * w);
                      double angle = asin(h.abs() / radius);

                      canvas.drawArc(
                        Rect.fromLTRB(
                          offset.dx + s.width - p,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() -
                              radius,
                          offset.dx + s.width - p + radius * 2,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() +
                              radius,
                        ),
                        pi,
                        angle,
                        false,
                        paint,
                      );
                    } else {
                      final radius = (w * w + h.abs() * h.abs()) / (2 * w);
                      double angle = asin(h.abs() / radius);

                      canvas.drawArc(
                        Rect.fromLTRB(
                          offset.dx + s.width - p,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() -
                              radius,
                          offset.dx + s.width - p + radius * 2,
                          offset.dy +
                              s.height / 2 +
                              node.getLinkOutOffset() +
                              radius,
                        ),
                        pi - angle,
                        angle,
                        false,
                        paint,
                      );
                    }
                  }
                }
              }
            }
          }
          break;
        case MapType.fishbone:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ArcLineLinkAdapter implements ILinkAdapter {
  @override
  ILink createLink() {
    return ArcLineLink();
  }

  @override
  String getName() {
    return "ArcLineLink";
  }
}
