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
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}

