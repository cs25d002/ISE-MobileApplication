import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimatedEHRScreen extends StatefulWidget {
  final String extractedText;
  final String pid;
  final String docID;

  const AnimatedEHRScreen({super.key, required this.extractedText, required this.pid, required this.docID});

  @override
  _AnimatedEHRScreenState createState() => _AnimatedEHRScreenState();
}

class _AnimatedEHRScreenState extends State<AnimatedEHRScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  Map<String, dynamic>? patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    final url = Uri.parse('http://localhost:5000/api/patient/${widget.docID}/${widget.pid}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          patientData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load patient data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching patient data: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Patient EHR", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Lottie.asset('assets/medical_animation.json'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientHeader(),
                        SizedBox(height: 20),
                        _buildEHRCard("Diagnosis", patientData?["diagnosis"] ?? "N/A"),
                        _buildEHRCard("Prescriptions", widget.extractedText),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 30,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Patient Name: ${patientData?["name"] ?? "Unknown"}", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Age: ${patientData?["age"] ?? "N/A"} | Blood Type: ${patientData?["bloodType"] ?? "N/A"}", style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEHRCard(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            Text(content, style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
