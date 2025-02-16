import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrescriptionPage extends StatelessWidget {
  final String pid;
  final String docID;

  const PrescriptionPage({super.key, required this.pid, required this.docID});

  Future<List<String>> fetchPrescriptions() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/prescriptions?docID=$docID&pid=$pid'),
    );
    
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body)); // Expecting a list of image URLs
    } else {
      return [];
    }
  }

  

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl, fit: BoxFit.cover),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: FutureBuilder<List<String>>(
        future: fetchPrescriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data!.isEmpty) {
            return const Center(child: Text('No prescriptions found'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Show images in a grid format
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              String imageUrl = snapshot.data![index];
              String fileName = imageUrl.split('/').last; // Extract the file name from the URL
              return GestureDetector(
                onTap: () => _showImage(context, imageUrl),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          fileName, // Display filename
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis, // Truncate long names
                          maxLines: 1,
                        ),
            ),
          ],
        ),
      ),
    );
            },
          );
        },
      ),
    );
  }
}
