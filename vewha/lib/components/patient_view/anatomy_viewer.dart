// lib/components/patient_view/anatomy_viewer.dart
// Interactive physiology visualization upgrade using data-driven SVG config.
// Replaced body.mp4 with dynamic layer rendering based on AnatomyAnimationConfig.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/prescriptions.dart';
import '../../data/anatomy_config.dart';

class AnatomyViewer extends StatefulWidget {
  final BodySystem bodySystem;
  final double height;
  final AnatomyAnimationConfig? config;
  final ValueNotifier<int>? activeStepNotifier;
  final String language;

  const AnatomyViewer({
    super.key,
    required this.bodySystem,
    this.height = 350, 
    this.config,
    this.activeStepNotifier,
    this.language = 'en',
  });

  @override
  State<AnatomyViewer> createState() => _AnatomyViewerState();
}

class _AnatomyViewerState extends State<AnatomyViewer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base SVG Anatomy Model
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SvgPicture.asset(
              'assets/anatomy/${widget.bodySystem.name}.svg',
              height: widget.height,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF1D9E75))),
            ),
          ),
          
          // Mechanism Pathway Animation Overlay
          if (widget.config != null)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_animation, widget.activeStepNotifier]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: _MechanismPainter(
                      config: widget.config!,
                      progress: _animation.value,
                      activeStep: widget.activeStepNotifier?.value ?? -1,
                      language: widget.language,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MechanismPainter extends CustomPainter {
  final AnatomyAnimationConfig config;
  final double progress;
  final int activeStep;
  final String language;

  _MechanismPainter({
    required this.config,
    required this.progress,
    required this.activeStep,
    required this.language,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // If no active step yet, don't draw overlays
    if (activeStep < 0) return;

    // Collect active items to draw
    final activeIds = <String>{};
    for (int i = 0; i <= activeStep; i++) {
      if (config.narrationSyncPoints.containsKey(i)) {
        activeIds.addAll(config.narrationSyncPoints[i]!);
      }
    }

    // 1. Draw Paths first (so they are under organs)
    for (final path in config.animationPaths) {
      if (!activeIds.contains(path.id)) continue;
      _drawPath(canvas, size, path);
    }

    // 2. Draw Organs
    for (final organ in config.organTargets) {
      if (!activeIds.contains(organ.id)) continue;
      _drawOrgan(canvas, size, organ);
    }
    
    // 3. Draw Outcome if active
    String currentOutcomeText = config.outcomeText;
    if (language == 'te' && config.outcomeTextTe.isNotEmpty) {
      currentOutcomeText = config.outcomeTextTe;
    } else if (language == 'hi' && config.outcomeTextHi.isNotEmpty) {
      currentOutcomeText = config.outcomeTextHi;
    }

    if (activeIds.contains('outcome') && currentOutcomeText.isNotEmpty) {
      // Find outcome position (usually bottom center of the active region, or default)
      final x = size.width / 2;
      final y = size.height * 0.8;
      _drawBenefit(canvas, currentOutcomeText, x - 30, y, config.outcomeColor);
    }
  }

  void _drawOrgan(Canvas canvas, Size size, OrganTarget organ) {
    final x = organ.normalizedPosition.dx * size.width;
    final y = organ.normalizedPosition.dy * size.height;
    final paint = Paint()..isAntiAlias = true;

    paint.style = PaintingStyle.fill;
    
    if (organ.effectType == 'pulse') {
      final intensity = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
      paint.color = organ.highlightColor.withAlpha((200 * intensity).round());
      canvas.drawCircle(Offset(x, y), 25 + (5 * intensity), paint);
    } else if (organ.effectType == 'expand') {
      // Simulate lungs expanding and contracting
      final intensity = 0.5 + 0.5 * math.sin(progress * 2 * math.pi); // 0 to 1
      paint.color = organ.highlightColor.withAlpha(150);
      // Draw two lung-like lobes expanding
      final currentRadius = 20 + (15 * intensity);
      canvas.drawCircle(Offset(x - 20, y), currentRadius, paint);
      canvas.drawCircle(Offset(x + 20, y), currentRadius, paint);
    } else if (organ.effectType == 'widen') {
      // Simulate airways widening
      final intensity = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 8 + (8 * intensity);
      paint.color = organ.highlightColor.withAlpha(200);
      paint.strokeCap = StrokeCap.round;
      // Draw a Y-shape for airways
      canvas.drawLine(Offset(x, y - 20), Offset(x, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x - 15, y + 20), paint);
      canvas.drawLine(Offset(x, y), Offset(x + 15, y + 20), paint);
    } else if (organ.effectType == 'heal') {
      // Transition from red/inflamed to healthy color
      final isRed = progress < 0.5;
      final colorProg = isRed ? 1.0 : 1.0 - ((progress - 0.5) * 2); 
      final currentColor = Color.lerp(organ.highlightColor, Colors.red, colorProg) ?? organ.highlightColor;
      paint.color = currentColor.withAlpha(200);
      
      // Draw an organic shaped region for skin patch
      final path = Path();
      path.moveTo(x - 30, y);
      path.quadraticBezierTo(x, y - 20, x + 30, y);
      path.quadraticBezierTo(x + 40, y + 30, x, y + 30);
      path.quadraticBezierTo(x - 40, y + 30, x - 30, y);
      canvas.drawPath(path, paint);
    } else if (organ.effectType == 'skin_layers') {
      // Draw static skin cross-section layers (Epidermis, Dermis, Subcutaneous)
      final rectWidth = 120.0;
      final rectHeight = 60.0;
      
      // Subcutaneous (bottom)
      paint.color = const Color(0xFFFFD180);
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y, rectWidth, rectHeight), paint);
      
      // Dermis (middle)
      paint.color = const Color(0xFFFFAB91);
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y - 20, rectWidth, 20), paint);
      
      // Epidermis (top)
      paint.color = const Color(0xFFFFCCBC);
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y - 30, rectWidth, 10), paint);
    } else if (organ.effectType == 'fade_inflammation') {
      // Draw skin layers, but Dermis transitions from inflamed (red) to healthy
      final rectWidth = 120.0;
      final rectHeight = 60.0;
      
      // Subcutaneous (bottom)
      paint.color = const Color(0xFFFFD180);
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y, rectWidth, rectHeight), paint);
      
      // Dermis (middle) transitions from Red to Healthy
      final inflamedColor = Colors.redAccent;
      final healthyColor = const Color(0xFFFFAB91);
      final transitionColor = Color.lerp(inflamedColor, healthyColor, progress) ?? healthyColor;
      paint.color = transitionColor;
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y - 20, rectWidth, 20), paint);
      
      // Epidermis (top)
      paint.color = const Color(0xFFFFCCBC);
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y - 30, rectWidth, 10), paint);
    } else if (organ.effectType == 'circulate') {
      // Simulate whole-body distribution with expanding rings
      final intensity1 = (progress) % 1.0;
      final intensity2 = (progress + 0.33) % 1.0;
      final intensity3 = (progress + 0.66) % 1.0;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paint.color = organ.highlightColor.withAlpha((200 * (1.0 - intensity1)).round());
      canvas.drawCircle(Offset(x, y), 30 + (50 * intensity1), paint);
      paint.color = organ.highlightColor.withAlpha((200 * (1.0 - intensity2)).round());
      canvas.drawCircle(Offset(x, y), 30 + (50 * intensity2), paint);
      paint.color = organ.highlightColor.withAlpha((200 * (1.0 - intensity3)).round());
      canvas.drawCircle(Offset(x, y), 30 + (50 * intensity3), paint);
      // Center body core
      paint.style = PaintingStyle.fill;
      paint.color = organ.highlightColor.withAlpha(200);
      canvas.drawCircle(Offset(x, y), 25, paint);
    } else if (organ.effectType == 'vessel_widen') {
      // Widen expanding blood vessel network
      final intensity = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 6 + (12 * intensity);
      paint.color = organ.highlightColor.withAlpha(200);
      paint.strokeCap = StrokeCap.round;
      // Draw branching vessels
      canvas.drawLine(Offset(x - 30, y - 20), Offset(x, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x + 30, y - 10), paint);
      canvas.drawLine(Offset(x, y), Offset(x + 10, y + 30), paint);
    } else {
      paint.color = organ.highlightColor.withAlpha(200);
      canvas.drawCircle(Offset(x, y), 25, paint);
    }
    
    String labelText = organ.name;
    if (language == 'te') labelText = organ.nameTe;
    if (language == 'hi') labelText = organ.nameHi;
    
    _drawLabel(canvas, labelText, x, y - 40);
  }

  void _drawPath(Canvas canvas, Size size, AnimationPath path) {
    final p1 = Offset(path.startNormalized.dx * size.width, path.startNormalized.dy * size.height);
    final p2 = Offset(path.endNormalized.dx * size.width, path.endNormalized.dy * size.height);
    
    _drawDashedPathway(canvas, p1, p2, path.color);

    // Particle
    if (path.style == 'particles') {
      final signalX = p1.dx + (p2.dx - p1.dx) * progress;
      final signalY = p1.dy + (p2.dy - p1.dy) * progress;
      canvas.drawCircle(Offset(signalX, signalY), 6, Paint()..color = Colors.white);
    } else if (path.style == 'penetrate') {
      // Draw multiple descending particles
      final paint = Paint()..color = Colors.white;
      for (int i = 0; i < 3; i++) {
        double p = (progress + (i * 0.33)) % 1.0;
        final signalX = p1.dx + (p2.dx - p1.dx) * p;
        final signalY = p1.dy + (p2.dy - p1.dy) * p;
        canvas.drawCircle(Offset(signalX, signalY), 4, paint);
      }
    }
  }

  void _drawDashedPathway(Canvas canvas, Offset p1, Offset p2, Color color) {
    final paint = Paint()
      ..color = color.withAlpha(150)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startY = 0.0;
    
    canvas.save();
    canvas.translate(p1.dx, p1.dy);
    canvas.rotate(math.atan2(dy, dx));
    
    while (startY < distance) {
      canvas.drawLine(Offset(startY, 0), Offset(startY + dashWidth, 0), paint);
      startY += dashWidth + dashSpace;
    }
    canvas.restore();
  }

  void _drawLabel(Canvas canvas, String text, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - (textPainter.width / 2) - 4, y - 2, textPainter.width + 8, textPainter.height + 4),
      const Radius.circular(4),
    );
    canvas.drawRRect(bgRect, Paint()..color = Colors.black54);
    textPainter.paint(canvas, Offset(x - (textPainter.width / 2), y));
  }

  void _drawBenefit(Canvas canvas, String text, double x, double y, Color textColor) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          shadows: const [Shadow(color: Colors.white, blurRadius: 6)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(canvas, Offset(x - (textPainter.width / 2) + 30, y));
  }

  @override
  bool shouldRepaint(covariant _MechanismPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activeStep != activeStep || oldDelegate.config != config;
  }
}
