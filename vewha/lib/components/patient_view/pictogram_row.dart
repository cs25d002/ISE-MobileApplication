// lib/components/patient_view/pictogram_row.dart
// Non-verbal icon row for illiterate users.
// Maps pictogram codes to Material icons and short multilingual labels.
// No external assets — uses Flutter Icons only.

import 'package:flutter/material.dart';

class PictogramRow extends StatelessWidget {
  final List<String> codes;
  final String language; // 'en', 'te', 'hi'

  const PictogramRow({
    super.key,
    required this.codes,
    required this.language,
  });

  // ── Icon map ──────────────────────────────────────────────────────────────
  static const Map<String, IconData> _icons = {
    'take_with_food':    Icons.restaurant,
    'take_without_food': Icons.no_meals,
    'twice_daily':       Icons.exposure_plus_2,
    'once_daily':        Icons.looks_one_outlined,
    'as_needed':         Icons.touch_app_outlined,
    'apply_to_skin':     Icons.back_hand_outlined,
    'inhale':            Icons.air,
    'do_not_stop':       Icons.block,
    'morning_and_night': Icons.wb_twilight_outlined,
    'follow_schedule':   Icons.event_note_outlined,
    'wash_hands':        Icons.wash_outlined,
  };

  // ── Label map — three languages ───────────────────────────────────────────
  static const Map<String, Map<String, String>> _labels = {
    'take_with_food': {
      'en': 'With food',
      'te': 'ఆహారంతో',
      'hi': 'खाने के साथ',
    },
    'take_without_food': {
      'en': 'Any time',
      'te': 'ఎప్పుడైనా',
      'hi': 'कभी भी',
    },
    'twice_daily': {
      'en': '2× daily',
      'te': 'రోజు 2×',
      'hi': 'दिन में 2×',
    },
    'once_daily': {
      'en': '1× daily',
      'te': 'రోజు 1×',
      'hi': 'दिन में 1×',
    },
    'as_needed': {
      'en': 'As needed',
      'te': 'అవసరమైతే',
      'hi': 'जरूरत पर',
    },
    'apply_to_skin': {
      'en': 'On skin',
      'te': 'చర్మంపై',
      'hi': 'त्वचा पर',
    },
    'inhale': {
      'en': 'Inhale',
      'te': 'పీల్చాలి',
      'hi': 'सांस लें',
    },
    'do_not_stop': {
      'en': 'Don\'t stop',
      'te': 'ఆపవద్దు',
      'hi': 'बंद न करें',
    },
    'morning_and_night': {
      'en': 'Same time',
      'te': 'ఒకే సమయం',
      'hi': 'एक समय',
    },
    'follow_schedule': {
      'en': 'Follow plan',
      'te': 'షెడ్యూల్',
      'hi': 'शेड्यूल',
    },
    'wash_hands': {
      'en': 'Wash hands',
      'te': 'చేతులు కడగండి',
      'hi': 'हाथ धोएं',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB2EAD7)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 8,
        runSpacing: 8,
        children: codes.map((code) => _buildPictogram(code)).toList(),
      ),
    );
  }

  Widget _buildPictogram(String code) {
    final icon = _icons[code] ?? Icons.help_outline;
    final label = _labels[code]?[language] ?? _labels[code]?['en'] ?? code;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFF1D9E75),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF085041),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
