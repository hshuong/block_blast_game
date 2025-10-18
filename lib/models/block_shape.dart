import 'package:flutter/material.dart';

/// Lớp đại diện cho một khối hình trong game
/// Mỗi khối được biểu diễn bằng ma trận 2D (List<List<bool>>)
/// true = có ô, false = ô trống
class BlockShape {
  final List<List<bool>> shape;
  final Color color;
  final String name;

  BlockShape({
    required this.shape,
    required this.color,
    required this.name,
  });

  /// Chiều cao của khối (số hàng)
  int get height => shape.length;

  /// Chiều rộng của khối (số cột)
  int get width => shape.isEmpty ? 0 : shape[0].length;

  /// Đếm số ô thực sự trong khối (để tính điểm)
  int get blockCount {
    int count = 0;
    for (var row in shape) {
      for (var cell in row) {
        if (cell) count++;
      }
    }
    return count;
  }

  /// Copy khối với màu mới
  BlockShape copyWith({Color? color}) {
    return BlockShape(
      shape: shape,
      color: color ?? this.color,
      name: name,
    );
  }
}

/// Factory tạo tất cả các loại khối trong game
class BlockShapes {
  // ============ KHỐI HÌNH CHỮ I (Đường thẳng) ============
  
  /// Khối I ngang 1x3
  static BlockShape get i1x3 => BlockShape(
    name: 'I1x3',
    color: Colors.cyan,
    shape: [
      [true, true, true],
    ],
  );

  /// Khối I ngang 1x4
  static BlockShape get i1x4 => BlockShape(
    name: 'I1x4',
    color: Colors.cyan,
    shape: [
      [true, true, true, true],
    ],
  );

  /// Khối I ngang 1x5
  static BlockShape get i1x5 => BlockShape(
    name: 'I1x5',
    color: Colors.cyan,
    shape: [
      [true, true, true, true, true],
    ],
  );

  /// Khối I dọc 3x1
  static BlockShape get i3x1 => BlockShape(
    name: 'I3x1',
    color: Colors.cyan,
    shape: [
      [true],
      [true],
      [true],
    ],
  );

  /// Khối I dọc 4x1
  static BlockShape get i4x1 => BlockShape(
    name: 'I4x1',
    color: Colors.cyan,
    shape: [
      [true],
      [true],
      [true],
      [true],
    ],
  );

  /// Khối I dọc 5x1
  static BlockShape get i5x1 => BlockShape(
    name: 'I5x1',
    color: Colors.cyan,
    shape: [
      [true],
      [true],
      [true],
      [true],
      [true],
    ],
  );

  // ============ KHỐI VUÔNG ============
  
  /// Khối vuông 1x1 (ô đơn)
  static BlockShape get square1x1 => BlockShape(
    name: 'Square1x1',
    color: Colors.yellow,
    shape: [
      [true],
    ],
  );

  /// Khối vuông 2x2
  static BlockShape get square2x2 => BlockShape(
    name: 'Square2x2',
    color: Colors.yellow,
    shape: [
      [true, true],
      [true, true],
    ],
  );

  /// Khối vuông 3x3
  static BlockShape get square3x3 => BlockShape(
    name: 'Square3x3',
    color: Colors.yellow,
    shape: [
      [true, true, true],
      [true, true, true],
      [true, true, true],
    ],
  );

  // ============ KHỐI CHỮ NHẬT ============
  
  /// Khối chữ nhật 2x3 (ngang)
  static BlockShape get rect2x3 => BlockShape(
    name: 'Rect2x3',
    color: Colors.orange,
    shape: [
      [true, true, true],
      [true, true, true],
    ],
  );

  /// Khối chữ nhật 3x2 (dọc)
  static BlockShape get rect3x2 => BlockShape(
    name: 'Rect3x2',
    color: Colors.orange,
    shape: [
      [true, true],
      [true, true],
      [true, true],
    ],
  );

  // ============ KHỐI CHỮ L ============
  
  /// Khối L hướng lên
  static BlockShape get lUp => BlockShape(
    name: 'L_Up',
    color: Colors.blue,
    shape: [
      [true, false],
      [true, false],
      [true, true],
    ],
  );

