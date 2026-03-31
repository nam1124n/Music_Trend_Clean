import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/firebase_options.dart';
import 'package:login_flutter/ui/screen/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: SafeArea(child: Scaffold(body: LoginScreen())),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
