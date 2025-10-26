import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:khyate_b2b/screens/onboarding_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAuyK0gsU6P1iH2zBfLTEKgbjEZx3z4k90",
        authDomain: "b2bproject-b2c91.firebaseapp.com",
        projectId: "b2bproject-b2c91",
        storageBucket: "b2bproject-b2c91.appspot.com",  // Corrected typo here!
        messagingSenderId: "264918662033",
        appId: "1:264918662033:web:3029cf068709e859307830",
        measurementId: "G-QV1XRTFJBX",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Khyate B2B',
      home: OnboardingScreen(),

    );
  }
}
