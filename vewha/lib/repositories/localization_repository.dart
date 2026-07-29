import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationRepository {
  Map<String, dynamic> _uiData = {};
  Map<String, dynamic> _clinicalData = {};
  
  Map<String, dynamic> _fallbackUiData = {};
  Map<String, dynamic> _fallbackClinicalData = {};
  
  String _currentLang = 'en';

  Future<void> init() async {
    await _loadFallbackLanguage();
    await loadLanguage('en'); // Default to english on start
  }

  Future<void> _loadFallbackLanguage() async {
    try {
      final uiJson = await rootBundle.loadString('assets/i18n/ui_en.json');
      _fallbackUiData = jsonDecode(uiJson) as Map<String, dynamic>;
      
      final clinicalJson = await rootBundle.loadString('assets/i18n/en.json');
      _fallbackClinicalData = jsonDecode(clinicalJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading fallback English language: $e');
    }
  }

  Future<void> loadLanguage(String langCode) async {
    try {
      final uiJson = await rootBundle.loadString('assets/i18n/ui_$langCode.json');
      _uiData = jsonDecode(uiJson) as Map<String, dynamic>;
      
      final clinicalJson = await rootBundle.loadString('assets/i18n/$langCode.json');
      _clinicalData = jsonDecode(clinicalJson) as Map<String, dynamic>;
      
      _currentLang = langCode;
    } catch (e) {
      print('Error loading language $langCode: $e');
      if (langCode != 'en') {
        await loadLanguage('en');
      }
    }
  }

  String _formatKey(String key) {
    if (key.isEmpty) return key;
    return key.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String getUiString(String key, {Map<String, String>? params}) {
    String text = _uiData[key]?.toString() ?? _fallbackUiData[key]?.toString() ?? _formatKey(key);
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }

  String getClinicalEntry(String drugKey) {
    return _clinicalData[drugKey]?.toString() ?? _fallbackClinicalData[drugKey]?.toString() ?? _formatKey(drugKey);
  }

  String getQuizString(String questionKey) {
    return _clinicalData[questionKey]?.toString() ?? _fallbackClinicalData[questionKey]?.toString() ?? _formatKey(questionKey);
  }
  
  List<String> getQuizStringList(String key) {
    if (_clinicalData.containsKey(key) && _clinicalData[key] is List) {
      return (_clinicalData[key] as List).map((e) => e.toString()).toList();
    }
    if (_fallbackClinicalData.containsKey(key) && _fallbackClinicalData[key] is List) {
      return (_fallbackClinicalData[key] as List).map((e) => e.toString()).toList();
    }
    return [];
  }
  
  String get currentLanguage => _currentLang;
}
