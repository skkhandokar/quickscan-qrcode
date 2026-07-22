


// // lib/screens/form_screens/generic_form_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart'; // গ্যালারি থেকে ছবি সিলেক্টের জন্য
// import 'dart:io';
// import 'dart:convert';
// import './scan_result_screen.dart';
// import '../../services/history_service.dart'; 

// class GenericFormScreen extends StatefulWidget {
//   final String formType;
//   final String title;
//   final bool isBarcode;

//   const GenericFormScreen({
//     super.key, 
//     required this.formType, 
//     required this.title, 
//     this.isBarcode = false,
//   });

//   @override
//   State<GenericFormScreen> createState() => _GenericFormScreenState();
// }

// class _GenericFormScreenState extends State<GenericFormScreen> {
//   final Map<String, TextEditingController> controllers = {};
//   bool _isAllDay = false;
//   bool _isHidden = false;
//   String _wifiSecurity = 'WPA/WPA2';

//   Color selectedQrColor = Colors.black;
//   Color selectedBgColor = Colors.white;

//   // --- নতুন যুক্ত করা কাস্টম লোগো ভেরিয়েবলসমূহ ---
//   File? _customLogoFile;
//   final ImagePicker _picker = ImagePicker();

//   final List<Color> qrColors = [
//     Colors.black, Colors.blue.shade900, Colors.red.shade900, Colors.green.shade900, Colors.purple.shade900, Colors.teal.shade900
//   ];
//   final List<Color> bgColors = [
//     Colors.white, Colors.amber.shade50, Colors.blue.shade50, Colors.grey.shade200
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initControllers();
//     if (widget.formType == 'text' || widget.formType == 'url') {
//       _autoPasteFromClipboard();
//     }
//   }

//   void _initControllers() {
//     controllers['url'] = TextEditingController(text: 'https://');
//     controllers['text'] = TextEditingController();
//     controllers['lat'] = TextEditingController();
//     controllers['lon'] = TextEditingController();
//     controllers['query'] = TextEditingController();
//     controllers['email'] = TextEditingController();
//     controllers['subject'] = TextEditingController();
//     controllers['body'] = TextEditingController();
//     controllers['event'] = TextEditingController();
//     controllers['location'] = TextEditingController();
//     controllers['desc'] = TextEditingController();
//     controllers['name'] = TextEditingController();
//     controllers['org'] = TextEditingController();
//     controllers['address'] = TextEditingController();
//     controllers['phone'] = TextEditingController();
//     controllers['mail'] = TextEditingController();
//     controllers['notes'] = TextEditingController();
//     controllers['sms_phone'] = TextEditingController();
//     controllers['sms_msg'] = TextEditingController();
//     controllers['wifi_ssid'] = TextEditingController();
//     controllers['wifi_pass'] = TextEditingController();
//     controllers['phone_single'] = TextEditingController();
//     controllers['barcode_input'] = TextEditingController();
//   }

//   @override
//   void dispose() {
//     for (var controller in controllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _autoPasteFromClipboard() async {
//     ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
//     if (data != null && data.text != null && data.text!.isNotEmpty) {
//       String copiedText = data.text!.trim();
//       setState(() {
//         if (widget.formType == 'url') {
//           if (copiedText.startsWith('http://') || copiedText.startsWith('https://')) {
//             controllers['url']!.text = copiedText;
//           }
//         } else if (widget.formType == 'text') {
//           controllers['text']!.text = copiedText;
//         }
//       });
//     }
//   }

//   // গ্যালারি থেকে কাস্টম লোগো সিলেক্ট করার মেথড
//   Future<void> _pickCustomLogo() async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _customLogoFile = File(pickedFile.path);
//       });
//     }
//   }

//   // সিলেক্ট করা কাস্টম লোগো রিমুভ করার মেথড
//   void _removeCustomLogo() {
//     setState(() {
//       _customLogoFile = null;
//     });
//   }

