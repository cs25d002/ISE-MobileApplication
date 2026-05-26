import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/prescriptions.dart';

import '../../logging/performance_tracker.dart';

class AnatomyViewer extends StatefulWidget {
  final BodySystem bodySystem;
  final double height;

  const AnatomyViewer({
    super.key,
    required this.bodySystem,
    this.height = 280,
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
    PatientModuleRegistry.isSvgInitialized = true;
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.bodySystem) {
      case BodySystem.endocrine:      return 'assets/anatomy/endocrine.svg';
      case BodySystem.respiratory:    return 'assets/anatomy/respiratory.svg';
      case BodySystem.integumentary:  return 'assets/anatomy/integumentary.svg';
      case BodySystem.cardiovascular: return 'assets/anatomy/cardiovascular.svg';
      case BodySystem.systemic:       return 'assets/anatomy/systemic.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: SvgPicture.asset(
        _assetPath,
        height: widget.height,
        semanticsLabel: 'Body diagram showing affected area',
      ),
    );
  }
}
