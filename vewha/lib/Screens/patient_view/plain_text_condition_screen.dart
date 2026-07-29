// Condition B control screen — plain clinical table, no visuals, no audio.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Vewha/models/study_drug.dart';
import '../../repositories/localization_repository.dart';
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
    final loc = context.watch<LocalizationRepository>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.getUiString('prescription'),
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
                // Also update the repository
                loc.loadLanguage(newValue).then((_) {
                  if (mounted) setState(() {});
                });
              }
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'te', child: Text('తెలుగు')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
              DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
              DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
              DropdownMenuItem(value: 'mr', child: Text('मराठी')),
              DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
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
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1.5, borderRadius: BorderRadius.circular(8)),
                  columnWidths: const {0: FixedColumnWidth(110), 1: FlexColumnWidth()},
                  children: [
                    _headerRow(loc.getUiString('field'), loc.getUiString('details')),
                    _dataRow(loc.getUiString('medicine'), loc.getClinicalEntry(d.nameKey)),
                    _dataRow(loc.getUiString('dose'), loc.getClinicalEntry(d.doseKey)),
                    _dataRow(loc.getUiString('route'), loc.getClinicalEntry(d.routeKey)),
                    _dataRow(loc.getUiString('frequency'), loc.getClinicalEntry(d.frequencyKey)),
                    _dataRow(loc.getUiString('purpose'), loc.getClinicalEntry(d.purposeKey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  loc.getUiString('answer_questions'),
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
