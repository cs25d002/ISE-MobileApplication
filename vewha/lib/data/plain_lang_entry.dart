// lib/data/plain_lang_entry.dart

class PlainLangEntry {
  final String whatItIsFor;
  final String howToTake;
  final String audioText;
  final List<String> mechanismSteps;
  final List<String> pictograms;

  const PlainLangEntry({
    required this.whatItIsFor,
    required this.howToTake,
    required this.audioText,
    required this.mechanismSteps,
    required this.pictograms,
  });

  factory PlainLangEntry.fromJson(Map<String, dynamic> json) {
    return PlainLangEntry(
      whatItIsFor: json['whatItIsFor'] as String,
      howToTake: json['howToTake'] as String,
      audioText: json['audioText'] as String,
      mechanismSteps: List<String>.from(json['mechanismSteps']),
      pictograms: List<String>.from(json['pictograms']),
    );
  }
}
