// FireBase Refernces
import 'package:firebase_core/firebase_core.dart';
// Flutter References
import 'package:flutter/material.dart';
import 'package:Vewha/Screens/Welcome/splash_screen.dart';
import 'package:Vewha/Components/constants.dart';
import 'package:Vewha/screens/patient_view/patient_entry_screen.dart';
// Local Notifications
import 'package:timezone/data/latest_all.dart' as tz;
// Import Calendar Page

// wait till firebase is inittialized before rendering front end
void main() async {
  // try finding dynamic fet app details instead of manually setting
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with values from the .env file (only if not in patient mode)
  const bool isPatient = String.fromEnvironment('MODE') == 'patient' || 
                         bool.fromEnvironment('patient_mode', defaultValue: false);
  if (!isPatient) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:
            "AIzaSyAMcCCh44Cz2uBdnHAu7TXQ74BtmKv6YKQ", // "api_key:current_key here",
        appId:
            "1:838890390964:android:1f625e152497dd2caadee1", // "mobilesdk_app_id here",
        messagingSenderId: "838890390964", // "project_number id here",
        projectId: "vewha-2d3a2", // "project id here",
      ),
    );
  }

  // Initialize Timezones (Required for scheduling notifications)
  tz.initializeTimeZones();

  //Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vewha',
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding:
                EdgeInsets.symmetric(horizontal: pad_norm, vertical: pad_norm),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )),
      home: (const String.fromEnvironment('MODE') == 'patient' ||
              const bool.fromEnvironment('patient_mode', defaultValue: false))
          ? const PatientEntryScreen()
          : const SplashScreen(),
    );
  }
}