  /// Khối L hướng phải
  static BlockShape get lRight => BlockShape(
    name: 'L_Right',
    color: Colors.blue,
    shape: [
      [true, true, true],
      [true, false, false],
    ],
  );

  /// Khối L hướng xuống
  static BlockShape get lDown => BlockShape(
    name: 'L_Down',
    color: Colors.blue,
    shape: [
      [true, true],
      [false, true],
      [false, true],
    ],
  );

  /// Khối L hướng trái
  static BlockShape get lLeft => BlockShape(
    name: 'L_Left',
    color: Colors.blue,
    shape: [
      [false, false, true],
      [true, true, true],
    ],
  );

  // ============ KHỐI CHỮ J (L ngược) ============
  
  /// Khối J hướng lên
  static BlockShape get jUp => BlockShape(
    name: 'J_Up',
    color: Colors.purple,
    shape: [
      [false, true],
      [false, true],
      [true, true],
    ],
  );

  /// Khối J hướng phải
  static BlockShape get jRight => BlockShape(
    name: 'J_Right',
    color: Colors.purple,
    shape: [
      [true, false, false],
      [true, true, true],
    ],
  );

  /// Khối J hướng xuống
  static BlockShape get jDown => BlockShape(
    name: 'J_Down',
    color: Colors.purple,
    shape: [
      [true, true],
      [true, false],
      [true, false],
    ],
  );

  /// Khối J hướng trái
  static BlockShape get jLeft => BlockShape(
    name: 'J_Left',
    color: Colors.purple,
    shape: [
      [true, true, true],
      [false, false, true],
    ],
  );

  // ============ KHỐI CHỮ T ============
  
  /// Khối T hướng lên
  static BlockShape get tUp => BlockShape(
    name: 'T_Up',
    color: Colors.green,
    shape: [
      [true, true, true],
      [false, true, false],
    ],
  );

  /// Khối T hướng phải
  static BlockShape get tRight => BlockShape(
    name: 'T_Right',
    color: Colors.green,
    shape: [
      [false, true],
      [true, true],
      [false, true],
    ],
  );

  /// Khối T hướng xuống
  static BlockShape get tDown => BlockShape(
    name: 'T_Down',
    color: Colors.green,
    shape: [
      [false, true, false],
      [true, true, true],
    ],
  );

  /// Khối T hướng trái
  static BlockShape get tLeft => BlockShape(
    name: 'T_Left',
    color: Colors.green,
    shape: [
      [true, false],
      [true, true],
      [true, false],
    ],
  );

  // ============ KHỐI CHỮ S ============
  
  /// Khối S ngang
  static BlockShape get sHorizontal => BlockShape(
    name: 'S_Horizontal',
    color: Colors.red,
    shape: [
      [false, true, true],
      [true, true, false],
    ],
  );

  /// Khối S dọc
  static BlockShape get sVertical => BlockShape(
    name: 'S_Vertical',
    color: Colors.red,
    shape: [
      [true, false],
      [true, true],
      [false, true],
    ],
  );

  // ============ KHỐI CHỮ Z ============
  
  /// Khối Z ngang
  static BlockShape get zHorizontal => BlockShape(
    name: 'Z_Horizontal',
    color: Colors.pink,
    shape: [
      [true, true, false],
      [false, true, true],
    ],
  );

  /// Khối Z dọc
  static BlockShape get zVertical => BlockShape(
    name: 'Z_Vertical',
    color: Colors.pink,
    shape: [
      [false, true],
      [true, true],
      [true, false],
    ],
  );

  // ============ DANH SÁCH TẤT CẢ CÁC KHỐI ============
  
  /// Lấy tất cả các khối có thể có trong game
  static List<BlockShape> get allShapes => [
    // Khối I
    i1x3, i1x4, i1x5,
    i3x1, i4x1, i5x1,
    // Khối vuông
    square1x1, square2x2, square3x3,
    // Khối chữ nhật
    rect2x3, rect3x2,
    // Khối L
    lUp, lRight, lDown, lLeft,
    // Khối J
    jUp, jRight, jDown, jLeft,
    // Khối T
    tUp, tRight, tDown, tLeft,
    // Khối S
    sHorizontal, sVertical,
    // Khối Z
    zHorizontal, zVertical,
  ];
}