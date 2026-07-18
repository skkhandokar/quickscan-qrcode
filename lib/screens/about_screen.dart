







// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';

class AboutScreen extends StatelessWidget {
  final Function(Color) onChangeColor;
  const AboutScreen({super.key, required this.onChangeColor});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('About App', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(onChangeColor: onChangeColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // ক্লিন ও প্রফেশনাল হেডার (হলুদ লোগো রিমুভড)
            Text(
              'QuickScan QR & Barcode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Professional Scanner Utility  •  Version 1.0.0',
              style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 24),
            
            // Overview Section
            _buildSectionHeader('Overview'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: const Text(
                'QuickScan QR & Barcode is an all-in-one utility app designed for modern scanning and customized code generation. Built with a focus on speed, privacy, and offline capabilities, QuickScan lets you bridge physical information with the digital world in a single tap.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Features Section
            _buildSectionHeader('Core Features'),
            const SizedBox(height: 12),
            
            _buildFeatureTile('Super-Fast Scanning', 'Scan any QR Code or Barcode with instant decoding using the device camera. Control hardware zoom and flashlight directly from the scanning screen.'),
            _buildFeatureTile('Scan from Gallery', 'Select any image or screenshot from your gallery, and our built-in offline ML Kit will automatically detect and read the codes inside it.'),
            _buildFeatureTile('Advanced Bulk Scan Mode', 'Need to scan multiple items in a warehouse or store? Turn on Bulk Scan to scan continuously, save automatically to history, with haptic feedback.'),
            _buildFeatureTile('Custom QR Creator', 'Generate high-quality QR codes for WiFi, Contacts, SMS, Social Media, and Web links. Add central brand logos, change eye styles, and customize background colors!'),
            _buildFeatureTile('Multi-Format Barcode Generator', 'Create standard retail and shipping barcodes such as EAN-8, EAN-13, UPC-A, Code 128, Code 39, and ISBN directly from the generator portal.'),
            _buildFeatureTile('Smart History & Favorites', 'Never lose your scanned or generated codes. All data is stored locally with quick search, easy categorization, and a star favorite system.'),
            _buildFeatureTile('Smart Auto-Actions', 'Customize settings to auto-copy scanned texts directly to your clipboard or auto-open web links in your preferred browser instantly.'),
            
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '© 2026 QuickScan. All rights reserved.',
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  // প্রফেশনাল ও ক্লিন ফিচার টাইলস উইজেট
  Widget _buildFeatureTile(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}