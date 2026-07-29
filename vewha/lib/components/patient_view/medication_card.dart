import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Vewha/models/study_drug.dart';
import '../../repositories/localization_repository.dart';

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
    final loc = context.watch<LocalizationRepository>();

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
            Text(loc.getClinicalEntry(drug.nameKey),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            _row(loc.getUiString('dose'), loc.getClinicalEntry(drug.doseKey)),
            _row(loc.getUiString('route'), loc.getClinicalEntry(drug.routeKey)),
            _row(loc.getUiString('frequency'), loc.getClinicalEntry(drug.frequencyKey)),
            _row(loc.getUiString('purpose'), loc.getClinicalEntry(drug.purposeKey)),
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
