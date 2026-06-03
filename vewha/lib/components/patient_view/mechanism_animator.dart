// lib/components/patient_view/mechanism_animator.dart
// Visual-first interactive drug mechanism storyboard animator.
// Renders dynamic MechanismSteps with icons and flow indicators.
// Helps fully illiterate patients understand how their medicine works in the body.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/anatomy_config.dart';

class MechanismAnimator extends StatefulWidget {
  final List<String> steps;
  final String language; // 'en', 'te', 'hi'
  final Color accentColor;
  final ValueNotifier<int>? activeStepNotifier;
  final List<MechanismStep> storyboardSteps;

  const MechanismAnimator({
    super.key,
    required this.steps,
    required this.language,
    required this.storyboardSteps,
    this.accentColor = const Color(0xFF1D9E75),
    this.activeStepNotifier,
  });

  @override
  State<MechanismAnimator> createState() => _MechanismAnimatorState();
}

class _MechanismAnimatorState extends State<MechanismAnimator> with SingleTickerProviderStateMixin {
  int _visibleCount = 0;
  Timer? _timer;
  bool _completed = false;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.activeStepNotifier != null) {
      widget.activeStepNotifier!.addListener(_onStepNotifierChanged);
      _onStepNotifierChanged();
    } else {
      _startAnimation();
    }
  }

  void _onStepNotifierChanged() {
    final step = widget.activeStepNotifier!.value;
    if (step < 0) {
      setState(() {
        _visibleCount = 0;
        _completed = false;
        _progressController.reset();
      });
    } else {
      setState(() {
        _visibleCount = step + 1; // 0-based step, 1-based visible count
        if (_visibleCount >= widget.steps.length) {
          _completed = true;
          _progressController.value = 1.0;
        } else {
          _completed = false;
          _progressController.forward(from: 0.0);
        }
      });
    }
  }

  void _startAnimation() {
    _visibleCount = 0;
    _completed = false;
    _progressController.reset();
    _timer?.cancel();
    
    setState(() => _visibleCount = 1);
    _progressController.forward(from: 0.0);
    
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_visibleCount < widget.steps.length) {
        setState(() => _visibleCount++);
        _progressController.forward(from: 0.0);
      } else {
        t.cancel();
        if (mounted) setState(() {
          _completed = true;
          _progressController.value = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    if (widget.activeStepNotifier != null) {
      widget.activeStepNotifier!.removeListener(_onStepNotifierChanged);
    }
    super.dispose();
  }

  String _tStep(MechanismStep step) {
    if (widget.language == 'hi') return step.titleHi;
    if (widget.language == 'te') return step.titleTe;
    return step.titleEn;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.biotech_outlined, size: 18, color: widget.accentColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                widget.language == 'te'
                    ? 'మందు పని చేసే విధానం'
                    : widget.language == 'hi'
                        ? 'दवा काम करने का तरीका'
                        : 'How this medicine works',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.accentColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_completed)
              GestureDetector(
                onTap: _startAnimation,
                child: Row(
                  children: [
                    Icon(Icons.replay, size: 16, color: widget.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      widget.language == 'te' ? 'మళ్లీ చూడండి' : widget.language == 'hi' ? 'फिर से देखें' : 'Replay',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Visual Storyboard Timeline
        if (widget.storyboardSteps.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EFEA)),
            ),
            child: Row(
              children: List.generate(widget.storyboardSteps.length, (index) {
                final isActive = index < _visibleCount;
                final isCurrent = index == _visibleCount - 1 && !_completed;
                final stepConfig = widget.storyboardSteps[index];

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isActive ? widget.accentColor : const Color(0xFFE0E0E0),
                                shape: BoxShape.circle,
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: widget.accentColor.withAlpha((0.4 * 255).round()),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  stepConfig.icon,
                                  color: isActive ? Colors.white : const Color(0xFF888888),
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _tStep(stepConfig),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isActive ? const Color(0xFF1A1A2E) : const Color(0xFF888888),
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      
                      // Solid Connecting Progress Bar
                      if (index < widget.storyboardSteps.length - 1)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20), // Align with icons, ignoring text height
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E0E0),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: index < _visibleCount - 1
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: widget.accentColor,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        )
                                      : (index == _visibleCount - 1 && !_completed)
                                          ? AnimatedBuilder(
                                              animation: _progressController,
                                              builder: (context, child) {
                                                return Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    width: constraints.maxWidth * _progressController.value,
                                                    decoration: BoxDecoration(
                                                      color: widget.accentColor,
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : const SizedBox.shrink(),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        const SizedBox(height: 18),

        // Text Step sequence
        ...List.generate(widget.steps.length, (i) {
          final isVisible = i < _visibleCount;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isVisible ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              offset: isVisible ? Offset.zero : const Offset(0, 0.15),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(right: 10, top: 1),
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.steps[i],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF333333),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        if (!_completed) ...[
          const SizedBox(height: 4),
          Row(
            children: List.generate(widget.steps.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: i < _visibleCount ? 20 : 8,
                height: 6,
                decoration: BoxDecoration(
                  color: i < _visibleCount
                      ? widget.accentColor
                      : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
