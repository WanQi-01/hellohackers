import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'profile_page.dart';
import 'payment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // test firebase connection
  try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase connected successfully!');
  print('📁 Project ID: ${Firebase.app().options.projectId}');
} catch (e) {
  print('❌ Firebase connection failed: $e');
}

  // Initialize Firebase 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTC Medicine App',
      theme: ThemeData(
        // Medium blue as primary color
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF64B5F6), // Medium blue
        scaffoldBackgroundColor: Colors.white,
        
        // Color scheme
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: const Color(0xFF64B5F6), // Medium blue
          secondary: Colors.green,
          surface: Colors.white,
        ),
        
        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF64B5F6), // Medium blue app bar
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        
        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        
        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64B5F6), // Medium blue
          ),
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black54, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black45, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green, width: 2.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFF64B5F6)), // Medium blue
          prefixIconColor: const Color(0xFF64B5F6),
          suffixIconColor: const Color(0xFF64B5F6),
        ),
        
        // Card Theme
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          color: Colors.white,
        ),
        
        useMaterial3: true,
      ),
      home: const ProfilePage(), // Change to PaymentPage() to test payment page
      debugShowCheckedModeBanner: false,
    );
  }
}