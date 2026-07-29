import 'dart:convert';
import 'dart:io';
import 'package:Vewha/data/prescriptions.dart';
import 'package:Vewha/data/anatomy_config.dart';

void main() {
  List<Map<String, dynamic>> drugsList = [];

  for (var drug in studyDrugs) {
    drugsList.add({
      'drugId': drug.drugId,
      'name': drug.name,
      'dose': drug.dose,
      'route': drug.route,
      'frequency': drug.frequency,
      'purpose': drug.purpose,
      'bodySystem': drug.bodySystem.toString().split('.').last,
      'plainLanguageKey': drug.plainLanguageKey,
      'isNonObvious': drug.isNonObvious,
      'anatomyConfig': {
        'storyboardSteps': drug.anatomyConfig.storyboardSteps.map((step) => {
          'title': step.titleEn,
          'icon': step.icon.codePoint,
          'organTargetId': step.organTargetId,
          'animationTrigger': step.animationTrigger,
        }).toList(),
        'organTargets': drug.anatomyConfig.organTargets.map((organ) => {
          'id': organ.id,
          'name': organ.name,
          'normalizedPosition': {'dx': organ.normalizedPosition.dx, 'dy': organ.normalizedPosition.dy},
          'highlightColor': organ.highlightColor.value,
          'effectType': organ.effectType,
        }).toList(),
        'animationPaths': drug.anatomyConfig.animationPaths.map((path) => {
          'id': path.id,
          'startNormalized': {'dx': path.startNormalized.dx, 'dy': path.startNormalized.dy},
          'endNormalized': {'dx': path.endNormalized.dx, 'dy': path.endNormalized.dy},
          'color': path.color.value,
          'style': path.style,
        }).toList(),
        'narrationSyncPoints': drug.anatomyConfig.narrationSyncPoints.map((k, v) => MapEntry(k.toString(), v)),
        'outcomeText': drug.anatomyConfig.outcomeText,
        'outcomeColor': drug.anatomyConfig.outcomeColor.value,
      },
      'questions': drug.questions.map((q) => {
        'id': q.id,
        'question': q.questionEn,
        'options': q.optionsEn,
        'correctIndex': q.correctIndex,
      }).toList(),
    });
  }

  // Create the directory if it doesn't exist
  final dir = Directory('assets/data');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Write to prescriptions.json
  final file = File('assets/data/prescriptions.json');
  file.writeAsStringSync(jsonEncode(drugsList));
  print('Successfully exported to assets/data/prescriptions.json');
}
