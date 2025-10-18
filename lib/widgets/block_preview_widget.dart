import 'package:flutter/material.dart';
import '../models/block_shape.dart';
import 'cell_widget.dart';

/// Widget hiển thị khối hình với hiệu ứng 3D
class BlockPreviewWidget extends StatelessWidget {
  final BlockShape? block;
  final double cellSize;
  final bool showShadow;

  const BlockPreviewWidget({
    super.key,
    required this.block,
    this.cellSize = 35,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    if (block == null) {
      return Container(
        width: cellSize * 5,
        height: cellSize * 5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.green.withValues(alpha: 0.5),
            size: 40,
          ),
        ),
      );
    }

    final b = block!;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Gradient nền đẹp
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.grey.withValues(alpha: 0.05),
          ],
        ),
        // Border với gradient
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        // Shadow mạnh cho khối
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: b.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: Offset(4, 4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < b.height; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int j = 0; j < b.width; j++)
                    CellWidget(
                      color: b.shape[i][j] ? b.color : null,
                      size: cellSize,
                      isPreview: true,
                      showBorder: true,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}