//   // --- ফিচার ৩: এপিআই দিয়ে লিংক শর্ট (Dynamic QR) করার লজিক ---
//   Future<String> _shortenUrl(String longUrl) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://cleanuri.com/api/v1/shorten'),
//         body: {'url': longUrl},
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['result_url'] ?? longUrl;
//       }
//     } catch (e) {
//       print("Shortening error: $e");
//     }
//     return longUrl; 
//   }

//   bool _isValidUrl(String url) {
//     final pattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
//     return RegExp(pattern, caseSensitive: false).hasMatch(url) && url != 'https://' && url != 'http://';
//   }

//   void _submitForm() async {
//     String finalData = "";
    
//     if (widget.isBarcode) {
//       finalData = controllers['barcode_input']!.text.trim();
//     } else {
//       switch (widget.formType) {
//         case 'url':
//           final String urlInput = controllers['url']!.text.trim();
//           if (!_isValidUrl(urlInput)) {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text('Please enter a valid website URL!')));
//             return;
//           }

//           // ফিচার ৩ প্রম্পট ডায়ালগ
//           bool? makeDynamic = await showDialog<bool>(
//             context: context,
//             builder: (context) => AlertDialog(
//               backgroundColor: const Color(0xFF1E1E1E),
//               title: const Text('Dynamic QR Code?', style: TextStyle(color: Colors.white)),
//               content: const Text('Do you want to shorten this URL to make the QR code cleaner and faster to scan?', style: TextStyle(color: Colors.white70)),
//               actions: [
//                 TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No, Static')),
//                 TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Shorten')),
//               ],
//             ),
//           );

//           String processedUrl = urlInput;
//           if (makeDynamic == true) {
//             if (!mounted) return;
//             showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
//             processedUrl = await _shortenUrl(urlInput);
//             if (!mounted) return;
//             Navigator.pop(context); // লোডিং রিমুভ
//           }
//           finalData = processedUrl;
//           break;

//         case 'text': finalData = controllers['text']!.text; break;
//         case 'phone': finalData = "tel:${controllers['phone_single']!.text.trim()}"; break;
//         case 'wifi': finalData = "WIFI:S:${controllers['wifi_ssid']!.text.trim()};T:$_wifiSecurity;P:${controllers['wifi_pass']!.text};H:$_isHidden;;"; break;
//         case 'email': finalData = "MATMSG:TO:${controllers['email']!.text.trim()};SUB:${controllers['subject']!.text};BODY:${controllers['body']!.text};;"; break;
//         case 'geo': finalData = "geo:${controllers['lat']!.text.trim()},${controllers['lon']!.text.trim()}?q=${controllers['query']!.text.trim()}"; break;
//         case 'calendar': finalData = "BEGIN:VEVENT\nSUMMARY:${controllers['event']!.text}\nLOCATION:${controllers['location']!.text}\nDESCRIPTION:${controllers['desc']!.text}\nEND:VEVENT"; break;
//         case 'contact': finalData = "MCARD:N:${controllers['name']!.text};ORG:${controllers['org']!.text};ADR:${controllers['address']!.text};TEL:${controllers['phone']!.text.trim()};EMAIL:${controllers['mail']!.text.trim()};NOTE:${controllers['notes']!.text};;"; break;
//         case 'sms': finalData = "smsto:${controllers['sms_phone']!.text.trim()}:${controllers['sms_msg']!.text}"; break;
//       }
//     }

//     if (finalData.isNotEmpty) {
//       final String commonId = DateTime.now().millisecondsSinceEpoch.toString();
//       await HistoryService.addToStorage(
//         isMyQR: true, // ইউজারের নিজের তৈরি তাই true সেট করা হলো
//         type: widget.isBarcode ? 'barcode' : widget.formType,
//         title: widget.isBarcode ? "Barcode: $finalData" : finalData,
//         isBarcode: widget.isBarcode,
//         barcodeTypeTag: widget.formType,
//         customId: commonId,
//       );

