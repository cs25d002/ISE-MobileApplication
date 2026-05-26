import 'package:flutter/material.dart';
import '../../data/prescriptions.dart';

class MedicationCard extends StatelessWidget {
  final StudyDrug drug;
  final String language;

  const MedicationCard({
    super.key,
    required this.drug,
    this.language = 'en',
  });

  @override
  Widget build(BuildContext context) {
    String name = drug.name;
    String dose = drug.dose;
    String route = drug.route;
    String freq = drug.frequency;
    String purpose = drug.purpose;
    String lDose = 'Dose';
    String lRoute = 'Route';
    String lFreq = 'How often';
    String lPurp = 'Purpose';

    if (language == 'te') {
      name = drug.nameTe;
      dose = drug.doseTe;
      route = drug.routeTe;
      freq = drug.frequencyTe;
      purpose = drug.purposeTe;
      lDose = 'మోతాదు';
      lRoute = 'ఎలా వాడాలి';
      lFreq = 'ఎంత తరచుగా';
      lPurp = 'దేనికి వాడతారు';
    } else if (language == 'hi') {
      name = drug.nameHi;
      dose = drug.doseHi;
      route = drug.routeHi;
      freq = drug.frequencyHi;
      purpose = drug.purposeHi;
      lDose = 'खुराक';
      lRoute = 'उपयोग का तरीका';
      lFreq = 'कितनी बार';
      lPurp = 'उद्देश्य';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            _row(lDose, dose),
            _row(lRoute, route),
            _row(lFreq, freq),
            _row(lPurp, purpose),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90,
            child: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w500))),
          Expanded(
            child: Text(value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)))),
        ],
      ),
    );
  }
}
