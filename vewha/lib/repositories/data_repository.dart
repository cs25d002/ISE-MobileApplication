import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/study_drug.dart';

import 'package:flutter/foundation.dart';

List<dynamic> _parseJson(String jsonString) {
  return jsonDecode(jsonString) as List<dynamic>;
}

class DataRepository {
  List<StudyDrug> _studyDrugs = [];
  bool _isLoaded = false;

  Future<void> init() async {
    if (_isLoaded) return;
    
    final jsonString = await rootBundle.loadString('assets/data/prescriptions.json');
    final List<dynamic> jsonList = await compute(_parseJson, jsonString);
    
    _studyDrugs = jsonList.map((e) => StudyDrug.fromJson(e as Map<String, dynamic>)).toList();
    _isLoaded = true;
  }

  List<StudyDrug> get studyDrugs {
    if (!_isLoaded) {
      throw StateError('DataRepository not initialized. Call init() first.');
    }
    return _studyDrugs;
  }

  StudyDrug getDrugById(String id) {
    return studyDrugs.firstWhere((drug) => drug.drugId == id, 
      orElse: () => throw ArgumentError('Drug not found: $id'));
  }
}