//       if (!mounted) return;
//       Navigator.push(context, MaterialPageRoute(
//         builder: (context) => ScanResultScreen(
//           rawValue: finalData, 
//           isBarcodeResult: widget.isBarcode,
//           barcodeTypeTag: widget.formType,
//           itemId: commonId,
//           qrColor: selectedQrColor, 
//           qrBgColor: selectedBgColor, 
//           customLogoPath: _customLogoFile?.path, // কাস্টম লোগো ফাইলটির লোকাল পাথ পাঠানো হলো
//         ),
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Theme.of(context).primaryColor;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Create', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [IconButton(icon: const Icon(Icons.check, color: Colors.blueAccent, size: 28), onPressed: _submitForm)],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(widget.formType == 'wifi' ? Icons.wifi : widget.isBarcode ? Icons.reorder : Icons.edit, color: primaryColor, size: 28),
//                     const SizedBox(width: 12),
//                     Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
//                   ],
//                 ),
//                 if (widget.formType == 'text' || widget.formType == 'url')
//                   IconButton(
//                     icon: const Icon(Icons.assignment_turned_in_outlined, color: Colors.greenAccent),
//                     onPressed: () {
//                       _autoPasteFromClipboard();
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied text pasted! 📋'), duration: Duration(seconds: 1)));
//                     },
//                   )
//               ],
//             ),
//             const SizedBox(height: 25),
//             ..._buildFormFields(),

//             // --- নতুন ফিচার: "Choose Logo" কাস্টম ডিজাইন উইজেট (শুধুমাত্র QR কোডের জন্য) ---
//             if (!widget.isBarcode) ...[
//               const Divider(color: Colors.white24, height: 40),
//               const Text(
//                 'Add Central Brand Logo',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1C1C1E), // ডার্ক থিমের সাথে ম্যাচিং কার্ড ডিজাইন
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.white.withOpacity(0.05)),
//                 ),
//                 child: Row(
//                   children: [
//                     // লোগো সিলেকশনের লাইভ প্রিভিউ বক্স
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.black26,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.white12),
//                       ),
//                       child: _customLogoFile != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.file(_customLogoFile!, fit: BoxFit.cover),
//                             )
//                           : const Icon(Icons.add_photo_alternate_outlined, color: Colors.white30, size: 28),
//                     ),
//                     const SizedBox(width: 16),
                    
