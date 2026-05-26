import 'package:flutter/material.dart';
import '../../logging/study_logger.dart';
import 'medication_list_screen.dart';

class PatientEntryScreen extends StatefulWidget {
  final String initialCondition;
  const PatientEntryScreen({super.key, this.initialCondition = 'A'});

  @override
  State<PatientEntryScreen> createState() => _PatientEntryScreenState();
}

class _PatientEntryScreenState extends State<PatientEntryScreen> {
  final _codeController = TextEditingController();
  String _condition = 'A';
  String _lang = 'en';

  String _t(String en, String te, String hi) {
    if (_lang == 'hi') return hi;
    if (_lang == 'te') return te;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _condition = widget.initialCondition;
  }

  void _launch() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('Please enter a participant code', 'దయచేసి పాల్గొనేవారి కోడ్‌ను నమోదు చేయండి', 'कृपया प्रतिभागी कोड दर्ज करें'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    StudyLogger().startSession(code, _condition);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MedicationListScreen(
        condition: _condition,
        language: _lang,
      ),
    ));
  }

  Future<void> _export() async {
    final path = await StudyLogger().exportToCsv();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('Exported to: $path', 'ఎగుమతి చేయబడింది: $path', 'निर्यात किया गया: $path'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1D9E75),
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _t('Study Setup', 'స్టడీ సెటప్', 'अध्ययन सेटअप'),
          style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF888888)),
            tooltip: _t('Export study data', 'స్టడీ డేటా ఎగుమతి', 'अध्ययन डेटा निर्यात करें'),
            onPressed: _export,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('Participant code', 'పాల్గొనేవారి కోడ్', 'प्रतिभागी कोड'),
                style: const TextStyle(fontSize: 16, color: Color(0xFF555555), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: _t('e.g. P01', 'ఉదా: P01', 'उदा: P01'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1D9E75), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _t('Select study instructions style', 'సూచనల శైలిని ఎంచుకోండి', 'अध्ययन निर्देश शैली चुनें'),
                style: const TextStyle(fontSize: 16, color: Color(0xFF555555), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _conditionButton(
                    'A',
                    _t('Pictures + Voice', 'చిత్రాలు + వాయిస్', 'चित्र + आवाज़'),
                    _t('Uses body drawings, plain words, & speaks out loud.', 'శరీర పటాలు, సరళమైన భాష మరియు వాయిస్ సహాయాన్ని ఉపయోగిస్తుంది.', 'शरीर के चित्र, सरल शब्द और आवाज़ का उपयोग करता है।'),
                    Icons.image,
                    Icons.volume_up,
                    const Color(0xFF1D9E75),
                    const Color(0xFFE8F8F5),
                  ),
                  const SizedBox(width: 16),
                  _conditionButton(
                    'B',
                    _t('Basic Text Table', 'సాధారణ టెక్స్ట్ పట్టిక', 'सामान्य पाठ तालिका'),
                    _t('Uses a simple clinical text table only.', 'కేవలం సాధారణ క్లినికల్ టెక్స్ట్ పట్టికను మాత్రమే ఉపయోగిస్తుంది.', 'केवल एक सरल नैदानिक पाठ तालिका का उपयोग करता है।'),
                    Icons.description,
                    Icons.table_chart,
                    const Color(0xFF455A64),
                    const Color(0xFFECEFF1),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _launch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D9E75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: Text(
                    _t('Launch Study', 'స్టడీ ప్రారంభించు', 'अध्ययन शुरू करें'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conditionButton(
    String value,
    String title,
    String subtitle,
    IconData icon1,
    IconData icon2,
    Color activeColor,
    Color activeBg,
  ) {
    final selected = _condition == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _condition = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 220, // Tall, accessible visual button
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? activeBg : const Color(0xFFF9F9F9),
            border: Border.all(
              color: selected ? activeColor : const Color(0xFFDDDDDD),
              width: selected ? 3.0 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Double Icons row for unmistakable visual cue
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon1, size: 36, color: selected ? activeColor : const Color(0xFF888888)),
                  const SizedBox(width: 8),
                  Icon(icon2, size: 36, color: selected ? activeColor : const Color(0xFF888888)),
                ],
              ),
              const SizedBox(height: 16),
              // Accent Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selected ? activeColor : const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              // Accessible small description
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: selected ? activeColor.withValues(alpha: 0.85) : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
