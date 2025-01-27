import 'package:flutter/material.dart';

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
              Image.asset(
                'assets/images/doctor.png', // Path to your image
                height: 100,
                width: 100,
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
                  // Navigate to Add Patient page or logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Patient Clicked')),
                  );
                },
                child: const Text('Add Patient'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointments')),
                  );
                },
                child: const Text('Appointments'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Search Patient page or logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Messages')),
                  );
                },
                child: const Text('Messages'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

