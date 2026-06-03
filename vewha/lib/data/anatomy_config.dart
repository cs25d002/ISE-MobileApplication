import 'package:flutter/material.dart';

class MechanismStep {
  final String titleEn;
  final String titleTe;
  final String titleHi;
  final IconData icon;
  final String organTargetId; 
  final String animationTrigger;

  const MechanismStep({
    required this.titleEn,
    required this.titleTe,
    required this.titleHi,
    required this.icon,
    required this.organTargetId,
    required this.animationTrigger,
  });
}

class OrganTarget {
  final String id;
  final String name;
  final String nameTe;
  final String nameHi;
  final Offset normalizedPosition; 
  final Color highlightColor;
  final String effectType; 

  const OrganTarget({
    required this.id,
    required this.name,
    required this.nameTe,
    required this.nameHi,
    required this.normalizedPosition,
    required this.highlightColor,
    this.effectType = 'pulse',
  });
}

class AnimationPath {
  final String id;
  final Offset startNormalized;
  final Offset endNormalized;
  final Color color;
  final String style; 

  const AnimationPath({
    required this.id,
    required this.startNormalized,
    required this.endNormalized,
    required this.color,
    this.style = 'particles',
  });
}

class AnatomyAnimationConfig {
  final List<MechanismStep> storyboardSteps;
  final List<OrganTarget> organTargets;
  final List<AnimationPath> animationPaths;
  final Map<int, List<String>> narrationSyncPoints; // step index -> list of target/path IDs
  final String outcomeText;
  final String outcomeTextTe;
  final String outcomeTextHi;
  final Color outcomeColor;

  const AnatomyAnimationConfig({
    required this.storyboardSteps,
    this.organTargets = const [],
    this.animationPaths = const [],
    this.narrationSyncPoints = const {},
    this.outcomeText = '',
    this.outcomeTextTe = '',
    this.outcomeTextHi = '',
    this.outcomeColor = Colors.transparent,
  });
}
