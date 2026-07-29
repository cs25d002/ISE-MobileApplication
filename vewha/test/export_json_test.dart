import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:Vewha/data/prescriptions.dart';
import 'package:Vewha/data/anatomy_config.dart';

void main() {
  test('export json', () {
    List<Map<String, dynamic>> drugsList = [];

    for (var drug in studyDrugs) {
      drugsList.add({
        'drugId': drug.drugId,
        'name': drug.name,
        'nameTe': drug.nameTe,
        'nameHi': drug.nameHi,
        'dose': drug.dose,
        'doseTe': drug.doseTe,
        'doseHi': drug.doseHi,
        'route': drug.route,
        'routeTe': drug.routeTe,
        'routeHi': drug.routeHi,
        'frequency': drug.frequency,
        'frequencyTe': drug.frequencyTe,
        'frequencyHi': drug.frequencyHi,
        'purpose': drug.purpose,
        'purposeTe': drug.purposeTe,
        'purposeHi': drug.purposeHi,
        'bodySystem': drug.bodySystem.toString().split('.').last,
        'plainLanguageKey': drug.plainLanguageKey,
        'isNonObvious': drug.isNonObvious,
        'anatomyConfig': {
          'storyboardSteps': drug.anatomyConfig.storyboardSteps.map((step) => {
            'titleEn': step.titleEn,
            'titleTe': step.titleTe,
            'titleHi': step.titleHi,
            'icon': step.icon.codePoint,
            'organTargetId': step.organTargetId,
            'animationTrigger': step.animationTrigger,
          }).toList(),
          'organTargets': drug.anatomyConfig.organTargets.map((organ) => {
            'id': organ.id,
            'name': organ.name,
            'nameTe': organ.nameTe,
            'nameHi': organ.nameHi,
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
          'outcomeTextTe': drug.anatomyConfig.outcomeTextTe,
          'outcomeTextHi': drug.anatomyConfig.outcomeTextHi,
          'outcomeColor': drug.anatomyConfig.outcomeColor.value,
        },
        'questions': drug.questions.map((q) => {
          'id': q.id,
          'questionEn': q.questionEn,
          'questionTe': q.questionTe,
          'questionHi': q.questionHi,
          'optionsEn': q.optionsEn,
          'optionsTe': q.optionsTe,
          'optionsHi': q.optionsHi,
          'correctIndex': q.correctIndex,
        }).toList(),
      });
    }

    final dir = Directory('assets/data');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final file = File('assets/data/prescriptions.json');
    file.writeAsStringSync(jsonEncode(drugsList));
    print('Successfully exported to assets/data/prescriptions.json');
  });
}
