import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/game_board.dart';
import '../models/block_shape.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/draggable_block_widget.dart';
import '../widgets/floating_block_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  BlockShape? _draggingBlock;
  int? _draggingBlockIndex;
  Offset? _draggingPosition;
  Offset? _previewPosition;

  final GlobalKey _boardKey = GlobalKey();

  Offset _boardPosition = Offset.zero;
  Size _boardSize = Size.zero;
  final List<GlobalKey> _blockKeys = List.generate(3, (index) => GlobalKey());

  Offset? _dragStartGlobalPosition;
  Offset? _floatingBlockStartPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBoardPosition();
    });
  }

  void _updateBoardPosition() {
    final RenderBox? renderBox =
        _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _boardPosition = renderBox.localToGlobal(Offset.zero);
        _boardSize = renderBox.size;
      });
    }
  }

  // Tìm vị trí preview gần nhất theo phong cách Block Blast
  Offset? _findNearestValidPosition(Offset floatingCenter) {
    if (_draggingBlock == null) return null;

    final gameState = Provider.of<GameState>(context, listen: false);

    // Tính vị trí grid tương ứng với floating center
    const double cellSize = 42;
    const double cellMargin = 1;
    const double boardPadding = 12;
    const double innerPadding = 8;

    // Convert floating center to grid coordinates
    Offset relativePos = floatingCenter - _boardPosition;
    double x = relativePos.dx - boardPadding - innerPadding;
    double y = relativePos.dy - boardPadding - innerPadding;

    // Tính cell center mà floating đang hover
    int centerCol = (x / (cellSize + cellMargin)).round().clamp(
      0,
      GameBoard.size - 1,
    );
    int centerRow = (y / (cellSize + cellMargin)).round().clamp(
      0,
      GameBoard.size - 1,
    );

    // Tính top-left position để đặt block sao cho center block trùng với hover cell
    int blockCenterRow = _draggingBlock!.height ~/ 2;
    int blockCenterCol = _draggingBlock!.width ~/ 2;

    int targetRow = centerRow - blockCenterRow;
    int targetCol = centerCol - blockCenterCol;

    // Clamp to valid board range
    targetRow = targetRow.clamp(0, GameBoard.size - _draggingBlock!.height);
    targetCol = targetCol.clamp(0, GameBoard.size - _draggingBlock!.width);

    // Kiểm tra xem có thể đặt tại vị trí này không
    if (gameState.canPlaceBlock(_draggingBlock!, targetRow, targetCol)) {
      return Offset(targetCol.toDouble(), targetRow.toDouble());
    }

    // Nếu không thể đặt tại vị trí này, tìm vị trí gần nhất trong bán kính nhỏ
    List<MapEntry<Offset, double>> validPositions = [];

    for (int row = 0; row <= GameBoard.size - _draggingBlock!.height; row++) {
      for (int col = 0; col <= GameBoard.size - _draggingBlock!.width; col++) {
        if (gameState.canPlaceBlock(_draggingBlock!, row, col)) {
          // Tính khoảng cách từ target position
          double distance = ((row - targetRow).abs() + (col - targetCol).abs())
              .toDouble();
          validPositions.add(
            MapEntry(Offset(col.toDouble(), row.toDouble()), distance),
          );
        }
      }
    }

    if (validPositions.isEmpty) return null;

    // Sắp xếp theo khoảng cách
    validPositions.sort((a, b) => a.value.compareTo(b.value));

    // Chỉ trả về nếu vị trí gần nhất không quá xa (trong bán kính 3 ô)
    if (validPositions.first.value <= 3) {
      return validPositions.first.key;
    }

    return null;
  }

  // Kiểm tra xem floating có đang ở trên/gần board không
  bool _isNearBoard(Offset floatingCenter) {
    if (_boardSize == Size.zero) return false;

    // Mở rộng vùng board một chút để detect sớm hơn
    Rect expandedBoardRect = Rect.fromLTWH(
      _boardPosition.dx - 60,
      _boardPosition.dy - 60,
      _boardSize.width + 120,
      _boardSize.height + 120,
    );

    return expandedBoardRect.contains(floatingCenter);
  }

  void _handleDragStart(int blockIndex, Offset dragStartGlobalPosition) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final block = gameState.currentBlocks[blockIndex];

    if (block == null) return;

    final RenderBox? blockRenderBox =
        _blockKeys[blockIndex].currentContext?.findRenderObject() as RenderBox?;
    if (blockRenderBox == null) return;

    final blockGlobalPosition = blockRenderBox.localToGlobal(Offset.zero);
    final blockSize = blockRenderBox.size;

    double startX = blockGlobalPosition.dx + blockSize.width / 2;
    double startY = _boardPosition.dy + _boardSize.height;

    setState(() {
      _draggingBlock = block;
      _draggingBlockIndex = blockIndex;
      _floatingBlockStartPosition = Offset(startX, startY);
      _dragStartGlobalPosition = dragStartGlobalPosition;
      _draggingPosition = _floatingBlockStartPosition;
      _previewPosition = null;
    });
  }

  void _handleDragUpdate(int blockIndex, Offset currentGlobalPosition) {
    if (_draggingBlock == null ||
        _floatingBlockStartPosition == null ||
        _dragStartGlobalPosition == null)
      return;

    Offset dragDelta = currentGlobalPosition - _dragStartGlobalPosition!;
    Offset newFloatingPosition = _floatingBlockStartPosition! + dragDelta;

    setState(() {
      _draggingPosition = newFloatingPosition;

      // Phong cách Block Blast: Hiển thị preview ngay khi gần board
      if (_isNearBoard(newFloatingPosition)) {
        _previewPosition = _findNearestValidPosition(newFloatingPosition);
      } else {
        _previewPosition = null;
      }
    });
  }

  void _handleDragComplete(int blockIndex, Offset dragStart, Offset dragEnd) {
    if (_previewPosition != null && _draggingBlockIndex != null) {
      int row = _previewPosition!.dy.toInt();
      int col = _previewPosition!.dx.toInt();

      final gameState = Provider.of<GameState>(context, listen: false);
      bool success = gameState.placeBlock(_draggingBlockIndex!, row, col);

      if (success) {
        _showMessage('✓ Block placed!', isError: false);
        _checkGameOver(gameState);
      } else {
        _showMessage('Failed to place block!', isError: true);
      }
    } else {
      _showMessage('✖ Drag block to the board!', isError: true);
    }

    _resetDragState();
  }

  void _handleDragCancel() {
    _resetDragState();
  }

  void _resetDragState() {
    setState(() {
      _draggingBlock = null;
      _draggingBlockIndex = null;
      _draggingPosition = null;
      _previewPosition = null;
      _dragStartGlobalPosition = null;
      _floatingBlockStartPosition = null;
    });
  }

  void _checkGameOver(GameState gameState) {
    if (gameState.isGameOver) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _showGameOverDialog(gameState);
        }
      });
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        duration: Duration(milliseconds: isError ? 1000 : 600),
        backgroundColor: isError
            ? Colors.red.withOpacity(0.9)
            : Colors.green.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: Consumer<GameState>(
            builder: (context, gameState, child) {
              return Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(gameState),
                      SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: Container(
                            key: _boardKey,
                            child: GameBoardWidget(
                              board: gameState.board,
                              previewBlock: _draggingBlock,
                              previewRow: _previewPosition?.dy.toInt(),
                              previewCol: _previewPosition?.dx.toInt(),
                              cellSize: 42,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildBlocksSection(gameState),
                      SizedBox(height: 30),
                    ],
                  ),
                  if (_draggingBlock != null && _draggingPosition != null)
                    FloatingBlockOverlay(
                      block: _draggingBlock!,
                      position: _draggingPosition!,
                      cellSize: 35,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard(
            title: 'SCORE',
            value: '${gameState.score}',
            gradient: [Colors.blue.shade600, Colors.blue.shade800],
            shadowColor: Colors.blue,
          ),
          _buildStatCard(
            title: 'LEVEL',
            value: '${gameState.level}',
            gradient: [Colors.purple.shade600, Colors.purple.shade800],
            shadowColor: Colors.purple,
          ),
          _buildStatCard(
            title: 'BEST',
            value: '${gameState.highScore}',
            gradient: [Colors.amber.shade600, Colors.orange.shade800],
            shadowColor: Colors.amber,
            isSmall: true,
          ),
          IconButton(
            onPressed: () {
              _showResetDialog(gameState);
            },
            icon: Icon(Icons.refresh, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required List<Color> gradient,
    required Color shadowColor,
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isSmall ? 10 : 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 16,
            vertical: isSmall ? 4 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 18 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlocksSection(GameState gameState) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            '👆 Drag blocks to the board',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              double availableWidth = constraints.maxWidth;
              double blockSize = (availableWidth - 40) / 3;
              blockSize = blockSize.clamp(80.0, 120.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < 3; i++)
                    Container(
                      key: _blockKeys[i],
                      width: blockSize,
                      height: blockSize,
                      child: DraggableBlockWidget(
                        key: ValueKey(
                          'block-$i-${gameState.currentBlocks[i]?.name ?? "empty"}',
                        ),
                        block: gameState.currentBlocks[i],
                        blockIndex: i,
                        onDragStart: _handleDragStart,
                        onDragUpdate: _handleDragUpdate,
                        onDragComplete: _handleDragComplete,
                        onDragCancel: _handleDragCancel,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(GameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Color(0xFF2C3E50),
        title: Text(
          'GAME OVER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 80),
            SizedBox(height: 20),
            Text(
              'Your Score',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '${gameState.score}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            if (gameState.score == gameState.highScore && gameState.score > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                ),
                child: Text(
                  '🏆 NEW HIGH SCORE! 🏆',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameState.resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'PLAY AGAIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(GameState gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Color(0xFF2C3E50),
        title: Text(
          'Reset Game?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your current progress will be lost.\nScore: ${gameState.score}',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameState.resetGame();
              _showMessage('Game reset!', isError: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('RESET', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
