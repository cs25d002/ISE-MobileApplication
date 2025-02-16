import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrescriptionAnimationScreen extends StatefulWidget {
  final String docID;
  final String pid;
  final String filename;

  PrescriptionAnimationScreen({
    required this.docID,
    required this.pid,
    required this.filename,
  });

  @override
  _PrescriptionAnimationScreenState createState() =>
      _PrescriptionAnimationScreenState();
}

class _PrescriptionAnimationScreenState
    extends State<PrescriptionAnimationScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  Map<String, dynamic>? prescriptionData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPrescriptionData();
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset("assets/body.mp4")
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.setLooping(true);
        _videoController.play();
      });
  }

  Future<void> _loadPrescriptionData() async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/process-ocr"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "docID": widget.docID,
          "pid": widget.pid,
          "filename": widget.filename,
        }),
      );

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);

        if (decodedJson is Map<String, dynamic>) {
          setState(() {
            prescriptionData = decodedJson;
            _isLoading = false;
          });
        } else {
          throw Exception("Invalid JSON format: Expected Map, got ${decodedJson.runtimeType}");
        }
      } else {
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print("OCR Error: $e");
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          "Animated Prescription",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Text(
                    "Error loading prescription data",
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.red),
                  ),
                )
              : Stack(
                  children: [
                    if (_isVideoInitialized)
                      Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController.value.size.width,
                            height: _videoController.value.size.height,
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _animatedText("👨‍⚕️ Physician: ${_getSafeValue("physician", "name")}"),
                            _animatedText("📜 License #: ${_getSafeValue("physician", "license")}"),
                            _animatedText("🏥 Medical Centre: ${_getSafeValue("physician", "medical_centre")}"),
                            _animatedText("📞 Phone: ${_getSafeValue("physician", "phone")}"),
                            SizedBox(height: 20),
                            _animatedText("👤 Patient: ${_getSafeValue("patient", "name")}"),
                            _animatedText("🏠 Address: ${_getSafeValue("patient", "address")}"),
                            _animatedText("📅 Date: ${_getSafeValue("patient", "date")}"),
                            SizedBox(height: 20),
                            _buildMedicationTable(),
                            SizedBox(height: 20),
                            _animatedText("✍️ Signature: ${_getSafeValue("signature")}", textStyle: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _animatedText(String text, {TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            text,
            textStyle: textStyle ?? GoogleFonts.lato(fontSize: 16, color: Colors.black87),
            speed: Duration(milliseconds: 50),
          ),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  Widget _buildMedicationTable() {
    List<dynamic> medications = prescriptionData?["medications"] ?? [];

    if (medications is! List) {
      medications = [];
    }

    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder.all(color: Colors.black54),
          columnWidths: {0: FractionColumnWidth(0.3)},
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: [
                _tableHeader("Medication"),
                _tableHeader("Dosage"),
                _tableHeader("Route"),
                _tableHeader("Frequency"),
                _tableHeader("Refills"),
              ],
            ),
            if (medications.isEmpty)
              TableRow(
                children: [
                  _tableCell("No Data", isBold: true),
                  _tableCell(""),
                  _tableCell(""),
                  _tableCell(""),
                  _tableCell(""),
                ],
              ),
            for (var med in medications)
              if (med is Map<String, dynamic>)
                TableRow(
                  children: [
                    _tableCell(med["name"]?.toString() ?? "N/A"),
                    _tableCell(med["dosage"]?.toString() ?? "N/A"),
                    _tableCell(med["route"]?.toString() ?? "N/A"),
                    _tableCell(med["frequency"]?.toString() ?? "N/A"),
                    _tableCell(med["refills"]?.toString() ?? "N/A"),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.lato(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  String _getSafeValue(String key1, [String? key2]) {
    if (prescriptionData == null) return "N/A";

    var value = prescriptionData![key1];
    if (value == null) return "N/A";

    if (key2 != null) {
      var nestedValue = value[key2];
      return nestedValue is String ? nestedValue : "N/A";
    }

    return value is String ? value : "N/A";
  }
}
