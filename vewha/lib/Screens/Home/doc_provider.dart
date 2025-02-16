import 'package:flutter/material.dart';

class DocIDProvider extends ChangeNotifier {
  String? _docID;

  String? get docID => _docID;

  void setDocID(String id) {
    _docID = id;
    notifyListeners();
  }
}
