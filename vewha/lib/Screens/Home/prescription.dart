import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrescriptionPage extends StatelessWidget {
  final String pid;
  
  PrescriptionPage({required this.pid});

  Future<List<String>> fetchPrescriptions() async {
    final response = await http.get(Uri.parse('http://10.25.73.154:3000/prescriptions?pid=$pid'));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prescriptions for $pid')),
      body: FutureBuilder<List<String>>(
        future: fetchPrescriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading prescriptions'));
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No prescriptions found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.description),
                title: Text(snapshot.data![index]),
                onTap: () {
                  // Open the prescription image
                },
              );
            },
          );
        },
      ),
    );
  }
}