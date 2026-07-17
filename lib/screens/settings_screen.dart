// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../services/history_service.dart'; // সেটিংস মেমোরিতে সেভ রাখার জন্য

class SettingsScreen extends StatefulWidget {
  final Function(Color) onChangeColor;
  const SettingsScreen({super.key, required this.onChangeColor});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // সুইচের জন্য ডাইনামিক স্টেট ভেরিয়েবলসমূহ
  bool _beepOnScan = true;
  bool _vibrate = false;
  bool _copyToClipboard = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // স্ক্রিন ওপেন হওয়ার সাথে সাথেই মেমোরি থেকে আগের সেটিংস লোড হবে
  }

  // ডাটাবেজ থেকে ইউজারের সেভ করা সেটিংস নিয়ে আসা
  Future<void> _loadSettings() async {
    final settings = await HistoryService.getAutoSettings();
    setState(() {
      _copyToClipboard = settings['autoCopy'] ?? true; 
      _beepOnScan = settings['autoOpen'] ?? true; 
    });
  }

  // কোনো সুইচ চেঞ্জ হওয়ার সাথে সাথে ডাটাবেজে পার্মানেন্টলি সেভ করা
  Future<void> _saveSettings() async {
    await HistoryService.setAutoSettings(
      _copyToClipboard, 
      _beepOnScan, 
    );
  }

  @override
  Widget build(BuildContext context) {
    // কালার স্কিমের জন্য রিফাইনড এবং স্ট্যান্ডার্ড ৮টি রঙের প্যালেট
    final List<Color> colorPalette = [
      Colors.blueAccent,
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.amber,
      Colors.greenAccent.shade400,
      Colors.tealAccent.shade700,
      Colors.purpleAccent,
      Colors.pinkAccent,
    ];

    final activeColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // মডার্ন আল্ট্রা-ডার্ক ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: const Text(
          'Settings', 
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. থিম কালার সেকশন হেডার
            const Text(
              'App Theme Color', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.3),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a color to personalize the application accent.', 
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 18),
            
            // অত্যন্ত প্রফেশনাল এবং ছোট সাইজের থিম কালার প্যালেট
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,         // প্রতি সারিতে ৪টি
                crossAxisSpacing: 16,      // গ্যাপ বাড়িয়ে বাটন ছোট করা হয়েছে
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,     // নিখুঁত বৃত্তাকার আকৃতি ধরে রাখতে
              ),
              itemCount: colorPalette.length,
              itemBuilder: (context, index) {
                final isSelected = activeColor.value == colorPalette[index].value;
                return GestureDetector(
                  onTap: () => widget.onChangeColor(colorPalette[index]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: colorPalette[index],
                      shape: BoxShape.circle, // সম্পূর্ণ বৃত্তাকার ডিজাইন
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3.5) // সুন্দর সাদা ডাবল বর্ডার ইফেক্ট
                          : Border.all(color: Colors.white10, width: 1),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorPalette[index].withOpacity(0.4), 
                                blurRadius: 10, 
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            const Divider(color: Colors.white10, thickness: 1.2),
            const SizedBox(height: 16),
            
            // ২. জেনারেল সেটিংস সেকশন হেডার
            const Text(
              'General Scan Settings', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.3),
            ),
            const SizedBox(height: 16),

            // প্রফেশনাল এবং ডাইনামিক সুইচের তালিকা
            _buildSettingsSwitch(
              title: 'Beep on scan',
              subtitle: 'Play a brief sound when code is successfully scanned',
              val: _beepOnScan,
              activeColor: activeColor,
              onChanged: (newValue) {
                setState(() => _beepOnScan = newValue);
                _saveSettings();
              },
            ),
            _buildSettingsSwitch(
              title: 'Vibrate',
              subtitle: 'Vibrate the device on a successful scan detection',
              val: _vibrate,
              activeColor: activeColor,
              onChanged: (newValue) {
                setState(() => _vibrate = newValue);
                _saveSettings();
              },
            ),
            _buildSettingsSwitch(
              title: 'Copy to clipboard',
              subtitle: 'Automatically copy scanned text results to system clipboard',
              val: _copyToClipboard,
              activeColor: activeColor,
              onChanged: (newValue) {
                setState(() => _copyToClipboard = newValue);
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  // মিনিমালিস্ট ও প্রফেশনাল ডাইনামিক সুইচ উইজেট
  Widget _buildSettingsSwitch({
    required String title,
    required String subtitle,
    required bool val,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // ডার্ক ম্যাট কার্ড ব্যাকগ্রাউন্ড
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        title: Text(
          title, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14.5),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle, 
            style: const TextStyle(color: Colors.white38, fontSize: 11.5, height: 1.3),
          ),
        ),
        trailing: Switch(
          value: val, 
          activeColor: activeColor,
          activeTrackColor: activeColor.withOpacity(0.3),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.white10,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

 //ndkVersion = "28.2.13676358"