import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../logging/study_logger.dart';
import 'medication_list_screen.dart';
import '../../services/patient_tts_service.dart';
import '../../repositories/localization_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _condition = widget.initialCondition;
    PatientTtsService().prewarm();
  }

  void _launch() {
    final code = _codeController.text.trim();
    final loc = context.read<LocalizationRepository>();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.translate('enter_participant_code'),
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
    final loc = context.read<LocalizationRepository>();

    if (mounted) {
      try {
        await Share.shareXFiles([XFile(path)], text: 'VEWHA Study Log CSV');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.translate('export_success'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF1D9E75),
          ),
        );
      } catch (e) {
        debugPrint('Error sharing file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share file: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.read<LocalizationRepository>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          loc.translate('study_setup'),
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
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF888888)),
            tooltip: loc.translate('export_study_data'),
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
                loc.translate('participant_code'),
                style: const TextStyle(fontSize: 16, color: Color(0xFF555555), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: loc.translate('participant_code_hint'),
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
                loc.translate('select_instruction_style'),
                style: const TextStyle(fontSize: 16, color: Color(0xFF555555), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _conditionButton(
                    'A',
                    loc.translate('style_a_title'),
                    loc.translate('style_a_subtitle'),
                    Icons.image,
                    Icons.volume_up,
                    const Color(0xFF1D9E75),
                    const Color(0xFFE8F8F5),
                  ),
                  const SizedBox(width: 16),
                  _conditionButton(
                    'B',
                    loc.translate('style_b_title'),
                    loc.translate('style_b_subtitle'),
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
                    loc.translate('launch_study'),
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
          height: 220, 
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon1, size: 36, color: selected ? activeColor : const Color(0xFF888888)),
                  const SizedBox(width: 8),
                  Icon(icon2, size: 36, color: selected ? activeColor : const Color(0xFF888888)),
                ],
              ),
              const SizedBox(height: 16),
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
