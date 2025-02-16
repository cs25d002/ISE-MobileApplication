import 'package:flutter/material.dart';
import 'package:Vewha/Components/constants.dart'; // Ensure your constants file is imported for theme consistency
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages =
      []; // Store messages as a list of maps
  bool _isLoading = false;

  // Chatbot API details
  final String chatbotApiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyAVKWaxaSJdDG_sNSvPacxJHV8aPJNMRkg";

  Future<void> _sendMessage() async {
    final userInput = _controller.text;
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add({"user": userInput}); // Add user message
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(chatbotApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userInput}
              ]
            }
          ]
        }),
      );

      print("API Response: ${response.body}"); // Debugging log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Parsed Data: $data"); // Debugging log

        final botResponse = data['candidates'][0]['content']['parts'][0]
            ['text']; // Updated path

        setState(() {
          _messages.add({"bot": botResponse});
        });
      } else {
        setState(() {
          _messages.add({
            "bot":
                "Error: Unable to fetch response. Status code: ${response.statusCode}"
          });
        });
      }
    } catch (e) {
      print("Error: $e"); // Log the error
      setState(() {
        _messages.add({"bot": "Error: ${e.toString()}"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6A1B9A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Image Fix: Reduce size to 75% and center it
          Positioned.fill(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/blocks/chatbot_background.png'), // Replace with your image
                    fit: BoxFit
                        .contain, // Ensures the image fits without stretching
                  ),
                ),
              ),
            ),
          ),

          // Chat Interface with side padding only
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(5.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.containsKey("user");

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser
                                ? kPrimaryColor
                                : Color.fromARGB(255, 184, 171, 207),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            isUser ? message['user']! : message['bot']!,
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : Colors
                                      .black, // White for user, Black for bot
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Input Field Fix: Use BoxDecoration instead of conflicting color property
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 186, 174, 208),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: kPrimaryColor),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
