import 'package:flutter/material.dart';
import '../models/block_shape.dart';
import 'cell_widget.dart';

/// Widget hiển thị khối đang bay theo ngón tay
class FloatingBlockOverlay extends StatelessWidget {
  final BlockShape block;
  final Offset position;
  final double cellSize;

  const FloatingBlockOverlay({
    super.key,
    required this.block,
    required this.position,
    this.cellSize = 35,
  });

  @override
  Widget build(BuildContext context) {
    double blockWidth = block.width * (cellSize + 2);
    double blockHeight = block.height * (cellSize + 2);
    
    return Positioned(
      left: position.dx - (blockWidth / 2),
      top: position.dy - (blockHeight / 2),
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.9,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: block.color.withOpacity(0.8),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < block.height; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int j = 0; j < block.width; j++)
                        CellWidget(
                          color: block.shape[i][j] ? block.color : null,
                          size: cellSize,
                          isPreview: true,
                          showBorder: true,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}