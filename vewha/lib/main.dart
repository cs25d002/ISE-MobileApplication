// FireBase Refernces
import 'package:firebase_core/firebase_core.dart';
// Flutter References
import 'package:flutter/material.dart';
import 'package:Vewha/Screens/Welcome/splash_screen.dart';
import 'package:Vewha/Components/constants.dart';
// Local Notifications
import 'package:timezone/data/latest_all.dart' as tz;
// Import Calendar Page

// wait till firebase is inittialized before rendering front end
void main() async {
  // try finding dynamic fet app details instead of manually setting
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with values from the .env file
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
      // home: const WelcomeScreen(), // using current spash screen crashes
      home:
          const SplashScreen(), // need to modify to keep login pages on top of HOME if user creds not found locally
    );
  }
}
