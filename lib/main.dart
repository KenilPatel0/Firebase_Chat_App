import 'package:firebase_chat_app/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyC7Veb_C4XpXY71F0q2oUQCkkCzKYLrmVY",
            authDomain: "chat-app-1de97.firebaseapp.com",
            projectId: "chat-app-1de97",
            storageBucket: "chat-app-1de97.appspot.com",
            messagingSenderId: "8554553172",
            appId: "1:8554553172:web:57c42f9e667e21f3d272c1",
            measurementId: "G-36WKSFG4ZN"));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
