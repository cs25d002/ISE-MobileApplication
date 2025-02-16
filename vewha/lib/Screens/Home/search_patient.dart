import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prescriptionPage.dart';


class SearchPatientPage extends StatefulWidget {
  final String docID;
  const SearchPatientPage({super.key, required this.docID});
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
    fetchPatients(widget.docID);
  }

  Future<void> fetchPatients(String docID) async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:3000/patients?docID=$docID'),
  );

  if (response.statusCode == 200) {
    setState(() {
      patients = json.decode(response.body);
      filteredPatients = patients;
    });
  } else {
    print('Failed to fetch patients');
  }
}


  void filterPatients(String query) {
    setState(() {
      filteredPatients = patients
          .where((patient) => patient['name'].toLowerCase().contains(query.toLowerCase()))
          
          .toList();
    }
    


    
    );
  }

  void viewPrescriptions(String pid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionPage(pid: pid, docID: widget.docID),
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
                        'http://10.0.2.2:3000/uploads/${patient['docID']}/patient_pics/${patient['name']}.jpg'),
                    onBackgroundImageError: (_, __) => const Icon(Icons.person),
                  ),
                  title: Text(patient['name']),
                  subtitle: Text('${patient['age']} / ${patient['sex']}'),
                  trailing: Text(patient['pid']),
                  onTap: () {
                    // Navigate to PrescriptionPage when a patient is clicked
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrescriptionPage(pid: patient['pid'], docID: patient['docID']),
                    ),
                  );

                  },
                );
              },
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person_add),
      //       label: 'Add Patient',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.search),
      //       label: 'Search Patient',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.calendar_today),
      //       label: 'Appointments',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.message),
      //       label: 'Messages',
      //     ),
      //   ],
      //   selectedItemColor:
      //       Theme.of(context).primaryColor, // Uses theme's primary color
      //   unselectedItemColor:
      //       Theme.of(context).disabledColor, // Uses theme's disabled color
      //   backgroundColor: Theme.of(context)
      //       .scaffoldBackgroundColor, // Matches app's background
      //   onTap: (index) {
      //     if (index == 3) {
      //       // Navigate to ChatPage when "Messages" icon is clicked
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => ChatbotPage()),
      //       );
      //       // } else {
      //       //   // Handle other navigation logic here
      //       //   print("Navigated to section: $index");
      //     } else if (index == 1) {
      //       //Navigate to CalendarPage when "Appointments" icon is clicked
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => SearchPatientPage()),
      //       );
      //       }
      //       else if (index == 2) {
      //       //Navigate to CalendarPage when "Appointments" icon is clicked
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => CalendarPage()),
      //       );
      //     } else if (index == 0) {
      //       //Navigate to CalendarPage when "Appointments" icon is clicked
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => AddPatientPage()),
      //       );
      //     } 
      //     else {
      //       // Handle other navigation logic here
      //       print("Navigated to section: $index");
      //     }
      //   },
      // ),
    );
  }
}
