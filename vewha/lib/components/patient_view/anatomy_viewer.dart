// lib/components/patient_view/anatomy_viewer.dart
// Interactive physiology visualization upgrade using data-driven SVG config.
// Replaced body.mp4 with dynamic layer rendering based on AnatomyAnimationConfig.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Vewha/data/prescriptions.dart' hide Colors;
import 'package:Vewha/data/anatomy_config.dart';

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
    if (language == 'te' && config.outcomeTextTe.isNotEmpty) currentOutcomeText = config.outcomeTextTe;
    else if (language == 'hi' && config.outcomeTextHi.isNotEmpty) currentOutcomeText = config.outcomeTextHi;
    else if (language == 'kn' && config.outcomeTextKn.isNotEmpty) currentOutcomeText = config.outcomeTextKn;
    else if (language == 'ta' && config.outcomeTextTa.isNotEmpty) currentOutcomeText = config.outcomeTextTa;
    else if (language == 'mr' && config.outcomeTextMr.isNotEmpty) currentOutcomeText = config.outcomeTextMr;
    else if (language == 'bn' && config.outcomeTextBn.isNotEmpty) currentOutcomeText = config.outcomeTextBn;

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
    } else if (organ.effectType == 'hepatocytes') {
      // Background cell
      paint.color = organ.highlightColor.withOpacity(0.3);
      paint.style = PaintingStyle.fill;
      final cellRect = RRect.fromRectAndRadius(Rect.fromLTWH(x - 50, y - 50, 100, 100), const Radius.circular(15));
      canvas.drawRRect(cellRect, paint);
      
      // Cell membrane border
      paint.color = organ.highlightColor.withOpacity(0.8);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      canvas.drawRRect(cellRect, paint);
      
      // Nucleus
      paint.style = PaintingStyle.fill;
      paint.color = Colors.purple.withOpacity(0.4);
      canvas.drawCircle(Offset(x, y + 15), 18, paint);

      // GLUT Transporters (Channels on top membrane)
      paint.color = Colors.cyan;
      canvas.drawRect(Rect.fromLTWH(x - 20, y - 55, 10, 10), paint);
      canvas.drawRect(Rect.fromLTWH(x + 10, y - 55, 10, 10), paint);

      // Mitochondria (ovals)
      paint.color = Colors.orange.withOpacity(0.5 + (0.5 * progress));
      canvas.save();
      canvas.translate(x - 25, y - 10);
      canvas.rotate(math.pi / 4);
      canvas.drawOval(Rect.fromLTWH(0, 0, 16, 8), paint);
      canvas.restore();
      canvas.save();
      canvas.translate(x + 15, y - 10);
      canvas.rotate(-math.pi / 4);
      canvas.drawOval(Rect.fromLTWH(0, 0, 16, 8), paint);
      canvas.restore();

      // Drug particles entering through channels
      paint.color = Colors.white;
      double enterProg = (progress * 2) % 1.0; 
      canvas.drawCircle(Offset(x - 15, y - 60 + (40 * enterProg)), 3, paint);
      canvas.drawCircle(Offset(x + 15, y - 60 + (40 * enterProg)), 3, paint);

      // Glucose molecules (synthesizing and exiting)
      paint.color = Colors.yellow;
      int maxGlucose = 8;
      int currentGlucose = (maxGlucose * (1.0 - (progress * 0.8))).round();
      for (int i = 0; i < currentGlucose; i++) {
        double gProg = (progress + (i * 0.15)) % 1.0;
        double gx = x - 20 + (40 * (i / maxGlucose));
        double gy = y - (30 * gProg);
        canvas.drawCircle(Offset(gx, gy), 4, paint);
      }
    } else if (organ.effectType == 'bronchi_cascade') {
      void drawBronchus(Offset start, Offset end, double cascadeProg) {
        double p = cascadeProg.clamp(0.0, 1.0);
        Color mColor = Color.lerp(const Color(0xFF8B0000), const Color(0xFFFF8A80), p)!;
        double w = 8 + (8 * p);
        
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = w + 4;
        paint.color = mColor.withOpacity(0.8 - (0.3 * p));
        paint.strokeCap = StrokeCap.round;
        canvas.drawLine(start, end, paint);
        
        paint.strokeWidth = w;
        paint.color = Colors.black87;
        canvas.drawLine(start, end, paint);
      }
      
      drawBronchus(Offset(x, y - 40), Offset(x, y - 10), progress * 3);
      drawBronchus(Offset(x, y - 10), Offset(x - 20, y + 15), (progress - 0.33) * 3);
      drawBronchus(Offset(x, y - 10), Offset(x + 20, y + 15), (progress - 0.33) * 3);
      drawBronchus(Offset(x - 20, y + 15), Offset(x - 30, y + 35), (progress - 0.66) * 3);
      drawBronchus(Offset(x + 20, y + 15), Offset(x + 30, y + 35), (progress - 0.66) * 3);
    } else if (organ.effectType == 'air_flow') {
      paint.style = PaintingStyle.fill;
      paint.color = Colors.lightBlueAccent.withOpacity(0.8);
      double speedMultiplier = 1.0 + (2.0 * progress); 
      for(int i=0; i<8; i++) {
         double p = ((progress * speedMultiplier) + (i * 0.125)) % 1.0;
         if (p < 0.4) {
           double yy = y - 40 + (p / 0.4) * 30;
           canvas.drawCircle(Offset(x, yy), 3, paint);
         } else if (p < 0.7) {
           double subP = (p - 0.4) / 0.3;
           bool isLeft = i % 2 == 0;
           double xx = x + (isLeft ? -20 * subP : 20 * subP);
           double yy = y - 10 + (subP * 25);
           canvas.drawCircle(Offset(xx, yy), 3, paint);
         } else {
           double subP = (p - 0.7) / 0.3;
           bool isLeft = i % 2 == 0;
           double xx = isLeft ? x - 20 - (10 * subP) : x + 20 + (10 * subP);
           double yy = y + 15 + (subP * 20);
           canvas.drawCircle(Offset(xx, yy), 3, paint);
         }
      }
    } else if (organ.effectType == 'skin_layers') {
      final rectWidth = 140.0;
      paint.color = const Color(0xFFFFCCBC);
      paint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y - 40, rectWidth, 15), paint);
      
      paint.color = const Color(0xFFF5F5DC);
      canvas.drawOval(Rect.fromLTWH(x - 30, y - 45, 60, 10), paint);
      
      for (int i=0; i<15; i++) {
         double p = (progress + (i * 0.06)) % 1.0;
         double px = x - 30 + (i * 4.2);
         double py = y - 40 + (15 * p);
         canvas.drawCircle(Offset(px, py), 2, paint);
      }
    } else if (organ.effectType == 'dermis_heal') {
      final rectWidth = 140.0;
      double dermisHeight = 45.0 - (15.0 * progress);
      
      final inflamedColor = Colors.redAccent;
      final healthyColor = const Color(0xFFFFAB91);
      final transitionColor = Color.lerp(inflamedColor, healthyColor, progress) ?? healthyColor;
      
      paint.style = PaintingStyle.fill;
      paint.color = transitionColor;
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, y - 25, rectWidth, dermisHeight), paint);
      
      int cellCount = (30 * (1.0 - (progress * 0.7))).round();
      paint.color = Colors.white70;
      for (int i=0; i<cellCount; i++) {
         double px = x - (rectWidth/2) + ((i * 17) % rectWidth);
         double py = y - 20 + ((i * 11) % (dermisHeight - 10));
         canvas.drawCircle(Offset(px, py), 2, paint);
      }
      
      paint.color = const Color(0xFFFFD180);
      double subY = y - 25 + dermisHeight;
      canvas.drawRect(Rect.fromLTWH(x - rectWidth/2, subY, rectWidth, 20), paint);
    } else if (organ.effectType == 'calcium_block') {
      double r = 20 + (10 * progress);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paint.color = Colors.grey[400]!;
      canvas.drawCircle(Offset(x, y), r + 15, paint);
      
      paint.strokeWidth = 10;
      paint.color = Color.lerp(const Color(0xFF8B0000), const Color(0xFFFF8A80), progress)!;
      canvas.drawCircle(Offset(x, y), r + 7, paint);
      
      paint.strokeWidth = 2;
      paint.color = Colors.red[200]!;
      canvas.drawCircle(Offset(x, y), r, paint);
      
      paint.style = PaintingStyle.fill;
      for (int i=0; i<4; i++) {
        double angle = i * (math.pi / 2);
        double cx = x + (r + 12) * math.cos(angle);
        double cy = y + (r + 12) * math.sin(angle);
        
        paint.color = Colors.yellow;
        canvas.drawRect(Rect.fromLTWH(cx - 4, cy - 4, 8, 8), paint);
        
        if (progress > 0.2) {
          paint.color = Colors.blue;
          double bp = ((progress - 0.2) * 5).clamp(0.0, 1.0);
          double bx = cx + (10 * (1.0 - bp) * math.cos(angle));
          double by = cy + (10 * (1.0 - bp) * math.sin(angle));
          canvas.drawCircle(Offset(bx, by), 3, paint);
        }
      }
    } else if (organ.effectType == 'vessel_widen') {
      double wBase = 10 + (6 * progress);
      double wMid = 6 + (4 * progress);
      double wSmall = 3 + (2 * progress);
      
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.redAccent.withOpacity(0.8);
      paint.strokeCap = StrokeCap.round;
      
      paint.strokeWidth = wBase;
      canvas.drawLine(Offset(x - 40, y - 20), Offset(x, y), paint);
      paint.strokeWidth = wMid;
      canvas.drawLine(Offset(x, y), Offset(x + 30, y - 10), paint);
      paint.strokeWidth = wSmall;
      canvas.drawLine(Offset(x + 30, y - 10), Offset(x + 45, y - 5), paint);
      canvas.drawLine(Offset(x + 30, y - 10), Offset(x + 40, y - 25), paint);
      
      paint.style = PaintingStyle.fill;
      paint.color = Colors.red[900]!;
      double speedMulti = 1.0 + (2.0 * progress);
      for (int i=0; i<5; i++) {
         double p = ((progress * speedMulti) + (i * 0.2)) % 1.0;
         if (p < 0.5) {
           double px = x - 40 + (40 * (p/0.5));
           double py = y - 20 + (20 * (p/0.5));
           canvas.drawOval(Rect.fromLTWH(px-3, py-2, 6, 4), paint);
         } else if (p < 0.8) {
           double sp = (p - 0.5) / 0.3;
           double px = x + (30 * sp);
           double py = y - (10 * sp);
           canvas.drawOval(Rect.fromLTWH(px-2, py-2, 4, 4), paint);
         }
      }
    } else if (organ.effectType == 'pressure_drop') {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 8;
      paint.color = Colors.green;
      canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 30), math.pi, math.pi/2, false, paint);
      paint.color = Colors.red;
      canvas.drawArc(Rect.fromCircle(center: Offset(x, y), radius: 30), math.pi + math.pi/2, math.pi/2, false, paint);
      
      double angle = math.pi * 1.8 - (math.pi * 0.6 * progress);
      paint.color = Colors.black87;
      paint.strokeWidth = 3;
      canvas.drawLine(Offset(x, y), Offset(x + 25 * math.cos(angle), y + 25 * math.sin(angle)), paint);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 4, paint);
    } else if (organ.effectType == 'circulate') {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      double maxRadius = 60.0;
      for (int i=0; i<3; i++) {
        double p = (progress + (i * 0.33)) % 1.0;
        paint.color = organ.highlightColor.withOpacity(0.6 * (1.0 - p));
        canvas.drawCircle(Offset(x, y), maxRadius * p, paint);
      }
      
      paint.style = PaintingStyle.fill;
      double organGlow = (progress < 0.5) ? progress * 2 : 2.0 - (progress * 2);
      paint.color = organ.highlightColor.withOpacity(0.3 + (0.3 * organGlow));
      
      canvas.drawCircle(Offset(x, y - 40), 8, paint);
      canvas.drawCircle(Offset(x - 15, y - 10), 10, paint);
      canvas.drawCircle(Offset(x + 15, y - 10), 10, paint);
      canvas.drawCircle(Offset(x - 5, y), 6, paint);
      canvas.drawCircle(Offset(x + 10, y + 15), 12, paint);
      canvas.drawCircle(Offset(x - 15, y + 25), 8, paint);
      canvas.drawCircle(Offset(x + 15, y + 25), 8, paint);
    } else if (organ.effectType == 'immune_suppress') {
      double ax = x + 30;
      double ay = y - 30;
      paint.style = PaintingStyle.fill;
      double adrenalGlow = progress < 0.4 ? (progress / 0.4) : (1.0 - ((progress - 0.4) / 0.6));
      paint.color = Colors.orange.withOpacity(0.4 + (0.6 * adrenalGlow));
      canvas.drawOval(Rect.fromLTWH(ax - 10, ay - 6, 20, 12), paint);
      
      double tx = x - 10;
      double ty = y + 10;
      Color tColor = Color.lerp(Colors.red, const Color(0xFFFFCCBC), progress)!;
      paint.color = tColor.withOpacity(0.7);
      double tRadius = 35.0 - (10.0 * progress);
      canvas.drawCircle(Offset(tx, ty), tRadius, paint);
      
      int maxCells = 20;
      int currentCells = (maxCells * (1.0 - (progress * 0.5))).round();
      Color cellColor = Color.lerp(Colors.white, Colors.grey[400]!, progress)!;
      paint.color = cellColor;
      
      for (int i=0; i<currentCells; i++) {
        double speed = 2.0 * (1.0 - progress);
        double dx = math.sin((progress * math.pi * 4 * speed) + i) * 6;
        double dy = math.cos((progress * math.pi * 4 * speed) + i) * 6;
        double cx = tx - 20 + ((i * 13) % 40) + dx;
        double cy = ty - 20 + ((i * 17) % 40) + dy;
        
        if (math.pow(cx - tx, 2) + math.pow(cy - ty, 2) < math.pow(tRadius - 3, 2)) {
          canvas.drawCircle(Offset(cx, cy), 2.5, paint);
        }
      }
      
      int maxMarkers = 15;
      int currentMarkers = (maxMarkers * (1.0 - progress)).round();
      paint.color = Colors.yellowAccent;
      for (int i=0; i<currentMarkers; i++) {
        double cx = tx - 25 + ((i * 7) % 50);
        double cy = ty - 25 + ((i * 11) % 50);
        if (math.pow(cx - tx, 2) + math.pow(cy - ty, 2) < math.pow(tRadius, 2)) {
          canvas.drawCircle(Offset(cx, cy), 1.5, paint);
        }
      }
    } else if (organ.effectType == 'taper_warning') {
      double ax = x;
      double ay = y;
      
      // Danger pulse indicating adrenal failure if stopped abruptly
      double pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 10);
      paint.style = PaintingStyle.fill;
      paint.color = Colors.red.withOpacity(0.4 + (0.4 * pulse));
      canvas.drawCircle(Offset(ax, ay), 35 + (8 * pulse), paint);
      
      // Warning Triangle
      paint.color = Colors.yellowAccent;
      Path warningPath = Path();
      warningPath.moveTo(ax, ay - 18);
      warningPath.lineTo(ax - 18, ay + 12);
      warningPath.lineTo(ax + 18, ay + 12);
      warningPath.close();
      canvas.drawPath(warningPath, paint);
      
      // Exclamation Mark inside the triangle
      paint.color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(ax - 2.5, ay - 5, 5, 10), paint);
      canvas.drawCircle(Offset(ax, ay + 8), 2.5, paint);
      
      // Cross mark (failing to restart) overlay
      paint.color = Colors.red[900]!;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4;
      double crossProg = (progress * 2).clamp(0.0, 1.0);
      if (crossProg > 0) {
        canvas.drawLine(
          Offset(ax - 25, ay - 25), 
          Offset(ax - 25 + (50 * crossProg), ay - 25 + (50 * crossProg)), 
          paint
        );
        canvas.drawLine(
          Offset(ax + 25, ay - 25), 
          Offset(ax + 25 - (50 * crossProg), ay - 25 + (50 * crossProg)), 
          paint
        );
      }
    } else {
      paint.color = organ.highlightColor.withAlpha(200);
      canvas.drawCircle(Offset(x, y), 25, paint);
    }
    
    String labelText = organ.name;
    if (language == 'te') labelText = organ.nameTe;
    else if (language == 'hi') labelText = organ.nameHi;
    else if (language == 'kn') labelText = organ.nameKn;
    else if (language == 'ta') labelText = organ.nameTa;
    else if (language == 'mr') labelText = organ.nameMr;
    else if (language == 'bn') labelText = organ.nameBn;
    
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