//                     // ডাইনামিক বাটন লজিক
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ElevatedButton.icon(
//                             onPressed: _pickCustomLogo,
//                             icon: const Icon(Icons.file_upload_outlined, size: 16, color: Colors.white),
//                             label: Text(
//                               _customLogoFile == null ? 'Choose Logo' : 'Change Logo',
//                               style: const TextStyle(fontSize: 12, color: Colors.white),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                             ),
//                           ),
//                           if (_customLogoFile != null) ...[
//                             const SizedBox(height: 6),
//                             GestureDetector(
//                               onTap: _removeCustomLogo,
//                               child: const Text(
//                                 'Remove Logo',
//                                 style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],

//             if (!widget.isBarcode) ...[
//               const Divider(color: Colors.white24, height: 40),
//               const Text('QR Code Customizer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 15),
//               _buildColorPicker('QR Code Color:', qrColors, true),
//               const SizedBox(height: 20),
//               _buildColorPicker('Background Color:', bgColors, false),
//             ]
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildColorPicker(String label, List<Color> colors, bool isQrColor) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 40,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: colors.length,
//             itemBuilder: (context, index) {
//               final color = colors[index];
//               final isSelected = isQrColor ? selectedQrColor == color : selectedBgColor == color;
//               return GestureDetector(
//                 onTap: () => setState(() => isQrColor ? selectedQrColor = color : selectedBgColor = color),
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 12),
//                   width: 40,
//                   decoration: BoxDecoration(
//                     color: color,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: isSelected ? Colors.blue : Colors.white24, width: isSelected ? 3 : 1),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   List<Widget> _buildFormFields() {
//     if (widget.isBarcode) return [_customTextField(controllers['barcode_input']!, 'Enter Barcode Data')];
//     switch (widget.formType) {
//       case 'url': return [_customTextField(controllers['url']!, 'Enter Website URL', keyboardType: TextInputType.url)];
//       case 'text': return [_customTextField(controllers['text']!, 'Enter Text Content', maxLines: 5)];
//       case 'phone': return [_customTextField(controllers['phone_single']!, 'Phone', keyboardType: TextInputType.phone)];
//       case 'wifi':
//         return [
//           _customTextField(controllers['wifi_ssid']!, 'SSID/Network name'),
//           _customTextField(controllers['wifi_pass']!, 'Password', obscureText: true),
//           DropdownButtonFormField<String>(
//             initialValue: _wifiSecurity,
//             dropdownColor: const Color(0xFF1E1E1E),
//             style: const TextStyle(color: Colors.white),
//             decoration: const InputDecoration(labelText: 'Security Type', labelStyle: TextStyle(color: Colors.white54), border: OutlineInputBorder()),
//             items: ['WPA/WPA2', 'WEP', 'no pass'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
//             onChanged: (v) => setState(() => _wifiSecurity = v!),
//           ),
//           Row(children: [Checkbox(value: _isHidden, onChanged: (v) => setState(() => _isHidden = v!)), const Text('Hidden Network', style: TextStyle(color: Colors.white70))]),
//         ];
//       case 'email':
//         return [
//           _customTextField(controllers['email']!, 'Email Address', keyboardType: TextInputType.emailAddress),
//           _customTextField(controllers['subject']!, 'Subject'),
//           _customTextField(controllers['body']!, 'Body message', maxLines: 5),
//         ];
//       case 'geo':
//         return [
//           _customTextField(controllers['lat']!, 'Latitude', keyboardType: TextInputType.number),
//           _customTextField(controllers['lon']!, 'Longitude', keyboardType: TextInputType.number),
//           _customTextField(controllers['query']!, 'Query (Optional)'),
//         ];
//       case 'calendar':
//         return [
//           _customTextField(controllers['event']!, 'Event name'),
//           CheckboxListTile(title: const Text("All day event", style: TextStyle(color: Colors.white70)), value: _isAllDay, controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => _isAllDay = v!)),
//           _customTextField(controllers['location']!, 'Location'),
//           _customTextField(controllers['desc']!, 'Description', maxLines: 3),
//         ];
//       case 'contact':
//         return [
//           _customTextField(controllers['name']!, 'Full name'),
//           _customTextField(controllers['org']!, 'Organization'),
//           _customTextField(controllers['address']!, 'Address'),
//           _customTextField(controllers['phone']!, 'Phone Number', keyboardType: TextInputType.phone),
//           _customTextField(controllers['mail']!, 'Email Address', keyboardType: TextInputType.emailAddress),
//           _customTextField(controllers['notes']!, 'Notes/Remarks', maxLines: 4),
//         ];
//       case 'sms':
//         return [
//           _customTextField(controllers['sms_phone']!, 'Recipient Phone', keyboardType: TextInputType.phone),
//           _customTextField(controllers['sms_msg']!, 'SMS Message Body', maxLines: 5),
//         ];
//       default: return [];
//     }
//   }

//   Widget _customTextField(TextEditingController controller, String label, {int maxLines = 1, bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15.0),
//       child: TextField(
//         controller: controller,
//         maxLines: maxLines,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label, labelStyle: const TextStyle(color: Colors.white54),
//           border: const OutlineInputBorder(),
//           enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
//           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
//         ),
//       ),
//     );
//   }
// }














// lib/screens/form_screens/generic_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // গ্যালারি থেকে ছবি সিলেক্টের জন্য
import 'dart:io';
import 'dart:convert';
import './scan_result_screen.dart';
import '../../services/history_service.dart'; 

class GenericFormScreen extends StatefulWidget {
  final String formType;
  final String title;
  final bool isBarcode;
  final String? initialData; // <-- এখানে ফিল্ডটি যোগ করতে হবে

