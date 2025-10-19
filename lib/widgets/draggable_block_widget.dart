import 'package:flutter/material.dart';
import '../models/block_shape.dart';
import 'block_preview_widget.dart';

class DraggableBlockWidget extends StatefulWidget {
  final BlockShape? block;
  final int blockIndex;
  final Function(int, Offset) onDragStart; // Thêm Offset parameter
  final Function(int blockIndex, Offset currentPosition) onDragUpdate;
  final Function(int blockIndex, Offset dragStart, Offset dragEnd) onDragComplete;
  final VoidCallback onDragCancel;

  const DraggableBlockWidget({
    Key? key,
    required this.block,
    required this.blockIndex,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragComplete,
    required this.onDragCancel,
  }) : super(key: key);

  @override
  State<DraggableBlockWidget> createState() => _DraggableBlockWidgetState();
}

class _DraggableBlockWidgetState extends State<DraggableBlockWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  Offset? _dragStartPosition;
  Offset? _lastDragPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(DraggableBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block != widget.block) {
      setState(() {
        _isDragging = false;
        _dragStartPosition = null;
        _lastDragPosition = null;
      });
      _scaleController.reset();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (widget.block == null) return;
    
    setState(() {
      _isDragging = true;
      _dragStartPosition = details.globalPosition;
    });
    
    _scaleController.forward();
    // Truyền cả blockIndex và vị trí bắt đầu của drag
    widget.onDragStart(widget.blockIndex, details.globalPosition);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.block == null || _dragStartPosition == null) return;
    
    _lastDragPosition = details.globalPosition;
    
    widget.onDragUpdate(widget.blockIndex, details.globalPosition);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (widget.block == null || _dragStartPosition == null) return;

    final startPos = _dragStartPosition!;
    
    widget.onDragComplete(widget.blockIndex, startPos, _lastDragPosition ?? startPos);
    
    setState(() {
      _isDragging = false;
      _dragStartPosition = null;
      _lastDragPosition = null;
    });
    
    _scaleController.reverse();
  }

  void _handleDragCancel() {
    setState(() {
      _isDragging = false;
      _dragStartPosition = null;
      _lastDragPosition = null;
    });
    
    _scaleController.reverse();
    widget.onDragCancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block == null) {
      return _buildEmptySlot();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      onPanCancel: _handleDragCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _isDragging ? 0.3 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isDragging
                      ? [
                          BoxShadow(
                            color: widget.block!.color.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: BlockPreviewWidget(
                    block: widget.block,
                    cellSize: 25,
                    showShadow: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green.withOpacity(0.5),
          size: 30,
        ),
      ),
    );
  }
}