// lib/i18n/strings.dart
// UI strings for both languages.

const Map<String, Map<String, String>> uiStrings = {
  'en': {
    'app_title': 'My Prescription',
    'medication_of': 'Medication {current} of {total}',
    'what_its_for': 'What this medicine is for',
    'how_to_take': 'How to take it',
    'body_system': 'Where it works in your body',
    'listen': 'Listen',
    'stop': 'Stop',
    'next': 'Next',
    'previous': 'Previous',
    'language': 'Language',
    'done': 'Done',
    'question_prompt': 'Answer these questions about this medicine',
    'q_name': 'What is the name of this medicine?',
    'q_dose': 'How much of this medicine do you take?',
    'q_freq': 'How often do you take this medicine?',
    'q_route': 'How do you take this medicine?',
    'q_purpose': 'What is this medicine for?',
    'submit': 'Submit answer',
    'session_complete': 'All done — thank you',
    'export': 'Export study data',
    'new_session': 'New session',
    'participant_code': 'Participant code',
    'condition': 'Study condition',
    'condition_a': 'Condition A — Enhanced',
    'condition_b': 'Condition B — Plain text',
    'launch': 'Launch',
    'drug': 'Medicine',
    'dose_label': 'Dose',
    'route_label': 'How to take',
    'frequency_label': 'How often',
    'purpose_label': 'What it is for',
  },
  'te': {
    'app_title': 'నా ప్రిస్క్రిప్షన్',
    'medication_of': 'మందు {current} / {total}',
    'what_its_for': 'ఈ మందు దేనికి వాడతారు',
    'how_to_take': 'ఎలా వాడాలి',
    'body_system': 'ఇది మీ శరీరంలో ఎక్కడ పని చేస్తుంది',
    'listen': 'వినండి',
    'stop': 'ఆపండి',
    'next': 'తదుపరి',
    'previous': 'వెనక్కి',
    'language': 'భాష',
    'done': 'పూర్తయింది',
    'question_prompt': 'ఈ మందు గురించి ఈ ప్రశ్నలకు సమాధానం ఇవ్వండి',
    'q_name': 'ఈ మందు పేరు ఏమిటి?',
    'q_dose': 'మీరు ఎంత మోతాదు తీసుకుంటారు?',
    'q_freq': 'మీరు ఈ మందు ఎంత తరచుగా తీసుకుంటారు?',
    'q_route': 'మీరు ఈ మందు ఎలా తీసుకుంటారు?',
    'q_purpose': 'ఈ మందు దేనికి వాడతారు?',
    'submit': 'సమాధానం ఇవ్వండి',
    'session_complete': 'అన్నీ పూర్తయ్యాయి — ధన్యవాదాలు',
    'export': 'స్టడీ డేటా ఎగుమతి చేయండి',
    'new_session': 'కొత్త సెషన్',
    'participant_code': 'పాల్గొనేవారి కోడ్',
    'condition': 'స్టడీ కండిషన్',
    'condition_a': 'కండిషన్ A — మెరుగైనది',
    'condition_b': 'కండిషన్ B — సాదా వచనం',
    'launch': 'ప్రారంభించండి',
    'drug': 'మందు',
    'dose_label': 'మోతాదు',
    'route_label': 'ఎలా వాడాలి',
    'frequency_label': 'ఎంత తరచుగా',
    'purpose_label': 'దేనికి వాడతారు',
  },
};

String getString(String key, String lang, {Map<String, String>? replace}) {
  String s = uiStrings[lang]?[key] ?? uiStrings['en']?[key] ?? key;
  if (replace != null) {
    replace.forEach((k, v) => s = s.replaceAll('{$k}', v));
  }
  return s;
}
