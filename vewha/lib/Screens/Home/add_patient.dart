import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPatientPage extends StatefulWidget {
  final String docID;
  const AddPatientPage({super.key, required this.docID});

  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();

  File? _patientImage;
  File? _prescriptionImage;
  final picker = ImagePicker();
  bool _showAddPrescription = false;
  String? _uniquePid;

  Future<void> _pickImage(bool isPatientImage) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        if (isPatientImage) {
          _patientImage = File(pickedFile.path);
        } else {
          _prescriptionImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _patientImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields & take patient picture')),
      );
      return;
    }

    final patientData = {
      "name": _nameController.text,
      "age": _ageController.text,
      "sex": _sexController.text,
      "weight": _weightController.text,
      "bloodPressure": _bpController.text,
      "healthHistory": _historyController.text,
      "docID": widget.docID,
    };

    final uri = Uri.parse('http://10.25.84.132:3000/add-patient');
    final request = http.MultipartRequest('POST', uri);
    request.fields['patientData'] = jsonEncode(patientData);
    request.files.add(await http.MultipartFile.fromPath('patientImage', _patientImage!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        setState(() {
          _uniquePid = responseData['pid'];
          _showAddPrescription = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient added successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission failed!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _addPrescription() async {
    if (_uniquePid == null || _prescriptionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Patient ID or prescription image!')),
      );
      return;
    }

    final uri = Uri.parse('http://10.25.84.132:3000/add-prescription');
    final request = http.MultipartRequest('POST', uri);
    request.fields['docID'] = widget.docID; 
    request.fields['pid'] = _uniquePid!;
    request.files.add(await http.MultipartFile.fromPath('prescriptionImage', _prescriptionImage!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription uploaded!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: Padding(
        
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (value) => value!.isEmpty ? 'Enter Name' : null),
              const SizedBox(height: 20),
              TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Age',suffixText: 'years', ), inputFormatters: [FilteringTextInputFormatter.digitsOnly],keyboardType: TextInputType.number, validator: (value) => value!.isEmpty ? 'Enter Age' : null),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _sexController.text.isNotEmpty ? _sexController.text : null,
                items: ['Male', 'Female', 'Other'].map((sex) => DropdownMenuItem(value: sex, child: Text(sex))).toList(),
                onChanged: (value) => setState(() => _sexController.text = value!),
                decoration: const InputDecoration(labelText: 'Sex'),
                
                validator: (value) => value == null ? 'Select Sex' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        suffixText: 'kg', // Adds "kg" to the field
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
              const SizedBox(height: 20),
              TextFormField(controller: _bpController, decoration: const InputDecoration(labelText: 'Blood Pressure'),validator: (value) => value!.isEmpty ? 'Enter BP' : null),
              const SizedBox(height: 20),
              TextFormField(controller: _historyController, decoration: const InputDecoration(labelText: 'Health History'), validator: (value) => value!.isEmpty ? 'Enter History' : null),
              
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickImage(true),
                icon: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 99, 99, 173)),
                label: const Text('Take Patient Picture'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: const Text('Submit')),
              if (_showAddPrescription) ...[
                const SizedBox(height: 20),
                const Text('Add Prescription', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                onPressed: () => _pickImage(true),
                icon: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 137, 115, 204)),
                label: const Text('Take Prescription Picture'),
              ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _addPrescription, child: const Text('Upload Prescription')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
