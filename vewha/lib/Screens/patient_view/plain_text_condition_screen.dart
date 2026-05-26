// Condition B control screen — plain clinical table, no visuals, no audio.
import 'package:flutter/material.dart';
import '../../data/prescriptions.dart';
import 'comprehension_screen.dart';

class PlainTextConditionScreen extends StatefulWidget {
  final StudyDrug drug;
  final String initialLanguage;

  const PlainTextConditionScreen({
    super.key,
    required this.drug,
    this.initialLanguage = 'en',
  });

  @override
  State<PlainTextConditionScreen> createState() => _PlainTextConditionScreenState();
}

class _PlainTextConditionScreenState extends State<PlainTextConditionScreen> {
  late final DateTime _screenOpenTime;
  String _lang = 'en';

  String _t(String en, String te, String hi) {
    if (_lang == 'hi') return hi;
    if (_lang == 'te') return te;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _lang = widget.initialLanguage;
    _screenOpenTime = DateTime.now();
  }

  void _openComprehension() {
    final elapsed = DateTime.now().difference(_screenOpenTime).inMilliseconds;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ComprehensionScreen(
        drug: widget.drug,
        timeOnScreenMs: elapsed,
        audioPlayed: false,
        language: _lang,
        showVisuals: false,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.drug;
    final isTe = _lang == 'te';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _t('Prescription', 'ప్రిస్క్రిప్షన్', 'नुस्खा'),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF555555)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          DropdownButton<String>(
            value: _lang,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Color(0xFF1D9E75)),
            style: const TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.bold, fontSize: 16),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _lang = newValue);
              }
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1.5, borderRadius: BorderRadius.circular(8)),
              columnWidths: const {0: FixedColumnWidth(110), 1: FlexColumnWidth()},
              children: [
                _headerRow(_t('Field', 'ఫీల్డ్', 'क्षेत्र'), _t('Details', 'వివరాలు', 'विवरण')),
                _dataRow(_t('Medicine', 'మందు', 'दवा'), _t(d.name, d.nameTe, d.nameHi)),
                _dataRow(_t('Dose', 'మోతాదు', 'खुराक'), _t(d.dose, d.doseTe, d.doseHi)),
                _dataRow(_t('Route', 'ఎలా వాడాలి', 'उपयोग का तरीका'), _t(d.route, d.routeTe, d.routeHi)),
                _dataRow(_t('Frequency', 'ఎంత తరచుగా', 'कितनी बार'), _t(d.frequency, d.frequencyTe, d.frequencyHi)),
                _dataRow(_t('Purpose', 'దేనికి వాడతారు', 'उद्देश्य'), _t(d.purpose, d.purposeTe, d.purposeHi)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openComprehension,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF534AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text(
                  _t('Answer questions', 'ప్రశ్నలకు సమాధానం ఇవ్వండి', 'सवालों के जवाब दें'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _headerRow(String fieldLabel, String detailsLabel) => TableRow(
        decoration: const BoxDecoration(color: Color(0xFF1A1A2E)),
        children: [fieldLabel, detailsLabel]
            .map((h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text(
                    h,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
      );

  TableRow _dataRow(String label, String value) => TableRow(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF555555), fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.4),
          ),
        ),
      ]);
}
