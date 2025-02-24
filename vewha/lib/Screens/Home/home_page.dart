import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:Vewha/chatbot/chatbot_page.dart';
import 'package:lottie/lottie.dart';
import 'add_patient.dart';
import 'package:Vewha/Screens/Home/calendar.dart';
// import 'package:Vewha/Screens/Home/EHR/ehr_knee.dart';
import 'search_patient.dart';
import 'doctor_profile.dart';

class GreetingPage extends StatefulWidget {
  final String email;
  

  const GreetingPage({super.key, required this.email});

  @override
  _GreetingPageState createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage> {
  String? docID; // Store the docID
  @override
  void initState() {
    super.initState();
    registerDoctor();
  }

  Future<void> registerDoctor() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/register-doctor'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        docID = responseData['docID']; // Store docID in state
      });
      print('Doctor registered successfully: ${jsonDecode(response.body)['docID']}');
    } else {
      print('Failed to register doctor: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    String username = widget.email.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: const Color.fromARGB(255, 121, 68, 255),
        actions: [
          IconButton(
             icon: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/icon.png'), // Doctor Image
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorProfilePage(
                    name: 'Dr. $username',
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/doctorProfile.json',
                height: 250,
                width: 250,
              ),
              const SizedBox(height: 20),
              Text(
                'Hello Dr. $username',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Great day, huh?',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
             ElevatedButton(
                  onPressed: () {
                    if (docID != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPatientPage(docID: docID!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please wait, fetching doctor ID...")),
                      );
                    }
                  },
                  child: const Text('Add Patient'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (docID != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPatientPage(docID: docID!)));
                }
                },
                child: const Text('Search for Patient'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
                },
                child: const Text('Scheduled Appointments'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage()));
                },
                child: const Text('AI Chatbot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:flutter_auth/chatbot/chatbot_page.dart';
import 'package:lottie/lottie.dart';
import 'add_patient.dart';
import 'package:flutter_auth/Screens/Home/calendar.dart';

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
        backgroundColor: const Color.fromARGB(255, 121, 68, 255),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Prevents overflow by allowing scrolling
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Add spacing at the top

              // Doctor Lottie Animation
              Lottie.asset(
                'assets/animations/doctorProfile.json',
                height: 250, // Adjusted height to prevent overflow
                width: 250,
              ),
              const SizedBox(height: 20),

              // Greeting Text
              Text(
                'Hello Dr. $username',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Great day, huh?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Buttons Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20), // Padding for all buttons
                child: Column(
                  children: [
                    _buildButton(
                      context,
                      "Add Patient",
                      const AddPatientPage(),
                    ),
                    _buildButton(
                      context,
                      "Search for Patient",
                      null, // Placeholder for future search logic
                    ),
                    _buildButton(
                      context,
                      "Scheduled Appointments",
                      const CalendarPage(),
                    ),
                    _buildButton(
                      context,
                      "AI Chatbot",
                      const ChatbotPage(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  /// Custom Button Builder (Avoids Redundant Code)
  Widget _buildButton(BuildContext context, String text, Widget? page) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50), // Full width buttons
          backgroundColor: const Color.fromARGB(255, 121, 68, 255), // Matching theme
        ),
        onPressed: () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$text Clicked")),
            );
          }
        },
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
  */