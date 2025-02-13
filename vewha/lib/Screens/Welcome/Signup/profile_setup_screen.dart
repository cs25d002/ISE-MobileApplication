import 'package:flutter/material.dart';
import '../../../Components/constants.dart';
import '../../../Components/responsive.dart';
import '../_shared/background.dart';
import '../../Home/home_page.dart'; // this is where GreetingPage is located

class ProfileSetupScreen extends StatefulWidget {
  final String email;

  const ProfileSetupScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      // Save profile details (you can integrate this with Firebase or any backend)
      final profileData = {
        'name': _nameController.text,
        'age': _ageController.text,
        'department': _departmentController.text,
        'qualification': _qualificationController.text,
        'hospital': _hospitalController.text,
        'experience': _experienceController.text,
      };

      // Navigate to the home page after profile setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GreetingPage(email: widget.email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: kPrimaryColor, // Using the primary color from constants.dart
      ),
      body: Background(
        child: SingleChildScrollView(
          child: Responsive(
            mobile: MobileProfileSetup(formKey: _formKey, nameController: _nameController, ageController: _ageController, departmentController: _departmentController, qualificationController: _qualificationController, hospitalController: _hospitalController, experienceController: _experienceController, submitProfile: _submitProfile),
            desktop: DesktopProfileSetup(formKey: _formKey, nameController: _nameController, ageController: _ageController, departmentController: _departmentController, qualificationController: _qualificationController, hospitalController: _hospitalController, experienceController: _experienceController, submitProfile: _submitProfile),
          ),
        ),
      ),
    );
  }
}

class MobileProfileSetup extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController departmentController;
  final TextEditingController qualificationController;
  final TextEditingController hospitalController;
  final TextEditingController experienceController;
  final VoidCallback submitProfile;

  const MobileProfileSetup({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.ageController,
    required this.departmentController,
    required this.qualificationController,
    required this.hospitalController,
    required this.experienceController,
    required this.submitProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(pad_norm),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _buildTextField("Full Name", "Enter your full name", nameController),
            _buildTextField("Age", "Enter your age", ageController, keyboardType: TextInputType.number),
            _buildTextField("Department", "Enter your department", departmentController),
            _buildTextField("Qualification", "Enter your qualification", qualificationController),
            _buildTextField("Hospital", "Enter your hospital name", hospitalController),
            _buildTextField("Experience", "Enter your experience (in years)", experienceController, keyboardType: TextInputType.number),
            const SizedBox(height: pad_norm),
            ElevatedButton(
              onPressed: submitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor, // Using the primary color from constants.dart
                padding: const EdgeInsets.symmetric(horizontal: pad_big, vertical: pad_small),
              ),
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: pad_small),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.person_outline, color: kPrimaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(pad_small),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter $label";
          return null;
        },
      ),
    );
  }
}

class DesktopProfileSetup extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController departmentController;
  final TextEditingController qualificationController;
  final TextEditingController hospitalController;
  final TextEditingController experienceController;
  final VoidCallback submitProfile;

  const DesktopProfileSetup({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.ageController,
    required this.departmentController,
    required this.qualificationController,
    required this.hospitalController,
    required this.experienceController,
    required this.submitProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField("Full Name", "Enter your full name", nameController),
              _buildTextField("Age", "Enter your age", ageController, keyboardType: TextInputType.number),
              _buildTextField("Department", "Enter your department", departmentController),
              _buildTextField("Qualification", "Enter your qualification", qualificationController),
              _buildTextField("Hospital", "Enter your hospital name", hospitalController),
              _buildTextField("Experience", "Enter your experience (in years)", experienceController, keyboardType: TextInputType.number),
              const SizedBox(height: pad_norm),
              ElevatedButton(
                onPressed: submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor, // Using the primary color from constants.dart
                  padding: const EdgeInsets.symmetric(horizontal: pad_big, vertical: pad_small),
                ),
                child: const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: pad_small),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.person_outline, color: kPrimaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(pad_small),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Please enter $label";
          return null;
        },
      ),
    );
  }
}