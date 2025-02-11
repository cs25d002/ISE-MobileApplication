import 'package:flutter/material.dart';
import 'package:Vewha/chatbot/chatbot_page.dart';
import 'package:lottie/lottie.dart';
import 'add_patient.dart';
import 'package:Vewha/Screens/Home/calendar.dart';

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/doctorProfile.json', // Path to your image
                height: 250,
                width: 250,
              ),
              const SizedBox(height: 20),
              Text(
                'Hello Dr. $username', // Use extracted username
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
              ElevatedButton(
                onPressed: () {
                  // Navigate to AddPatientPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPatientPage()),
                  );
                },
                child: const Text(' Add Patient'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Search Patient page or logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search for Patient Clicked')),
                  );
                },
                child: const Text('Search for Patient'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Search Patient page or logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarPage()),
                  );
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Appointments')),
                },
                child: const Text('Scheduled Appointments'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Search Patient page or logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatbotPage()),
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Messages')),
                  );
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