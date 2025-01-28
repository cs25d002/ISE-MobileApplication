import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart'; // For unique ID generation
import 'package:flutter_auth/chatbot/chatbot_page.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _healthHistoryController = TextEditingController();
  File? _patientPicture;
  String? _selectedSex;
  String? _patientId;

  final ImagePicker _picker = ImagePicker();

  // Image Picker function
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _patientPicture = File(pickedFile.path);
      });
    }
  }

  // Handle form submission
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Generate a unique patient ID
      final uuid = Uuid();
      setState(() {
        _patientId = uuid.v4();
      });

      // Mock save to Firebase (replace with actual Firebase logic)
      final patientData = {
        "patientId": _patientId,
        "name": _nameController.text,
        "age": _ageController.text,
        "sex": _selectedSex,
        "weight": _weightController.text,
        "bloodPressure": _bloodPressureController.text,
        "healthHistory": _healthHistoryController.text,
        "picturePath": _patientPicture?.path,
      };

      print("Patient data saved: $patientData");

      // Navigate to success or reset form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient added successfully! PID: $_patientId")),
      );

      _formKey.currentState?.reset();
      setState(() {
        _patientPicture = null;
        _selectedSex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Patient Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Patient Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Age
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Sex
              DropdownButtonFormField<String>(
                value: _selectedSex,
                items: ['Male', 'Female', 'Other']
                    .map((sex) => DropdownMenuItem<String>(
                          value: sex,
                          child: Text(sex),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSex = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Sex'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select sex';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Weight
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Blood Pressure
              TextFormField(
                controller: _bloodPressureController,
                decoration: InputDecoration(labelText: 'Blood Pressure'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter blood pressure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Previous Health History
              TextFormField(
                controller: _healthHistoryController,
                decoration: InputDecoration(labelText: 'Health History'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter health history';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Picture Upload
              TextButton(
                onPressed: () {
                  _pickImage(ImageSource.camera);
                },
                child: Text(_patientPicture == null
                    ? 'Take Patient Picture'
                    : 'Change Patient Picture'),
              ),
              _patientPicture != null
                  ? Image.file(_patientPicture!, height: 150)
                  : Container(),
              const SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
              if (_patientId != null) Text('Generated PID: $_patientId'),
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
