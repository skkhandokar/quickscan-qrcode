// lib/screens/form_screens/all_forms.dart
import 'package:flutter/material.dart';
import '../scan_result_screen.dart';
import '../../services/history_service.dart'; // ডাটাবেজ সার্ভিস ইম্পোর্ট করা হলো

class GenericFormScreen extends StatefulWidget {
  final String formType;
  final String title;
  final bool isBarcode;

  const GenericFormScreen({
    super.key, 
    required this.formType, 
    required this.title, 
    this.isBarcode = false,
  });

  @override
  State<GenericFormScreen> createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  final Map<String, TextEditingController> controllers = {};
  bool _isAllDay = false;
  bool _isHidden = false;
  String _wifiSecurity = 'WPA/WPA2';

  @override
  void initState() {
    super.initState();
    controllers['url'] = TextEditingController();
    controllers['text'] = TextEditingController();
    controllers['lat'] = TextEditingController();
    controllers['lon'] = TextEditingController();
    controllers['query'] = TextEditingController();
    controllers['email'] = TextEditingController();
    controllers['subject'] = TextEditingController();
    controllers['body'] = TextEditingController();
    controllers['event'] = TextEditingController();
    controllers['location'] = TextEditingController();
    controllers['desc'] = TextEditingController();
    controllers['name'] = TextEditingController();
    controllers['org'] = TextEditingController();
    controllers['address'] = TextEditingController();
    controllers['phone'] = TextEditingController();
    controllers['mail'] = TextEditingController();
    controllers['notes'] = TextEditingController();
    controllers['sms_phone'] = TextEditingController();
    controllers['sms_msg'] = TextEditingController();
    controllers['wifi_ssid'] = TextEditingController();
    controllers['wifi_pass'] = TextEditingController();
    controllers['phone_single'] = TextEditingController();
    controllers['barcode_input'] = TextEditingController();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitForm() async {
    String finalData = "";
    
    if (widget.isBarcode) {
      finalData = controllers['barcode_input']!.text.trim();
    } else {
      switch (widget.formType) {
        case 'url':
          finalData = controllers['url']!.text.trim();
          break;
        case 'text':
          finalData = controllers['text']!.text;
          break;
        case 'phone':
          finalData = "tel:${controllers['phone_single']!.text.trim()}";
          break;
        case 'geo':
          finalData = "geo:${controllers['lat']!.text.trim()},${controllers['lon']!.text.trim()}?q=${controllers['query']!.text.trim()}";
          break;
        case 'email':
          finalData = "MATMSG:TO:${controllers['email']!.text.trim()};SUB:${controllers['subject']!.text};BODY:${controllers['body']!.text};;";
          break;
        case 'calendar':
          finalData = "BEGIN:VEVENT\nSUMMARY:${controllers['event']!.text}\nLOCATION:${controllers['location']!.text}\nDESCRIPTION:${controllers['desc']!.text}\nEND:VEVENT";
          break;
        case 'contact':
          finalData = "MCARD:N:${controllers['name']!.text};ORG:${controllers['org']!.text};ADR:${controllers['address']!.text};TEL:${controllers['phone']!.text.trim()};EMAIL:${controllers['mail']!.text.trim()};NOTE:${controllers['notes']!.text};;";
          break;
        case 'sms':
          finalData = "smsto:${controllers['sms_phone']!.text.trim()}:${controllers['sms_msg']!.text}";
          break;
        case 'wifi':
          finalData = "WIFI:S:${controllers['wifi_ssid']!.text.trim()};T:$_wifiSecurity;P:${controllers['wifi_pass']!.text};H:$_isHidden;;";
          break;
      }
    }

    if (finalData.isNotEmpty) {
      // ইউনিক সাধারণ আইডি জেনারেশন (যা দুই তালিকাতেই সিঙ্ক থাকবে)
      final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

      // ১. My QR Code সেকশনে ডেটা পাঠানো হলো
      await HistoryService.addToStorage(
        isMyQR: true,
        type: widget.isBarcode ? 'barcode' : widget.formType,
        title: widget.isBarcode ? "Barcode: $finalData" : finalData,
        isBarcode: widget.isBarcode,
        barcodeTypeTag: widget.formType,
        customId: commonId,
      );

      // ২. History সেকশনেও ডেটা একই সাথে পাঠানো হলো
      await HistoryService.addToStorage(
        isMyQR: false,
        type: widget.isBarcode ? 'barcode' : widget.formType,
        title: widget.isBarcode ? "Barcode: $finalData" : finalData,
        isBarcode: widget.isBarcode,
        barcodeTypeTag: widget.formType,
        customId: commonId,
      );

      if (!mounted) return;

      // ৩. রেজাল্ট স্ক্রিনে রিডাইরেক্ট (স্টার ট্র্যাকিং এর জন্য itemId পাস করা হলো)
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          rawValue: finalData, 
          isBarcodeResult: widget.isBarcode,
          barcodeTypeTag: widget.formType,
          itemId: commonId,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some details first!')),
      );
    }
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
            onPressed: _submitForm,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.formType == 'wifi' ? Icons.wifi : widget.isBarcode ? Icons.reorder : Icons.edit, 
                  color: Theme.of(context).primaryColor,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title, 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 25),
            ..._buildFormFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    if (widget.isBarcode) {
      return [_customTextField(controllers['barcode_input']!, 'Enter Barcode Data/Number')];
    }
    if (widget.formType == 'wifi') { 
      return [
        _customTextField(controllers['wifi_ssid']!, 'SSID/Network name'),
        _customTextField(controllers['wifi_pass']!, 'Password', obscureText: true),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _wifiSecurity,
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Security Type',
            labelStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
          ),
          items: ['WPA/WPA2', 'WEP', 'no pass'].map((String value) {
            return DropdownMenuItem<String>(
              value: value, 
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() { _wifiSecurity = newValue!; });
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: _isHidden,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (bool? value) {
                setState(() { _isHidden = value!; });
              },
            ),
            const Text('Hidden Network', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ];
    }
    if (widget.formType == 'phone') {
      return [_customTextField(controllers['phone_single']!, 'Phone', keyboardType: TextInputType.phone)];
    }
    if (widget.formType == 'url' || widget.formType == 'text') {
      return [_customTextField(controllers[widget.formType]!, widget.formType == 'url' ? 'Enter Website URL' : 'Enter Text Content')];
    }
    if (widget.formType == 'geo') {
      return [
        _customTextField(controllers['lat']!, 'Latitude', keyboardType: TextInputType.number),
        _customTextField(controllers['lon']!, 'Longitude', keyboardType: TextInputType.number),
        _customTextField(controllers['query']!, 'Query (Optional)'),
      ];
    }
    if (widget.formType == 'email') {
      return [
        _customTextField(controllers['email']!, 'Email Address', keyboardType: TextInputType.emailAddress),
        _customTextField(controllers['subject']!, 'Subject'),
        _customTextField(controllers['body']!, 'Body message', maxLines: 5),
      ];
    }
    if (widget.formType == 'calendar') {
      return [
        _customTextField(controllers['event']!, 'Event name'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text("Start:\n2026-07-13   20:50\nEnd:\n2026-07-13   20:50", style: TextStyle(color: Colors.white70)),
        ),
        CheckboxListTile(
          title: const Text("All day event", style: TextStyle(color: Colors.white70)),
          value: _isAllDay,
          activeColor: Theme.of(context).primaryColor,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _isAllDay = v!),
        ),
        _customTextField(controllers['location']!, 'Location'),
        _customTextField(controllers['desc']!, 'Description', maxLines: 3),
      ];
    }
    if (widget.formType == 'contact') {
      return [
        _customTextField(controllers['name']!, 'Full name'),
        _customTextField(controllers['org']!, 'Organization'),
        _customTextField(controllers['address']!, 'Address'),
        _customTextField(controllers['phone']!, 'Phone Number', keyboardType: TextInputType.phone),
        _customTextField(controllers['mail']!, 'Email Address', keyboardType: TextInputType.emailAddress),
        _customTextField(controllers['notes']!, 'Notes/Remarks', maxLines: 4),
      ];
    }
    if (widget.formType == 'sms') {
      return [
        _customTextField(controllers['sms_phone']!, 'Recipient Phone', keyboardType: TextInputType.phone),
        _customTextField(controllers['sms_msg']!, 'SMS Message Body', maxLines: 5),
      ];
    }
    return [];
  }

  Widget _customTextField(
    TextEditingController controller, 
    String label, {
    int maxLines = 1, 
    bool obscureText = false, 
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );
  }
}