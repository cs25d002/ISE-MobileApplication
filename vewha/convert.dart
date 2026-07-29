import 'dart:convert';
import 'dart:io';
import 'lib/data/plain_language_map.dart';

void main() {
  final languages = ['en', 'te', 'hi', 'kn', 'ta', 'mr', 'bn'];
  final outputDir = Directory('assets/i18n');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  for (final lang in languages) {
    final Map<String, dynamic> langData = {};
    for (final entry in plainLanguageMap.entries) {
      final drugId = entry.key;
      final drugLangs = entry.value;
      if (drugLangs.containsKey(lang)) {
        final data = drugLangs[lang]!;
        langData[drugId] = {
          'whatItIsFor': data.whatItIsFor,
          'howToTake': data.howToTake,
          'audioText': data.audioText,
          'mechanismSteps': data.mechanismSteps,
          'pictograms': data.pictograms,
        };
      }
    }
    
    final file = File('${outputDir.path}/$lang.json');
    file.writeAsStringSync(jsonEncode(langData));
    print('Wrote $lang.json');
  }
}
