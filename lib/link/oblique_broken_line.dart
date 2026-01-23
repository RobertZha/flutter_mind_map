import 'package:flutter/material.dart';
import 'package:flutter_mind_map/adapter/i_link_adapter.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/link/i_link.dart';

/// Oblique Broken Line
class ObliqueBrokenLine implements ILink {
  @override
  String getName() {
    return "ObliqueBrokenLine";
  }

  @override
  CustomPainter getPainter(IMindMapNode node) {
    return ObliqueBrokenLinePainter(node: node);
  }
}

class ObliqueBrokenLinePainter extends CustomPainter {
  ObliqueBrokenLinePainter({required this.node});

  IMindMapNode node;

  @override
  void paint(Canvas canvas, Size size) {
    if (node.getExpanded() || !(node.getMindMap()?.getReadOnly() ?? false)) {
      Offset? offset = node.getOffset();
      Size? s = node.getSize();
      if (offset != null && s != null) {
        double p = 0 - node.getLinkOutPadding();
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
              double w = (p + offset.dx - itemOffset.dx - itemSize.width) / 2;

              //Left HLine
              canvas.drawLine(
                Offset(
                  itemOffset.dx + itemSize.width,
                  itemOffset.dy + itemSize.height / 2 + item.getLinkInOffset(),
                ),
                Offset(
                  itemOffset.dx + itemSize.width + w,
                  itemOffset.dy + itemSize.height / 2 + item.getLinkInOffset(),
                ),
                paint,
              );

              //oblique HLine
              canvas.drawLine(
                Offset(
                  itemOffset.dx + itemSize.width + w,
                  itemOffset.dy + itemSize.height / 2 + item.getLinkInOffset(),
                ),
                Offset(
                  offset.dx + p,
                  offset.dy + s.height / 2 + node.getLinkOutOffset(),
                ),
                paint,
              );
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
              double w = (p + itemOffset.dx - offset.dx - s.width) / 2;

              //Right HLine
              canvas.drawLine(
                Offset(
                  itemOffset.dx,
                  itemOffset.dy + itemSize.height / 2 + item.getLinkInOffset(),
                ),
                Offset(
                  itemOffset.dx - w,
                  itemOffset.dy + itemSize.height / 2 + item.getLinkInOffset(),
                ),
                paint,
              );

              //oblique HLine
              canvas.drawLine(
                Offset(
                  itemOffset.dx - w,
                  itemOffset.dy + itemSize.height / 2 + item.getLinkInOffset(),
                ),
                Offset(
                  offset.dx + s.width - p,
                  offset.dy + s.height / 2 + node.getLinkOutOffset(),
                ),
                paint,
              );
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ObliqueBrokenLineAdapter implements ILinkAdapter {
  @override
  ILink createLink() {
    return ObliqueBrokenLine();
  }

  @override
  String getName() {
    return "ObliqueBrokenLine";
  }
}
