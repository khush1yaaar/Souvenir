import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:souvenir/controllers/journal_controller.dart';
import 'package:souvenir/screens/get_started_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:souvenir/screens/home_screen.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthController());
  Get.put(JournalController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return snapshot.hasData ? HomeScreen() : const GetStartedScreen();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
