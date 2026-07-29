import 'package:flutter/material.dart';

class MechanismStep {
  final String titleKey;
  final IconData icon;
  final String organTargetId; 
  final String animationTrigger;

  const MechanismStep({
    required this.titleKey,
    required this.icon,
    required this.organTargetId,
    required this.animationTrigger,
  });

  factory MechanismStep.fromJson(Map<String, dynamic> json) {
    return MechanismStep(
      titleKey: json['titleKey'] ?? '',
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      organTargetId: json['organTargetId'] ?? '',
      animationTrigger: json['animationTrigger'] ?? '',
    );
  }
}

class OrganTarget {
  final String id;
  final String name;
  final Offset normalizedPosition; 
  final Color highlightColor;
  final String effectType; 

  const OrganTarget({
    required this.id,
    required this.name,
    required this.normalizedPosition,
    required this.highlightColor,
    this.effectType = 'pulse',
  });

  factory OrganTarget.fromJson(Map<String, dynamic> json) {
    return OrganTarget(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      normalizedPosition: Offset(
        (json['normalizedPosition']['dx'] as num).toDouble(),
        (json['normalizedPosition']['dy'] as num).toDouble(),
      ),
      highlightColor: Color(json['highlightColor'] as int),
      effectType: json['effectType'] ?? 'pulse',
    );
  }
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

  factory AnimationPath.fromJson(Map<String, dynamic> json) {
    return AnimationPath(
      id: json['id'] ?? '',
      startNormalized: Offset(
        (json['startNormalized']['dx'] as num).toDouble(),
        (json['startNormalized']['dy'] as num).toDouble(),
      ),
      endNormalized: Offset(
        (json['endNormalized']['dx'] as num).toDouble(),
        (json['endNormalized']['dy'] as num).toDouble(),
      ),
      color: Color(json['color'] as int),
      style: json['style'] ?? 'particles',
    );
  }
}

class AnatomyAnimationConfig {
  final List<MechanismStep> storyboardSteps;
  final List<OrganTarget> organTargets;
  final List<AnimationPath> animationPaths;
  final Map<int, List<String>> narrationSyncPoints;
  final String outcomeTextKey;
  final Color outcomeColor;

  const AnatomyAnimationConfig({
    required this.storyboardSteps,
    this.organTargets = const [],
    this.animationPaths = const [],
    this.narrationSyncPoints = const {},
    this.outcomeTextKey = '',
    this.outcomeColor = Colors.transparent,
  });

  factory AnatomyAnimationConfig.fromJson(Map<String, dynamic> json) {
    return AnatomyAnimationConfig(
      storyboardSteps: (json['storyboardSteps'] as List? ?? [])
          .map((e) => MechanismStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      organTargets: (json['organTargets'] as List? ?? [])
          .map((e) => OrganTarget.fromJson(e as Map<String, dynamic>))
          .toList(),
      animationPaths: (json['animationPaths'] as List? ?? [])
          .map((e) => AnimationPath.fromJson(e as Map<String, dynamic>))
          .toList(),
      narrationSyncPoints: (json['narrationSyncPoints'] as Map? ?? {}).map(
        (k, v) => MapEntry(int.parse(k.toString()), List<String>.from(v)),
      ),
      outcomeTextKey: json['outcomeTextKey'] ?? '',
      outcomeColor: Color(json['outcomeColor'] as int),
    );
  }
}

class McqQuestion {
  final String id;
  final String questionKey;
  final String optionsKey;
  final int correctIndex;

  const McqQuestion({
    required this.id,
    required this.questionKey,
    required this.optionsKey,
    required this.correctIndex,
  });

  factory McqQuestion.fromJson(Map<String, dynamic> json) {
    return McqQuestion(
      id: json['id'] ?? '',
      questionKey: json['questionKey'] ?? '',
      optionsKey: json['optionsKey'] ?? '',
      correctIndex: json['correctIndex'] as int? ?? 0,
    );
  }
}

class StudyDrug {
  final String drugId;
  final String nameKey;
  final String doseKey;
  final String routeKey;
  final String frequencyKey;
  final String purposeKey;
  final String bodySystem;
  final String plainLanguageKey;
  final bool isNonObvious;
  final AnatomyAnimationConfig anatomyConfig;
  final List<McqQuestion> questions;

  const StudyDrug({
    required this.drugId,
    required this.nameKey,
    required this.doseKey,
    required this.routeKey,
    required this.frequencyKey,
    required this.purposeKey,
    required this.bodySystem,
    required this.plainLanguageKey,
    required this.isNonObvious,
    required this.anatomyConfig,
    required this.questions,
  });

  factory StudyDrug.fromJson(Map<String, dynamic> json) {
    return StudyDrug(
      drugId: json['drugId'] ?? '',
      nameKey: json['nameKey'] ?? '',
      doseKey: json['doseKey'] ?? '',
      routeKey: json['routeKey'] ?? '',
      frequencyKey: json['frequencyKey'] ?? '',
      purposeKey: json['purposeKey'] ?? '',
      bodySystem: json['bodySystem'] ?? '',
      plainLanguageKey: json['plainLanguageKey'] ?? '',
      isNonObvious: json['isNonObvious'] as bool? ?? false,
      anatomyConfig: AnatomyAnimationConfig.fromJson(
          json['anatomyConfig'] as Map<String, dynamic>),
      questions: (json['questions'] as List? ?? [])
          .map((e) => McqQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
