import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../data/plain_lang_entry.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Map<String, Map<String, PlainLangEntry>> _cache = {};

  // Medical Glossary for context-aware translations.
  // Instead of literal "Sugar", replace with "Diabetes" terminology context where applicable.
  
  final Map<String, Map<String, String>> _glossary = {
    'en': {
      'sugar': 'blood sugar',
      'bp': 'blood pressure',
    },
    'te': {
      'చెక్కర': 'మధుమేహం (Diabetes)', 
      'బీపీ': 'రక్తపోటు',
    },
    'hi': {
      'चीनी': 'मधुमेह (Diabetes)',
      'बीपी': 'रक्तचाप',
    },
    'kn': {
      'ಸಕ್ಕರೆ': 'ಮಧುಮೇಹ (Diabetes)',
      'ಬಿಪಿ': 'ರಕ್ತದೊತ್ತಡ',
    },
    'ta': {
      'சர்க்கரை': 'நீரிழிவு (Diabetes)',
      'பிபி': 'இரத்த அழுத்தம்',
    },
    'mr': {
      'साखर': 'मधुमेह (Diabetes)',
      'बीपी': 'रक्तदाब',
    },
    'bn': {
      'চিনি': 'ডায়াবেটিস (Diabetes)',
      'বিপি': 'রক্তচাপ',
    },
  };

  Future<void> loadLanguage(String lang) async {
    print('TRANS: loadLanguage($lang) called. cache contains? ${_cache.containsKey(lang)}');
    if (_cache.containsKey(lang)) return;

    try {
      print('TRANS: loading from rootBundle...');
      final jsonString = await rootBundle.loadString('assets/i18n/$lang.json');
      print('TRANS: decode json...');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      final Map<String, PlainLangEntry> entries = {};
      for (var key in jsonMap.keys) {
        final val = jsonMap[key];
        if (val is Map<String, dynamic> && val.containsKey('whatItIsFor')) {
          entries[key] = PlainLangEntry.fromJson(val);
        }
      }
      
      _cache[lang] = entries;
    } catch (e) {
      debugPrint('Error loading language $lang: $e');
      // If a language fails, attempt to fallback load English if not already loaded
      if (lang != 'en' && !_cache.containsKey('en')) {
        await loadLanguage('en');
      }
    }
  }

  PlainLangEntry? getEntry(String drugKey, String lang) {
    PlainLangEntry? entry;
    
    if (_cache.containsKey(lang)) {
      entry = _cache[lang]![drugKey];
    }
    
    // Fallback to English if translation is missing or language failed to load
    if (entry == null && lang != 'en' && _cache.containsKey('en')) {
      entry = _cache['en']![drugKey];
    }

    if (entry == null) return null;

    return _applyGlossary(entry, lang);
  }

  PlainLangEntry _applyGlossary(PlainLangEntry entry, String lang) {
    final glossary = _glossary[lang];
    if (glossary == null) return entry;

    String processText(String text) {
      String processed = text;
      glossary.forEach((key, value) {
        // Simple case-insensitive replace for demonstration. 
        // TODO, use word boundaries.
        processed = processed.replaceAll(RegExp(key, caseSensitive: false), value);
      });
      return processed;
    }

    return PlainLangEntry(
      whatItIsFor: processText(entry.whatItIsFor),
      howToTake: processText(entry.howToTake),
      audioText: processText(entry.audioText),
      mechanismSteps: entry.mechanismSteps.map(processText).toList(),
      pictograms: entry.pictograms, // Keep identifiers unchanged
    );
  }

  /// TODO implement lru rather than complete flush 
  
  void clearCache() {
    _cache.clear();
  }
}
