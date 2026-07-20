import 'package:flutter/material.dart';
import '../scan_result_screen.dart'; 
import '../../services/history_service.dart'; 

class WifiFormScreen extends StatefulWidget {
  const WifiFormScreen({super.key});

  @override
  State<WifiFormScreen> createState() => _WifiFormScreenState();
}

class _WifiFormScreenState extends State<WifiFormScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedSecurity = 'WPA/WPA2';
  bool _isHidden = false;

  void _generateWifiQR() async {
    final String ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Network Name (SSID)!")),
      );
      return;
    }
    
    String encryption = _selectedSecurity == 'no pass' ? 'nopass' : 'WPA';
    String qrData = "WIFI:S:$ssid;T:$encryption;P:${_passwordController.text};H:$_isHidden;;";
    final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

    // ডুপ্লিকেট কমানোর জন্য শুধুমাত্র একবার সাধারণ হিস্ট্রিতে সেভ
    await HistoryService.addToStorage(
      isMyQR: false,
      type: 'wifi',
      title: qrData,
      customId: commonId,
    );

    if (!mounted) return;

    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ScanResultScreen(
        rawValue: qrData,
        isBarcodeResult: false, 
        barcodeTypeTag: "",
        itemId: commonId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Create', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blueAccent, size: 28), 
            onPressed: _generateWifiQR,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: Colors.white70, size: 28),
                const SizedBox(width: 10),
                Text('Wifi', style: TextStyle(fontSize: 22, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _ssidController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'SSID/Network name',
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _selectedSecurity,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Security Type',
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              items: ['WPA/WPA2', 'WEP', 'no pass'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value, 
                  child: Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() { _selectedSecurity = newValue!; });
              },
            ),
            const SizedBox(height: 15),
            CheckboxListTile(
              title: const Text("Hidden", style: TextStyle(color: Colors.white70)),
              value: _isHidden,
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (bool? value) {
                setState(() { _isHidden = value!; });
              },
            )
          ],
        ),
      ),
    );
  }
}