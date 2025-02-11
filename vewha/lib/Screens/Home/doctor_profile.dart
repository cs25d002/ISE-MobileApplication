import 'package:flutter/material.dart';
import '../Welcome/welcome_screen.dart';

class DoctorProfilePage extends StatelessWidget {
  final String name;
  final int age;
  final String department;
  final String qualification;
  final String hospital;
  final String experience;

  const DoctorProfilePage({ // need to change this to dynamic fetch from server based on user with backend
    super.key, // currently this page needs to be called with these values as parameters
    required this.name,
    required this.age,
    required this.department,
    required this.qualification,
    required this.hospital,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: const Color.fromARGB(255, 121, 68, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileDetail('Name', name),
            _buildProfileDetail('Age', age.toString()),
            _buildProfileDetail('Department', department),
            _buildProfileDetail('Qualification', qualification),
            _buildProfileDetail('Hospital', hospital),
            _buildProfileDetail('Experience', experience),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  );
                },
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}