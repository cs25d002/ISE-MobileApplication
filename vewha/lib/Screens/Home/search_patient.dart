import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prescription.dart';



class SearchPatientPage extends StatefulWidget {
  const SearchPatientPage({Key? key}) : super(key: key);
  @override
  _SearchPatientPageState createState() => _SearchPatientPageState();
}

class _SearchPatientPageState extends State<SearchPatientPage> {
  List<dynamic> patients = [];
  List<dynamic> filteredPatients = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    final response = await http.get(Uri.parse('http://10.25.73.154:3000/patients'));
    if (response.statusCode == 200) {
      setState(() {
        patients = json.decode(response.body);
        filteredPatients = patients;
      });
    }
  }

  void filterPatients(String query) {
    setState(() {
      filteredPatients = patients
          .where((patient) => patient['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void viewPrescriptions(String pid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionPage(pid: pid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Patient')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
              ),
              onChanged: filterPatients,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'http://10.25.73.154:3000/uploads/${patient['pid']}.jpg'),
                    onBackgroundImageError: (_, __) => const Icon(Icons.person),
                  ),
                  title: Text(patient['name']),
                  subtitle: Text('${patient['age']} / ${patient['sex']}'),
                  trailing: Text(patient['pid']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
