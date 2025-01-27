import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _healthHistoryController = TextEditingController();
  File? _image;
  File? _prescriptionImage;
  String? _selectedSex;
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;

  final ImagePicker _picker = ImagePicker();

  // Image Picker function
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Prescription Image Picker function
  Future<void> _pickPrescriptionImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _prescriptionImage = File(pickedFile.path);
      });
    }
  }

  // Date and Time Picker for appointment
  Future<void> _pickDateAndTime() async {
    DateTime selectedDate = await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      onConfirm: (date) {
        setState(() {
          _appointmentDate = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    ) ?? DateTime.now();

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _appointmentTime = selectedTime;
      });
    }
  }

  // Handle form submission
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Process the form data here
      print("Form submitted with data: ");
      print("Name: ${_nameController.text}");
      print("Age: ${_ageController.text}");
      print("Sex: $_selectedSex");
      print("Blood Pressure: ${_bloodPressureController.text}");
      print("Health History: ${_healthHistoryController.text}");
      if (_image != null) print("Picture: ${_image?.path}");
      if (_prescriptionImage != null) print("Prescription: ${_prescriptionImage?.path}");
      print("Appointment Date: $_appointmentDate");
      print("Appointment Time: $_appointmentTime");
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
              // Name
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
              // Picture Upload
              TextButton(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                child: Text(_image == null ? 'Add Picture' : 'Change Picture'),
              ),
              _image != null ? Image.file(_image!) : Container(),
              // Prescription Image
              TextButton(
                onPressed: () {
                  _pickPrescriptionImage(ImageSource.gallery);
                },
                child: Text(_prescriptionImage == null
                    ? 'Add Prescription Image'
                    : 'Change Prescription Image'),
              ),
              _prescriptionImage != null
                  ? Image.file(_prescriptionImage!)
                  : Container(),
              // Appointment Date and Time Picker
              TextButton(
                onPressed: _pickDateAndTime,
                child: Text('Select Appointment Date & Time'),
              ),
              if (_appointmentDate != null)
                Text('Date: ${_appointmentDate!.toLocal()}'),
              if (_appointmentTime != null)
                Text('Time: ${_appointmentTime!.format(context)}'),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
