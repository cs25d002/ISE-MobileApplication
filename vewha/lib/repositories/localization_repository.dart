import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationRepository {
  Map<String, dynamic> _localizedData = {};
  String _currentLang = 'en';

  Future<void> loadLanguage(String langCode) async {
    try {
      final jsonString = await rootBundle.loadString('assets/i18n/$langCode.json');
      _localizedData = jsonDecode(jsonString) as Map<String, dynamic>;
      _currentLang = langCode;
    } catch (e) {
      print('Error loading language $langCode: $e');
      // Fallback to english if available
      if (langCode != 'en') {
        await loadLanguage('en');
      }
    }
  }

  String translate(String key, {Map<String, String>? params}) {
    String text = _localizedData[key]?.toString() ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }
  
  List<String> translateList(String key) {
    if (_localizedData[key] is List) {
      return (_localizedData[key] as List).map((e) => e.toString()).toList();
    }
    return [];
  }
  
  String get currentLanguage => _currentLang;
}