  const GenericFormScreen({
    super.key, 
    required this.formType, 
    required this.title, 
    this.isBarcode = false,
    this.initialData, // <-- এখানে কনস্ট্রাক্টরে পারামিটারটি ডিফাইন করা হলো
  });

  @override
  State<GenericFormScreen> createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends State<GenericFormScreen> {
  final Map<String, TextEditingController> controllers = {};
  bool _isAllDay = false;
  bool _isHidden = false;
  String _wifiSecurity = 'WPA/WPA2';

  Color selectedQrColor = Colors.black;
  Color selectedBgColor = Colors.white;

  // --- নতুন যুক্ত করা কাস্টম লোগো ভেরিয়েবলসমূহ ---
  File? _customLogoFile;
  final ImagePicker _picker = ImagePicker();

  final List<Color> qrColors = [
    Colors.black, Colors.blue.shade900, Colors.red.shade900, Colors.green.shade900, Colors.purple.shade900, Colors.teal.shade900
  ];
  final List<Color> bgColors = [
    Colors.white, Colors.amber.shade50, Colors.blue.shade50, Colors.grey.shade200
  ];

@override
  void initState() {
    super.initState();
    _initControllers();

    // এডিট মোড হলে আগের তথ্য দিয়ে ঘরগুলো পূরণ হবে
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _populateInitialData(widget.initialData!);
    } else if (widget.formType == 'text' || widget.formType == 'url') {
      _autoPasteFromClipboard();
    }
  }

  void _populateInitialData(String rawData) {
    if (widget.isBarcode) {
      controllers['barcode_input']!.text = rawData.replaceAll('Barcode: ', '');
      return;
    }

    switch (widget.formType) {
      case 'url':
        controllers['url']!.text = rawData;
        break;

      case 'text':
        controllers['text']!.text = rawData;
        break;

      case 'phone':
        controllers['phone_single']!.text = rawData.replaceAll('tel:', '');
        break;

      case 'wifi':
        // WIFI:S:MyWifi;T:WPA;P:123456;H:false;; পার্সিং
        String cleanData = rawData.replaceFirst('WIFI:', '');
        List<String> parts = cleanData.split(';');
        for (var part in parts) {
          if (part.startsWith('S:')) {
            controllers['wifi_ssid']!.text = part.substring(2);
          } else if (part.startsWith('P:')) {
            controllers['wifi_pass']!.text = part.substring(2);
          } else if (part.startsWith('T:')) {
            String sec = part.substring(2).toUpperCase();
            if (sec == 'NOPASS') {
              _wifiSecurity = 'no pass';
            } else if (sec == 'WEP') {
              _wifiSecurity = 'WEP';
            } else {
              _wifiSecurity = 'WPA/WPA2';
            }
          } else if (part.startsWith('H:')) {
            _isHidden = part.substring(2).toLowerCase() == 'true';
          }
        }
        break;

      case 'email':
        if (rawData.startsWith('MATMSG:')) {
          RegExp toExp = RegExp(r'TO:(.*?);');
          RegExp subExp = RegExp(r'SUB:(.*?);');
          RegExp bodyExp = RegExp(r'BODY:(.*?);;');
          
          if (toExp.hasMatch(rawData)) controllers['email']!.text = toExp.firstMatch(rawData)!.group(1) ?? '';
          if (subExp.hasMatch(rawData)) controllers['subject']!.text = subExp.firstMatch(rawData)!.group(1) ?? '';
          if (bodyExp.hasMatch(rawData)) controllers['body']!.text = bodyExp.firstMatch(rawData)!.group(1) ?? '';
        } else if (rawData.startsWith('mailto:')) {
          controllers['email']!.text = rawData.replaceAll('mailto:', '');
        }
        break;

      case 'sms':
        String cleanSms = rawData.replaceAll('smsto:', '');
        List<String> smsParts = cleanSms.split(':');
        if (smsParts.isNotEmpty) controllers['sms_phone']!.text = smsParts[0];
        if (smsParts.length > 1) controllers['sms_msg']!.text = smsParts[1];
        break;

        
      case 'contact':
        RegExp nameExp = RegExp(r'N:(.*?);');
        RegExp orgExp = RegExp(r'ORG:(.*?);');
        RegExp adrExp = RegExp(r'ADR:(.*?);');
        RegExp telExp = RegExp(r'TEL:(.*?);');
        RegExp mailExp = RegExp(r'EMAIL:(.*?);');
        RegExp noteExp = RegExp(r'NOTE:(.*?);;'); // <-- এখানে ভুল স্পেলিং ফিক্স করা হয়েছে

        if (nameExp.hasMatch(rawData)) controllers['name']!.text = nameExp.firstMatch(rawData)!.group(1) ?? '';
        if (orgExp.hasMatch(rawData)) controllers['org']!.text = orgExp.firstMatch(rawData)!.group(1) ?? '';
        if (adrExp.hasMatch(rawData)) controllers['address']!.text = adrExp.firstMatch(rawData)!.group(1) ?? '';
        if (telExp.hasMatch(rawData)) controllers['phone']!.text = telExp.firstMatch(rawData)!.group(1) ?? '';
        if (mailExp.hasMatch(rawData)) controllers['mail']!.text = mailExp.firstMatch(rawData)!.group(1) ?? '';
        if (noteExp.hasMatch(rawData)) controllers['notes']!.text = noteExp.firstMatch(rawData)!.group(1) ?? '';
        break;
    }
  }

