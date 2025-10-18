import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
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
      print('📍 Board position: $_boardPosition, size: $_boardSize');
    }
  }

  Offset? _globalToGridCoordinate(Offset globalPos) {
    if (_boardSize == Size.zero) return null;

    Offset relativePos = globalPos - _boardPosition;

    const double boardPadding = 12;
    const double innerPadding = 8;
    const double cellSize = 42;
    const double cellMargin = 1;

    double x = relativePos.dx - boardPadding - innerPadding;
    double y = relativePos.dy - boardPadding - innerPadding;

    double col = x / (cellSize + cellMargin);
    double row = y / (cellSize + cellMargin);

    if (row < 0 || row >= 8 || col < 0 || col >= 8) {
      return null;
    }

    return Offset(col.floorToDouble(), row.floorToDouble());
  }

  void _handleDragStart(int blockIndex) {
    print('🎯 Drag start - block $blockIndex');
    final gameState = Provider.of<GameState>(context, listen: false);
    final block = gameState.currentBlocks[blockIndex];
    
    if (block == null) {
      print('❌ Block is null');
      return;
    }
    
    setState(() {
      _draggingBlock = block;
      _draggingBlockIndex = blockIndex;
      _draggingPosition = null;
      _previewPosition = null;
    });
    print('✅ Started dragging: ${block.name}');
  }

  void _handleDragUpdate(int blockIndex, Offset currentPosition) {
    if (_draggingBlock == null) return;

    setState(() {
      _draggingPosition = currentPosition;
      
      Offset? gridPos = _globalToGridCoordinate(currentPosition);
      if (gridPos != null) {
        final gameState = Provider.of<GameState>(context, listen: false);
        int row = gridPos.dy.toInt();
        int col = gridPos.dx.toInt();
        
        if (gameState.canPlaceBlock(_draggingBlock!, row, col)) {
          _previewPosition = Offset(col.toDouble(), row.toDouble());
        } else {
          _previewPosition = null;
        }
      } else {
        _previewPosition = null;
      }
    });
  }

  void _handleDragComplete(int blockIndex, Offset dragStart, Offset dragEnd) {
    print('\n=== Drag Complete ===');
    print('Block index: $blockIndex');
    print('Preview position: $_previewPosition');

    if (_previewPosition != null && _draggingBlockIndex != null) {
      int row = _previewPosition!.dy.toInt();
      int col = _previewPosition!.dx.toInt();
      
      print('📍 Placing at: ($row, $col)');
      
      final gameState = Provider.of<GameState>(context, listen: false);
      bool success = gameState.placeBlock(_draggingBlockIndex!, row, col);
      
      if (success) {
        print('✅ Placed successfully');
        _showMessage('✓ Block placed!', isError: false);
        
        // Force rebuild
        setState(() {});
        
        _checkGameOver(gameState);
      } else {
        print('❌ Failed to place');
        _showMessage('Failed to place block!', isError: true);
      }
    } else {
      print('❌ No valid preview position');
      _showMessage('❌ Drag block over the board!', isError: true);
    }

    _resetDragState();
  }

  void _handleDragCancel() {
    print('🎯 Drag cancelled');
    _resetDragState();
  }

  void _resetDragState() {
    setState(() {
      _draggingBlock = null;
      _draggingBlockIndex = null;
      _draggingPosition = null;
      _previewPosition = null;
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        duration: Duration(milliseconds: isError ? 1000 : 600),
        backgroundColor: isError 
            ? Colors.red.withOpacity(0.9) 
            : Colors.green.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
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
            '👆 Tap & Drag to place blocks',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 3; i++)
                DraggableBlockWidget(
                  key: ValueKey('block-$i-${gameState.currentBlocks[i]?.name ?? "empty"}'),
                  block: gameState.currentBlocks[i],
                  blockIndex: i,
                  onDragStart: () => _handleDragStart(i),
                  onDragUpdate: _handleDragUpdate,
                  onDragComplete: _handleDragComplete,
                  onDragCancel: _handleDragCancel,
                ),
            ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Your Score',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
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
            child: Text(
              'RESET',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}