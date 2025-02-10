import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_auth/chatbot/chatbot_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for patient details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();

  // File variables for images
  File? _patientImage;
  File? _prescriptionImage;

  final picker = ImagePicker();
  bool _showAddPrescription = false;
  String? _uniquePid;

  // Function to capture patient image
  Future<void> _takePatientPicture() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _patientImage = File(pickedFile.path);
      });
    }
  }

  // Function to capture prescription image
  Future<void> _addPrescriptionImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _prescriptionImage = File(pickedFile.path);
      });
    }
  }

  // Function to submit patient details
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _patientImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and take a patient picture')),
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
    };

    final uri = Uri.parse('http://127.0.0.1:3000/add-patient');
    final request = http.MultipartRequest('POST', uri);

    request.fields['patientData'] = jsonEncode(patientData);
    request.files.add(
      await http.MultipartFile.fromPath('patientImage', _patientImage!.path),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = jsonDecode(await response.stream.bytesToString())
            as Map<String, dynamic>;

        setState(() {
          _uniquePid = responseData['pid'];
          _showAddPrescription = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient data submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission failed! Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Function to upload prescription
  Future<void> _addPrescription() async {
    if (_uniquePid == null || _uniquePid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient ID not found!')),
      );
      return;
    }

    final uri = Uri.parse('http://127.0.0.1:3000/add-prescription');
    final request = http.MultipartRequest('POST', uri);

    request.fields['pid'] = _uniquePid!;
    request.files.add(
      await http.MultipartFile.fromPath(
          'prescriptionImage', _prescriptionImage!.path),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add prescription!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value:
                    _sexController.text.isNotEmpty ? _sexController.text : null,
                items: ['Male', 'Female', 'Other']
                    .map((sex) => DropdownMenuItem(
                          value: sex,
                          child: Text(sex),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _sexController.text = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Sex'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select sex';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bloodPressureController,
                decoration: const InputDecoration(labelText: 'Blood Pressure'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter blood pressure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _healthHistoryController,
                decoration: const InputDecoration(labelText: 'Health History'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter health history';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _takePatientPicture,
                child: const Text('Take Patient Picture'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
              if (_showAddPrescription) ...[
                const SizedBox(height: 32),
                const Text('Add Prescription', style: TextStyle(fontSize: 18)),
                ElevatedButton(
                  onPressed: _addPrescriptionImage,
                  child: const Text('Capture Prescription Image'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addPrescription,
                  child: const Text('Upload Prescription'),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Patient',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Patient',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
        selectedItemColor:
            Theme.of(context).primaryColor, // Uses theme's primary color
        unselectedItemColor:
            Theme.of(context).disabledColor, // Uses theme's disabled color
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor, // Matches app's background
        onTap: (index) {
          if (index == 3) {
            // Navigate to ChatPage when "Messages" icon is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatbotPage()),
            );
          } else {
            // Handle other navigation logic here
            print("Navigated to section: $index");
          }
        },
      ),
    );
  }
}
