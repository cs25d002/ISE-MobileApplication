import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class PrescriptionScreen extends StatelessWidget {
  final Map<String, dynamic> prescriptionData;

  PrescriptionScreen({required this.prescriptionData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prescription Details", style: GoogleFonts.lato()),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("👨‍⚕️ Physician"),
              _infoRow("Name", prescriptionData['physician']['name']),
              _infoRow("Medical Centre", prescriptionData['physician']['medical_centre']),
              SizedBox(height: 20),
              _sectionTitle("👤 Patient"),
              _infoRow("Name", prescriptionData['patient']['name']),
              _infoRow("Address", prescriptionData['patient']['address']),
              _infoRow("Date", prescriptionData['patient']['date']),
              SizedBox(height: 20),
              _sectionTitle("💊 Medications"),
              _buildMedicationTable(),
              SizedBox(height: 20),
              _sectionTitle("✍️ Signature"),
              _infoRow("", prescriptionData['signature'] ?? "N/A"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value ?? "N/A", style: GoogleFonts.lato(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMedicationTable() {
    List<dynamic> medications = prescriptionData["medications"] ?? [];
    
    return Table(
      border: TableBorder.all(color: Colors.black54),
      columnWidths: {
        0: FractionColumnWidth(0.3),
        1: FractionColumnWidth(0.2),
        2: FractionColumnWidth(0.2),
        3: FractionColumnWidth(0.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _tableHeader("Medication"),
            _tableHeader("Dosage"),
            _tableHeader("Frequency"),
            _tableHeader("Refills"),
          ],
        ),
        for (var med in medications)
          TableRow(
            children: [
              _tableCell(med["name"]),
              _tableCell(med["dosage"]),
              _tableCell(med["frequency"] ?? "N/A"),
              _tableCell(med["refills"] ?? "N/A"),
            ],
          ),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String? text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text ?? "N/A",
        style: GoogleFonts.lato(fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}
