import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  const PrescriptionDetailsScreen({super.key});

  @override
  _PrescriptionDetailsScreenState createState() =>
      _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  // Replace with actual YouTube Video IDs
  final String healthyVideoId = "wyiJw034ssA"; // Your provided YouTube video ID
  final String diseasedVideoId = "aBcDeFgH12"; // Replace this with another video ID

  late YoutubePlayerController healthyController;
  late YoutubePlayerController diseasedController;

  @override
  void initState() {
    super.initState();
    healthyController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    )..loadVideoById(videoId: healthyVideoId);

    diseasedController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    )..loadVideoById(videoId: diseasedVideoId);
  }

  @override
  void dispose() {
    healthyController.close();
    diseasedController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient EHR"),
        backgroundColor: Colors.purple[300],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientCard(),
            _buildPrescriptionDetails(),
            const SizedBox(height: 20),
            _buildHealthVisualization(),
            const SizedBox(height: 20),
            _buildComparisonVideos(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Patient Name: Zahidul Haque",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Age: 37"),
              Text("Condition: Knee Pain"),
              Text("Doctor's Advice: X-ray, Physiotherapy"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: const [
            ListTile(
              title: Text("Tablet: Ultra-fin Plus"),
              subtitle: Text("Dosage: 0+0+1"),
              leading: Icon(Icons.medication, color: Colors.purple),
            ),
            ListTile(
              title: Text("Tablet: Rebustine"),
              subtitle: Text("Dosage: 0+1+0"),
              leading: Icon(Icons.medical_services, color: Colors.purple),
            ),
            ListTile(
              title: Text("Capsule: Romphos"),
              subtitle: Text("Dosage: 1 daily"),
              leading: Icon(Icons.medication_liquid, color: Colors.purple),
            ),
            ListTile(
              title: Text("Tablet: Ultraheal-D"),
              subtitle: Text("Dosage: 0+0+1"),
              leading: Icon(Icons.medication, color: Colors.purple),
            ),
            ListTile(
              title: Text("Tablet: Cartilage"),
              subtitle: Text("Dosage: 0+0+1"),
              leading: Icon(Icons.healing, color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthVisualization() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Health Condition Visualization",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: YoutubePlayer(
              controller: healthyController,
              aspectRatio: 16 / 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonVideos() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Comparison: Healthy vs Diseased State",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text("Healthy Knee",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 150,
                    height: 100,
                    child: YoutubePlayer(
                      controller: healthyController,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  const Text("Diseased Knee",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 150,
                    height: 100,
                    child: YoutubePlayer(
                      controller: diseasedController,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
