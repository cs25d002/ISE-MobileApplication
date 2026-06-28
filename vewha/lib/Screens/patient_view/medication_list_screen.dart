import 'package:flutter/material.dart';
import 'package:Vewha/data/prescriptions.dart' hide Colors;
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

  String _t(String en, String te, String hi, String kn, String ta, String mr, String bn) {
    if (widget.language == 'hi') return hi;
    if (widget.language == 'te') return te;
    if (widget.language == 'kn') return kn;
    if (widget.language == 'ta') return ta;
    if (widget.language == 'mr') return mr;
    if (widget.language == 'bn') return bn;
    return en;
  }

  void _go(int index) {
    if (index < 0 || index >= studyDrugs.length) return;
    setState(() => _current = index);
  }

  void _openDetail() {
    final drug = studyDrugs[_current];
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
    final drug = studyDrugs[_current];
    final isTe = widget.language == 'te';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _t('Medication ${_current + 1} of ${studyDrugs.length}', 'మందు ${_current + 1} / ${studyDrugs.length}', 'दवा ${_current + 1} / ${studyDrugs.length}', 'ಔಷಧಿ ${_current + 1} / ${studyDrugs.length}', 'மருந்து ${_current + 1} / ${studyDrugs.length}', 'औषध ${_current + 1} / ${studyDrugs.length}', 'ওষুধ ${_current + 1} / ${studyDrugs.length}'),
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
              onTap: _go,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              ),
              child: InkWell(
                onTap: _openDetail,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(drug.name, drug.nameTe, drug.nameHi, drug.nameKn, drug.nameTa, drug.nameMr, drug.nameBn),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _t(drug.purpose, drug.purposeTe, drug.purposeHi, drug.purposeKn, drug.purposeTa, drug.purposeMr, drug.purposeBn),
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
                            _t('Tap to view details', 'వివరాలను చూడటానికి నొక్కండి', 'विवरण देखने के लिए टैप करें', 'ವಿವರಗಳನ್ನು ನೋಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ', 'விவரங்களைக் காண தட்டவும்', 'तपशील पाहण्यासाठी टॅप करा', 'বিবরণ দেখতে ট্যাপ করুন'),
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
                      onPressed: () => _go(_current - 1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1D9E75), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _t('Previous', 'వెనక్కి', 'पिछला', 'ಹಿಂದಿನ', 'முந்தைய', 'मागील', 'আগের'),
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
                      onPressed: () => _go(_current + 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _t('Next', 'తదుపరి', 'अगला', 'ಮುಂದಿನ', 'அடுத்த', 'पुढील', 'পরবর্তী'),
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
                        _t('Done', 'పూర్తయింది', 'हो गया', 'ಮುಗಿದಿದೆ', 'முடிந்தது', 'पूर्ण झाले', 'হয়ে গেছে'),
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
