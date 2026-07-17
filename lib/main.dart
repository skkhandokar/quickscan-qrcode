import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QRScannerApp());
}

class QRScannerApp extends StatefulWidget {
  const QRScannerApp({super.key});

  @override
  State<QRScannerApp> createState() => _QRScannerAppState();
}

class _QRScannerAppState extends State<QRScannerApp> {
  // ডিফোল্ট থিম কালার (ইউজার চাইলে পরে সেটিংস থেকে চেঞ্জ করতে পারবে)
  Color appPrimaryColor = Colors.blue;

  void changeThemeColor(Color newColor) {
    setState(() {
      appPrimaryColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shortfy Scanner',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: appPrimaryColor,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      ),
      // থিম চেঞ্জ করার ফাংশনটি স্ক্রিনে পাস করা হচ্ছে
      home: HomeScreen(onChangeColor: changeThemeColor),
    );
  }
}