  void _initControllers() {
    controllers['url'] = TextEditingController(text: 'https://');
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

  Future<void> _autoPasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      String copiedText = data.text!.trim();
      setState(() {
        if (widget.formType == 'url') {
          if (copiedText.startsWith('http://') || copiedText.startsWith('https://')) {
            controllers['url']!.text = copiedText;
          }
        } else if (widget.formType == 'text') {
          controllers['text']!.text = copiedText;
        }
      });
    }
  }

  // গ্যালারি থেকে কাস্টম লোগো সিলেক্ট করার মেথড
  Future<void> _pickCustomLogo() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _customLogoFile = File(pickedFile.path);
      });
    }
  }

  // সিলেক্ট করা কাস্টম লোগো রিমুভ করার মেথড
  void _removeCustomLogo() {
    setState(() {
      _customLogoFile = null;
    });
  }

  // --- ফিচার ৩: এপিআই দিয়ে লিংক শর্ট (Dynamic QR) করার লজিক ---
  Future<String> _shortenUrl(String longUrl) async {
    try {
      final response = await http.post(
        Uri.parse('https://cleanuri.com/api/v1/shorten'),
        body: {'url': longUrl},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result_url'] ?? longUrl;
      }
    } catch (e) {
      print("Shortening error: $e");
    }
    return longUrl; 
  }

  bool _isValidUrl(String url) {
    final pattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
    return RegExp(pattern, caseSensitive: false).hasMatch(url) && url != 'https://' && url != 'http://';
  }

  void _submitForm() async {
    String finalData = "";
    
    if (widget.isBarcode) {
      finalData = controllers['barcode_input']!.text.trim();
    } else {
      switch (widget.formType) {
        case 'url':
          final String urlInput = controllers['url']!.text.trim();
          if (!_isValidUrl(urlInput)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text('Please enter a valid website URL!')));
            return;
          }

          // ফিচার ৩ প্রম্পট ডায়ালগ
          bool? makeDynamic = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Dynamic QR Code?', style: TextStyle(color: Colors.white)),
              content: const Text('Do you want to shorten this URL to make the QR code cleaner and faster to scan?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No, Static')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Shorten')),
              ],
            ),
          );

          String processedUrl = urlInput;
          if (makeDynamic == true) {
            if (!mounted) return;
            showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
            processedUrl = await _shortenUrl(urlInput);
            if (!mounted) return;
            Navigator.pop(context); // লোডিং রিমুভ
          }
          finalData = processedUrl;
          break;

        case 'text': finalData = controllers['text']!.text; break;
        case 'phone': finalData = "tel:${controllers['phone_single']!.text.trim()}"; break;
        case 'wifi': finalData = "WIFI:S:${controllers['wifi_ssid']!.text.trim()};T:$_wifiSecurity;P:${controllers['wifi_pass']!.text};H:$_isHidden;;"; break;
        case 'email': finalData = "MATMSG:TO:${controllers['email']!.text.trim()};SUB:${controllers['subject']!.text};BODY:${controllers['body']!.text};;"; break;
        case 'geo': finalData = "geo:${controllers['lat']!.text.trim()},${controllers['lon']!.text.trim()}?q=${controllers['query']!.text.trim()}"; break;
        case 'calendar': finalData = "BEGIN:VEVENT\nSUMMARY:${controllers['event']!.text}\nLOCATION:${controllers['location']!.text}\nDESCRIPTION:${controllers['desc']!.text}\nEND:VEVENT"; break;
        case 'contact': finalData = "MCARD:N:${controllers['name']!.text};ORG:${controllers['org']!.text};ADR:${controllers['address']!.text};TEL:${controllers['phone']!.text.trim()};EMAIL:${controllers['mail']!.text.trim()};NOTE:${controllers['notes']!.text};;"; break;
        case 'sms': finalData = "smsto:${controllers['sms_phone']!.text.trim()}:${controllers['sms_msg']!.text}"; break;
      }
    }

    if (finalData.isNotEmpty) {
      final String commonId = DateTime.now().millisecondsSinceEpoch.toString();
      await HistoryService.addToStorage(
        isMyQR: true, // ইউজারের নিজের তৈরি তাই true সেট করা হলো
        type: widget.isBarcode ? 'barcode' : widget.formType,
        title: widget.isBarcode ? "Barcode: $finalData" : finalData,
        isBarcode: widget.isBarcode,
        barcodeTypeTag: widget.formType,
        customId: commonId,
      );

      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          rawValue: finalData, 
          isBarcodeResult: widget.isBarcode,
          barcodeTypeTag: widget.formType,
          itemId: commonId,
          qrColor: selectedQrColor, 
          qrBgColor: selectedBgColor, 
          customLogoPath: _customLogoFile?.path, // কাস্টম লোগো ফাইলটির লোকাল পাথ পাঠানো হলো
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Create', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.check, color: Colors.blueAccent, size: 28), onPressed: _submitForm)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.formType == 'wifi' ? Icons.wifi : widget.isBarcode ? Icons.reorder : Icons.edit, color: primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                if (widget.formType == 'text' || widget.formType == 'url')
                  IconButton(
                    icon: const Icon(Icons.assignment_turned_in_outlined, color: Colors.greenAccent),
                    onPressed: () {
                      _autoPasteFromClipboard();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied text pasted! 📋'), duration: Duration(seconds: 1)));
                    },
                  )
              ],
            ),
            const SizedBox(height: 25),
            ..._buildFormFields(),

            // --- নতুন ফিচার: "Choose Logo" কাস্টম ডিজাইন উইজেট (শুধুমাত্র QR কোডের জন্য) ---
            if (!widget.isBarcode) ...[
              const Divider(color: Colors.white24, height: 40),
              const Text(
                'Add Central Brand Logo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E), // ডার্ক থিমের সাথে ম্যাচিং কার্ড ডিজাইন
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    // লোগো সিলেকশনের লাইভ প্রিভিউ বক্স
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: _customLogoFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_customLogoFile!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.add_photo_alternate_outlined, color: Colors.white30, size: 28),
                    ),
                    const SizedBox(width: 16),
                    
                    // ডাইনামিক বাটন লজিক
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickCustomLogo,
                            icon: const Icon(Icons.file_upload_outlined, size: 16, color: Colors.white),
                            label: Text(
                              _customLogoFile == null ? 'Choose Logo' : 'Change Logo',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                          if (_customLogoFile != null) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _removeCustomLogo,
                              child: const Text(
                                'Remove Logo',
                                style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (!widget.isBarcode) ...[
              const Divider(color: Colors.white24, height: 40),
              const Text('QR Code Customizer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildColorPicker('QR Code Color:', qrColors, true),
              const SizedBox(height: 20),
              _buildColorPicker('Background Color:', bgColors, false),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(String label, List<Color> colors, bool isQrColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = isQrColor ? selectedQrColor == color : selectedBgColor == color;
              return GestureDetector(
                onTap: () => setState(() => isQrColor ? selectedQrColor = color : selectedBgColor = color),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? Colors.blue : Colors.white24, width: isSelected ? 3 : 1),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields() {
    if (widget.isBarcode) return [_customTextField(controllers['barcode_input']!, 'Enter Barcode Data')];
    switch (widget.formType) {
      case 'url': return [_customTextField(controllers['url']!, 'Enter Website URL', keyboardType: TextInputType.url)];
      case 'text': return [_customTextField(controllers['text']!, 'Enter Text Content', maxLines: 5)];
      case 'phone': return [_customTextField(controllers['phone_single']!, 'Phone', keyboardType: TextInputType.phone)];
      case 'wifi':
        return [
          _customTextField(controllers['wifi_ssid']!, 'SSID/Network name'),
          _customTextField(controllers['wifi_pass']!, 'Password', obscureText: true),
          DropdownButtonFormField<String>(
            initialValue: _wifiSecurity,
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Security Type', labelStyle: TextStyle(color: Colors.white54), border: OutlineInputBorder()),
            items: ['WPA/WPA2', 'WEP', 'no pass'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _wifiSecurity = v!),
          ),
          Row(children: [Checkbox(value: _isHidden, onChanged: (v) => setState(() => _isHidden = v!)), const Text('Hidden Network', style: TextStyle(color: Colors.white70))]),
        ];
      case 'email':
        return [
          _customTextField(controllers['email']!, 'Email Address', keyboardType: TextInputType.emailAddress),
          _customTextField(controllers['subject']!, 'Subject'),
          _customTextField(controllers['body']!, 'Body message', maxLines: 5),
        ];
      case 'geo':
        return [
          _customTextField(controllers['lat']!, 'Latitude', keyboardType: TextInputType.number),
          _customTextField(controllers['lon']!, 'Longitude', keyboardType: TextInputType.number),
          _customTextField(controllers['query']!, 'Query (Optional)'),
        ];
      case 'calendar':
        return [
          _customTextField(controllers['event']!, 'Event name'),
          CheckboxListTile(title: const Text("All day event", style: TextStyle(color: Colors.white70)), value: _isAllDay, controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero, onChanged: (v) => setState(() => _isAllDay = v!)),
          _customTextField(controllers['location']!, 'Location'),
          _customTextField(controllers['desc']!, 'Description', maxLines: 3),
        ];
      case 'contact':
        return [
          _customTextField(controllers['name']!, 'Full name'),
          _customTextField(controllers['org']!, 'Organization'),
          _customTextField(controllers['address']!, 'Address'),
          _customTextField(controllers['phone']!, 'Phone Number', keyboardType: TextInputType.phone),
          _customTextField(controllers['mail']!, 'Email Address', keyboardType: TextInputType.emailAddress),
          _customTextField(controllers['notes']!, 'Notes/Remarks', maxLines: 4),
        ];
      case 'sms':
        return [
          _customTextField(controllers['sms_phone']!, 'Recipient Phone', keyboardType: TextInputType.phone),
          _customTextField(controllers['sms_msg']!, 'SMS Message Body', maxLines: 5),
        ];
      default: return [];
    }
  }

  Widget _customTextField(TextEditingController controller, String label, {int maxLines = 1, bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white54),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        ),
      ),
    );
  }
}