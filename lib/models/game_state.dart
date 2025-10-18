import 'package:flutter/foundation.dart';
import 'block_shape.dart';
import 'game_board.dart';
import '../utils/block_generator.dart';

class GameState extends ChangeNotifier {
  late GameBoard board;
  late BlockGenerator generator;
  
  // QUAN TRỌNG: Khai báo đúng type
  List<BlockShape?> currentBlocks = List<BlockShape?>.filled(3, null, growable: false);
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  int level = 1;
  int totalBlocksPlaced = 0;

  GameState() {
    board = GameBoard();
    generator = BlockGenerator();
    _generateNewBlocks();
  }

  void _generateNewBlocks() {
    List<BlockShape> newBlocks = generator.generateBlockSetByLevel(level);
    for (int i = 0; i < 3; i++) {
      currentBlocks[i] = newBlocks[i];
    }
    notifyListeners();
    debugPrint('Generated: ${currentBlocks.map((b) => b?.name).toList()}');
  }

  bool canPlaceBlock(BlockShape block, int row, int col) {
    return board.canPlaceBlock(block, row, col);
  }

  bool placeBlock(int blockIndex, int row, int col) {
    debugPrint('\n=== Place Block ===');
    debugPrint('Block index: $blockIndex, Position: ($row, $col)');
    debugPrint('Before: ${currentBlocks.map((b) => b?.name ?? "null").toList()}');
    
    if (blockIndex < 0 || blockIndex >= 3) {
      debugPrint('❌ Invalid blockIndex: $blockIndex');
      return false;
    }

    BlockShape? block = currentBlocks[blockIndex];
    if (block == null) {
      debugPrint('❌ Block is null at index $blockIndex');
      return false;
    }

    if (!board.canPlaceBlock(block, row, col)) {
      debugPrint('❌ Cannot place block at ($row, $col)');
      return false;
    }

    try {
      String blockName = block.name;
      int blockPoints = block.blockCount;
      
      board.placeBlock(block, row, col);
      debugPrint('✅ Block placed: $blockName');
      
      score += blockPoints;
      totalBlocksPlaced++;
      
      currentBlocks[blockIndex] = null;
      debugPrint('🗑️ Set block[$blockIndex] = null');
      debugPrint('After: ${currentBlocks.map((b) => b?.name ?? "null").toList()}');
      
      // CRITICAL: Notify ngay sau khi set null
      notifyListeners();
      
      ClearResult clearResult = board.clearFullLines();
      
      if (clearResult.totalCleared > 0) {
        int clearScore = clearResult.calculateScore();
        score += clearScore;
        debugPrint('🎉 Cleared ${clearResult.rowsCleared} rows + ${clearResult.colsCleared} cols, +$clearScore pts');
        notifyListeners();
      }

      _checkLevelUp();

      bool allUsed = currentBlocks.every((b) => b == null);
      debugPrint('All blocks used? $allUsed');
      
      if (allUsed) {
        _generateNewBlocks();
        debugPrint('🎲 Generated new blocks: ${currentBlocks.map((b) => b?.name ?? "null").toList()}');
      }

      _checkGameOver();

      if (score > highScore) {
        highScore = score;
      }

      // Final notify
      notifyListeners();
      debugPrint('✅ Completed\n');
      return true;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      debugPrint('Stack: $stackTrace');
      return false;
    }
  }

  void _checkGameOver() {
    if (currentBlocks.every((block) => block == null)) {
      isGameOver = false;
      return;
    }

    for (BlockShape? block in currentBlocks) {
      if (block == null) continue;

      for (int row = 0; row < GameBoard.size; row++) {
        for (int col = 0; col < GameBoard.size; col++) {
          if (board.canPlaceBlock(block, row, col)) {
            isGameOver = false;
            return;
          }
        }
      }
    }

    isGameOver = true;
    debugPrint('💀 GAME OVER! Score: $score');
  }

  void _checkLevelUp() {
    int requiredBlocks = level * 10;
    if (totalBlocksPlaced >= requiredBlocks) {
      level++;
      debugPrint('⭐ LEVEL UP! Now at level $level');
    }
  }

  void resetGame() {
    board.reset();
    score = 0;
    isGameOver = false;
    level = 1;
    totalBlocksPlaced = 0;
    _generateNewBlocks();
    notifyListeners();
    debugPrint('🔄 Game Reset');
  }

  int get remainingBlocks {
    return currentBlocks.where((block) => block != null).length;
  }
}