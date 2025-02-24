import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class PrescriptionAnimationScreen extends StatefulWidget {
  const PrescriptionAnimationScreen({super.key});

  @override
  _PrescriptionAnimationScreenState createState() =>
      _PrescriptionAnimationScreenState();
}

class _PrescriptionAnimationScreenState
    extends State<PrescriptionAnimationScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset("assets/body.mp4")
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.setLooping(true);
        _videoController.play();
      });
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
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Title in white
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(221, 50, 50, 50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
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
            )
          else
            const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _animatedText("Physician: Dr. G. Pe Saddell"),
                _animatedText("DEA#: GB 05455616 | License #: 976269"),
                _animatedText(
                    "Medical Centre: 824 14th Street, New York, NY 91743, USA"),
                _animatedText("Phone: 1-889-422-0700"),
                const SizedBox(height: 20),
                _animatedText("Patient: Naber Oll"),
                _animatedText("Address: 167 Example St"),
                _animatedText("Date: 09-11-17"),
                const SizedBox(height: 20),
                _buildMedicationTable(),
                const Spacer(),
                _animatedText("Signature: [Physician Signature]",
                    textStyle: GoogleFonts.lato(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Function to display animated text with bold styling
  Widget _animatedText(String text, {TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            text,
            textStyle: textStyle ??
                GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // All text bold
                  color: const Color.fromARGB(221, 219, 214, 214),
                ),
            speed: const Duration(milliseconds: 50),
          ),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  /// Function to build a sample medication table
  Widget _buildMedicationTable() {
    List<Map<String, String>> medications = [
      {
        "name": "Betiloc",
        "dosage": "100mg",
        "route": "Oral",
        "frequency": "BID",
        "refills": "1"
      },
      {
        "name": "Dorzolamidua",
        "dosage": "10mg",
        "route": "Ophthalmic",
        "frequency": "TID",
        "refills": "2"
      },
      {
        "name": "Erith",
        "dosage": "50mg",
        "route": "Oral",
        "frequency": "TID",
        "refills": "None"
      },
      {
        "name": "Orprelol",
        "dosage": "50mg",
        "route": "Oral",
        "frequency": "QP",
        "refills": "None"
      }
    ];

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder.all(color: Colors.black54),
          columnWidths: const {0: FractionColumnWidth(0.3)},
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
            for (var med in medications)
              TableRow(
                children: [
                  _tableCell(med["name"] ?? "N/A"),
                  _tableCell(med["dosage"] ?? "N/A"),
                  _tableCell(med["route"] ?? "N/A"),
                  _tableCell(med["frequency"] ?? "N/A"),
                  _tableCell(med["refills"] ?? "N/A"),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Function to create a bold table header
  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.bold, // Bold headers
        ),
      ),
    );
  }

  /// Function to create a bold table cell
  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.bold, // Bold table content
        ),
      ),
    );
  }
}
