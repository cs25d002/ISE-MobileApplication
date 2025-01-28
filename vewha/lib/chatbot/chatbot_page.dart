import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final List<Map<String, dynamic>> _chatHistory = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> getAnswer() async {
    final apiKey = "AIzaSyAVKWaxaSJdDG_sNSvPacxJHV8aPJNMRkg"; // Replace with your valid API key
    final url =
        "https://generativelanguage.googleapis.com/v1beta2/models/gemini-1.5-flash:generateContent?key=$apiKey";
    final uri = Uri.parse(url);

    // Prepare the request body
    Map<String, dynamic> request = {
      "contents": [
        {
          "parts": [
            {"text": _chatHistory.last["message"] ?? ""}
          ]
        }
      ]
    };

    try {
      // Send the POST request
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botMessage =
            data["contents"][0]["parts"][0]["text"]; // Extract response text

        // Add the bot's response to chat history
        setState(() {
          _chatHistory.add({
            "time": DateTime.now(),
            "message": botMessage,
            "isSender": false,
          });
        });

        // Scroll to the bottom
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      } else {
        throw Exception("Failed to fetch response: ${response.body}");
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        _chatHistory.add({
          "time": DateTime.now(),
          "message": "Something went wrong. Please try again.",
          "isSender": false,
        });
      });

      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );

      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Chatbot")),
      body: Column(
        children: [
          // Chat History Display
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                final isUser = message["isSender"] ?? false;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["message"] ?? "",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Field and Send Button
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    // Add user message to chat history
                    setState(() {
                      if (_chatController.text.isNotEmpty) {
                        _chatHistory.add({
                          "time": DateTime.now(),
                          "message": _chatController.text,
                          "isSender": true,
                        });
                        _chatController.clear();
                      }
                    });

                    // Scroll to the bottom and fetch bot response
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );

                    getAnswer();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
