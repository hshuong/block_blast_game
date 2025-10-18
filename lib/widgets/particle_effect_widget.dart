import 'package:flutter/material.dart';
import 'dart:math';

/// Lớp đại diện một particle (hạt)
class Particle {
  late Offset position;
  late Offset velocity;
  late double size;
  late Color color;
  late double life; // 0.0 đến 1.0
  late double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.maxLife,
  }) {
    life = maxLife;
  }

  /// Cập nhật particle (animation)
  void update(double deltaTime) {
    // Cập nhật vị trí
    position += velocity * deltaTime;
    
    // Áp dụng gravity
    velocity = Offset(velocity.dx, velocity.dy + 200 * deltaTime);
    
    // Giảm life
    life -= deltaTime;
  }

  /// Vẽ particle
  void paint(Canvas canvas, Paint paint) {
    // Opacity dựa trên life remaining
    double opacity = (life / maxLife).clamp(0.0, 1.0);
    paint.color = color.withValues(alpha:opacity * 0.8);

    // Vẽ particle dưới dạng hình tròn
    canvas.drawCircle(position, size * opacity, paint);
  }
}

/// Custom painter để vẽ particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.paint(canvas, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return true; // Luôn repaint vì particles đang animation
  }
}

/// Widget hiển thị particle effects
class ParticleEffectWidget extends StatefulWidget {
  final Offset position;
  final Color color;
  final int particleCount;
  final Duration duration;
  final VoidCallback? onComplete;

  const ParticleEffectWidget({
    super.key,
    required this.position,
    required this.color,
    this.particleCount = 30,
    this.duration = const Duration(milliseconds: 1500),
    this.onComplete,
  });

  @override
  State<ParticleEffectWidget> createState() => _ParticleEffectWidgetState();
}

class _ParticleEffectWidgetState extends State<ParticleEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Tạo particles
    _generateParticles();

    // Animation controller
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
      setState(() {});
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  /// Sinh particles ngẫu nhiên
  void _generateParticles() {
    particles = List.generate(widget.particleCount, (_) {
      // Hướng ngẫu nhiên
      double angle = _random.nextDouble() * 2 * pi;
      double speed = 100 + _random.nextDouble() * 150;

      return Particle(
        position: widget.position,
        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        ),
        size: 3 + _random.nextDouble() * 5,
        color: widget.color,
        maxLife: widget.duration.inMilliseconds / 1000.0,
      );
    });
  }

  /// Cập nhật particles
  void _updateParticles(double deltaTime) {
    for (var particle in particles) {
      particle.update(deltaTime);
    }
    // Xóa particles đã mất life
    particles.removeWhere((p) => p.life <= 0);
  }

  @override
  void didUpdateWidget(ParticleEffectWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _generateParticles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cập nhật particles dựa trên animation progress
    _updateParticles(_controller.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0);

    return CustomPaint(
      painter: ParticlePainter(particles),
      size: Size.infinite,
    );
  }
}

/// Overlay entry để hiển thị particle effects trên màn hình
class ParticleEffectOverlay {
  static void show(
    BuildContext context,
    Offset position,
    Color color, {
    int particleCount = 30,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => ParticleEffectWidget(
        position: position,
        color: color,
        particleCount: particleCount,
        duration: duration,
        onComplete: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}