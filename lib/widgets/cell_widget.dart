import 'package:flutter/material.dart';

/// Widget hiển thị một ô vuông với hiệu ứng 3D
class CellWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final bool isPreview; // True nếu là preview khối, false nếu trên bảng
  final bool showBorder;

  const CellWidget({
    Key? key,
    this.color,
    this.size = 40,
    this.isPreview = false,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isEmpty = color == null;

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.all(0.5), // Giảm từ 1 xuống 0.5
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: isEmpty
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  offset: Offset(-1, -1),
                  blurRadius: 2,
                ),
              ],
        gradient: isEmpty
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _lightenColor(color!, 0.3),
                  color!,
                  _darkenColor(color!, 0.2),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
        border: showBorder
            ? Border.all(
                color: isEmpty
                    ? Colors.grey.withOpacity(0.2)
                    : _darkenColor(color!, 0.3),
                width: isEmpty ? 0.5 : 1.5,
              )
            : null,
      ),
      child: isEmpty
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.withOpacity(0.05),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    offset: Offset(1, 1),
                    blurRadius: 1,
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.all(2),
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  /// Làm sáng màu
  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Làm tối màu
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}