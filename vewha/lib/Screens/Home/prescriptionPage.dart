import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:Vewha/Screens/Home/AnimatedPrescriptionPage.dart'; // Import animated page

class PrescriptionPage extends StatefulWidget {
  final String pid;
  final String docID;

  const PrescriptionPage({super.key, required this.pid, required this.docID});

  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  List<String> _prescriptions = [];
  bool _isLoading = true;
  File? _prescriptionImage;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  // Fetch prescriptions from backend
  Future<void> _fetchPrescriptions() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/prescriptions?docID=${widget.docID}&pid=${widget.pid}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _prescriptions = List<String>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        print("Failed to load prescriptions: ${response.body}");
      }
    } catch (e) {
      print("Error fetching prescriptions: $e");
    }
  }

  // Pick an image from the camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _prescriptionImage = File(pickedFile.path);
      });
      _addPrescription(); // Auto-upload after selecting the image
    }
  }

  // Upload prescription image to backend
  Future<void> _addPrescription() async {
    if (_prescriptionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture an image first!')),
      );
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:3000/add-prescription');
    final request = http.MultipartRequest('POST', uri);
    request.fields['docID'] = widget.docID;
    request.fields['pid'] = widget.pid;
    request.files.add(
      await http.MultipartFile.fromPath('prescriptionImage', _prescriptionImage!.path),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription uploaded successfully!')),
        );
        _fetchPrescriptions(); // Refresh UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _processOCR2(BuildContext context, String imageUrl) {
  // Navigate directly to the animated prescription page when an image is clicked
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>  PrescriptionAnimationScreen(),
    ),
  );
}


  // Process OCR and navigate to animated screen
  void _processOCR(BuildContext context, String imageUrl) async {
    try {
      final Uri url = Uri.parse("http://10.0.2.2:3000/process-ocr");
      String filename = imageUrl.split('/').last;

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "docID": widget.docID,
          "pid": widget.pid,
          "filename": filename,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String extractedText = data['text'];

        print("OCR Result: $extractedText");

        // Navigate to animated prescription screen with extracted text
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  PrescriptionAnimationScreen(),
          ),
        );
      } else {
        print("OCR Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR Processing Failed!')),
        );
      }
    } catch (e) {
      print("OCR Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescriptions.isEmpty
              ? const Center(child: Text('No prescriptions found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _prescriptions.length,
                  itemBuilder: (context, index) {
                    String imageUrl = _prescriptions[index];
                    String fileName = imageUrl.split('/').last;
                    return GestureDetector(
                      onTap: () => _processOCR2(context, imageUrl),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                fileName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage, // Open camera when pressed
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
