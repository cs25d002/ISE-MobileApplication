import 'package:flutter/material.dart';
import 'package:Vewha/chatbot/chatbot_page.dart';
import 'package:lottie/lottie.dart';
import 'add_patient.dart';
import 'package:Vewha/Screens/Home/calendar.dart';
import 'package:Vewha/Screens/Home/EHR/ehr_knee.dart';
import 'doctor_profile.dart';
import 'package:Vewha/Components/constants.dart'; // Import constants for colors and padding
import 'package:Vewha/Components/responsive.dart'; // Import Responsive for layout adjustments

class GreetingPage extends StatelessWidget {
  final String email;

  const GreetingPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the username (part before '@')
    String username = email.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: kPrimaryColor, // Use primary color from constants.dart
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to DoctorProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorProfilePage(
                    name: 'Dr. $username', // Default values, replace with server-fetched data
                    age: 35,
                    department: 'Cardiology',
                    qualification: 'MD, PhD',
                    hospital: 'City General Hospital',
                    experience: '10 years',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Responsive(
          mobile: _buildMobileLayout(context, username),
          tablet: _buildTabletLayout(context, username),
          desktop: _buildDesktopLayout(context, username),
        ),
      ),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context, String username) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/doctorProfile.json',
            height: 250,
            width: 250,
          ),
          const SizedBox(height: pad_norm),
          Text(
            'Hello Dr. $username',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: pad_small),
          const Text(
            'Great day, huh?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: pad_norm),
          _buildButton(context, "Add Patient", const AddPatientPage()),
          const SizedBox(height: pad_small),
          _buildButton(context, "Search for Patient", PrescriptionDetailsScreen()),
          const SizedBox(height: pad_small),
          _buildButton(context, "Scheduled Appointments", const CalendarPage()),
          const SizedBox(height: pad_small),
          _buildButton(context, "AI Chatbot", ChatbotPage()),
        ],
      ),
    );
  }

  // Tablet Layout
  Widget _buildTabletLayout(BuildContext context, String username) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/doctorProfile.json',
            height: 300,
            width: 300,
          ),
          const SizedBox(height: pad_norm),
          Text(
            'Hello Dr. $username',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: pad_small),
          const Text(
            'Great day, huh?',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: pad_norm),
          _buildButton(context, "Add Patient", const AddPatientPage()),
          const SizedBox(height: pad_small),
          _buildButton(context, "Search for Patient", PrescriptionDetailsScreen()),
          const SizedBox(height: pad_small),
          _buildButton(context, "Scheduled Appointments", const CalendarPage()),
          const SizedBox(height: pad_small),
          _buildButton(context, "AI Chatbot", ChatbotPage()),
        ],
      ),
    );
  }

  // Desktop Layout
  Widget _buildDesktopLayout(BuildContext context, String username) {
    return Center(
      child: SizedBox(
        width: 600, // Limit width for better readability on desktop
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/doctorProfile.json',
              height: 350,
              width: 350,
            ),
            const SizedBox(height: pad_norm),
            Text(
              'Hello Dr. $username',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: pad_small),
            const Text(
              'Great day, huh?',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: pad_norm),
            _buildButton(context, "Add Patient", const AddPatientPage()),
            const SizedBox(height: pad_small),
            _buildButton(context, "Search for Patient", PrescriptionDetailsScreen()),
            const SizedBox(height: pad_small),
            _buildButton(context, "Scheduled Appointments", const CalendarPage()),
            const SizedBox(height: pad_small),
            _buildButton(context, "AI Chatbot", ChatbotPage()),
          ],
        ),
      ),
    );
  }

  // Reusable Button Builder
  Widget _buildButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor, // Use primary color from constants.dart
        padding: const EdgeInsets.symmetric(horizontal: pad_big, vertical: pad_small),
        minimumSize: const Size(double.infinity, 50), // Full-width button
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}