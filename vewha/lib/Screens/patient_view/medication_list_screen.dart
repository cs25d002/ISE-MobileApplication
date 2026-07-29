import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Vewha/repositories/data_repository.dart';
import 'package:Vewha/repositories/localization_repository.dart';
import '../../components/patient_view/progress_stepper.dart';
import 'medication_detail_screen.dart';
import 'plain_text_condition_screen.dart';

class MedicationListScreen extends StatefulWidget {
  final String condition; // 'A' or 'B'
  final String language;  // 'en' or 'te'

  const MedicationListScreen({
    super.key,
    required this.condition,
    required this.language,
  });

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  int _current = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLang();
  }

  Future<void> _initLang() async {
    final loc = context.read<LocalizationRepository>();
    if (loc.currentLanguage != widget.language) {
      await loc.loadLanguage(widget.language);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _go(int index, int totalLength) {
    if (index < 0 || index >= totalLength) return;
    setState(() => _current = index);
  }

  void _openDetail(dynamic drug) {
    if (widget.condition == 'A') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MedicationDetailScreen(
          drug: drug,
          initialLanguage: widget.language,
        ),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PlainTextConditionScreen(
          drug: drug,
          initialLanguage: widget.language,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dataRepo = context.watch<DataRepository>();
    final loc = context.watch<LocalizationRepository>();
    final studyDrugs = dataRepo.studyDrugs;
    final drug = studyDrugs[_current];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.getUiString('medication_count', params: {'0': '${_current + 1}', '1': '${studyDrugs.length}'}),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF555555)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProgressStepper(
              currentIndex: _current,
              total: studyDrugs.length,
              onTap: (idx) => _go(idx, studyDrugs.length),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              child: InkWell(
                onTap: () => _openDetail(drug),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.getClinicalEntry(drug.nameKey),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.getClinicalEntry(drug.purposeKey),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            loc.getUiString('tap_to_view_details'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1D9E75),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF1D9E75)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                if (_current > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _go(_current - 1, studyDrugs.length),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1D9E75), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        loc.getUiString('previous'),
                        style: const TextStyle(
                          color: Color(0xFF1D9E75),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                if (_current > 0) const SizedBox(width: 16),
                if (_current < studyDrugs.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _go(_current + 1, studyDrugs.length),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        loc.getUiString('next'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                if (_current == studyDrugs.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF534AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        loc.getUiString('done'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
