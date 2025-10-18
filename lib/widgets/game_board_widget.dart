import 'package:flutter/material.dart';
import '../models/game_board.dart';
import '../models/block_shape.dart';
import 'cell_widget.dart';

/// Widget hiển thị bảng chơi 8x8 với hiệu ứng đẹp
class GameBoardWidget extends StatefulWidget {
  final GameBoard board;
  final BlockShape? previewBlock;
  final int? previewRow;
  final int? previewCol;
  final double cellSize;

  const GameBoardWidget({
    Key? key,
    required this.board,
    this.previewBlock,
    this.previewRow,
    this.previewCol,
    this.cellSize = 42,
  }) : super(key: key);

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  @override
  Widget build(BuildContext context) {
    // Tính toán kích thước động dựa trên màn hình
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 80; // Trừ margins
    final calculatedCellSize = (availableWidth / GameBoard.size) - 3;
    final actualCellSize = calculatedCellSize.clamp(35.0, 45.0);
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF34495E),
            Color(0xFF2C3E50),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
          color: Color(0xFF1A252F),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int row = 0; row < GameBoard.size; row++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int col = 0; col < GameBoard.size; col++)
                    _buildCell(row, col, actualCellSize),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    Color? cellColor = widget.board.grid[row][col];

    bool isPreview = false;
    Color? previewColor;

    if (widget.previewBlock != null && 
        widget.previewRow != null && 
        widget.previewCol != null) {
      int blockRow = row - widget.previewRow!;
      int blockCol = col - widget.previewCol!;

      if (blockRow >= 0 &&
          blockRow < widget.previewBlock!.height &&
          blockCol >= 0 &&
          blockCol < widget.previewBlock!.width) {
        if (widget.previewBlock!.shape[blockRow][blockCol]) {
          isPreview = true;
          previewColor = widget.previewBlock!.color.withOpacity(0.4);
        }
      }
    }

    if (isPreview && cellColor == null) {
      return CellWidget(
        color: previewColor,
        size: cellSize,
        showBorder: true,
      );
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: CellWidget(
        key: ValueKey('$row-$col-${cellColor?.value}'),
        color: cellColor,
        size: cellSize,
        showBorder: true,
      ),
    );
  }
}