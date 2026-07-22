



// // lib/screens/scan_result_screen.dart
// import 'dart:convert';
// import 'dart:ui' as ui;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:barcode_widget/barcode_widget.dart' as b_widget;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:wifi_iot/wifi_iot.dart'; 
// import 'package:flutter_contacts/flutter_contacts.dart' as fc; 
// import 'package:permission_handler/permission_handler.dart';
// import 'package:universal_html/html.dart' as html; 
// import 'package:path_provider/path_provider.dart'; 
// import 'package:gal/gal.dart'; 
// import 'package:pasteboard/pasteboard.dart'; 
// import 'dart:io';
// import '../services/history_service.dart';

// class ScanResultScreen extends StatefulWidget {
//   final String rawValue;
//   final bool isBarcodeResult;
//   final String barcodeTypeTag;
//   final String? itemId;
//   final Color qrColor; 
//   final Color qrBgColor; 
//   final String? customLogoPath; 

//   const ScanResultScreen({
//     super.key,
//     required this.rawValue,
//     this.isBarcodeResult = false,
//     this.barcodeTypeTag = "",
//     this.itemId,
//     this.qrColor = Colors.black, 
//     this.qrBgColor = Colors.white, 
//     this.customLogoPath, 
//   });

//   @override
//   State<ScanResultScreen> createState() => _ScanResultScreenState();
// }

// class _ScanResultScreenState extends State<ScanResultScreen> {
//   bool _isFav = false;
//   bool _isSaving = false; 
  
//   final GlobalKey _qrBoundaryKey = GlobalKey(); 

//   String? _selectedLogoAsset;

//   final Map<String, String> _logoAssets = {
//     'WiFi': 'assets/logos/wifi.png',
//     'Facebook': 'assets/logos/facebook.png',
//     'YouTube': 'assets/logos/youtube.png',
//     'WhatsApp': 'assets/logos/whatsapp.png',
//     'Email': 'assets/logos/email.png',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _checkFavoriteStatus();
//   }

//   Future<void> _checkFavoriteStatus() async {
//     if (widget.itemId != null && widget.itemId!.isNotEmpty) {
//       final status = await HistoryService.isFavorite(widget.itemId!);
//       if (mounted) {
//         setState(() {
//           _isFav = status;
//         });
//       }
//     }
//   }

//   bool get _isWifi => widget.rawValue.startsWith('WIFI:');
//   bool get _isEmail => widget.rawValue.startsWith('MATMSG:') || widget.rawValue.startsWith('mailto:');
//   bool get _isPhone => widget.rawValue.startsWith('tel:');
//   bool get _isSMS => widget.rawValue.startsWith('smsto:');
//   bool get _isGeo => widget.rawValue.startsWith('geo:');
//   bool get _isUrl => widget.rawValue.startsWith('http://') || widget.rawValue.startsWith('https://');
//   bool get _isContact => widget.rawValue.startsWith('MCARD:') || widget.rawValue.startsWith('BEGIN:VCARD');

//   Future<void> _launchURL(String urlString) async {
//     final Uri url = Uri.parse(urlString);
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }

//   void _searchOnGoogle() {
//     final String query = Uri.encodeComponent(widget.rawValue);
//     _launchURL("https://www.google.com/search?q=$query");
//   }

//   // wifi_iot প্যাকেজের সঠিক ক্লাস নাম (WiFiForIoTPlugin) দিয়ে ফিক্স করা লজিক
//  // wifi_iot v0.3.19+2 এর অফিশিয়াল মেথড (connect) দিয়ে ফিক্স করা লজিক
//   Future<void> _connectToWifi() async {
//     final String data = widget.rawValue;
//     final parts = data.substring(5).split(';');
//     String ssid = "";
//     String pass = "";
//     String security = "WPA"; 

//     for (var part in parts) {
//       if (part.startsWith('S:')) ssid = part.substring(2);
//       if (part.startsWith('P:')) pass = part.substring(2);
//       if (part.startsWith('T:')) security = part.substring(2);
//     }

//     if (ssid.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid WiFi QR Code: Missing SSID")));
//       }
//       return;
//     }

//     try {
//       bool isEnabled = await WiFiForIoTPlugin.isEnabled();
//       if (!isEnabled) {
//         await WiFiForIoTPlugin.setEnabled(true);
//         await Future.delayed(const Duration(seconds: 1));
//       }

//       // v0.3.19+2 সংস্করণের অফিশিয়াল মেথড ও প্যারামিটার লজিক
//       final isConnected = await WiFiForIoTPlugin.connect(
//         ssid,
//         password: pass,
//         security: NetworkSecurity.values.firstWhere(
//           (e) => e.toString().split('.').last.toUpperCase() == security.toUpperCase(),
//           orElse: () => NetworkSecurity.WPA,
//         ),
//         joinOnce: false, // নেটওয়ার্কটি মোবাইলে সেভ করে রাখবে
//       );

//       if (mounted) {
//         if (isConnected) {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Connected successfully! 🎉")));
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Failed to connect. Please check credentials.")));
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text("WiFi Connection error: $e")));
//       }
//     }
//   }


//   void _openInMap() {
//     String query = widget.rawValue;
//     if (_isGeo) {
//       query = widget.rawValue.replaceAll('geo:', '');
//     }
//     _launchURL("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
//   }

//   void _sendSMS({bool isMMS = false}) {
//     final String cleanData = widget.rawValue.replaceAll('smsto:', '');
//     final List<String> parts = cleanData.split(':');
//     final String phone = parts.isNotEmpty ? parts[0] : '';
//     final String message = parts.length > 1 ? parts[1] : '';

//     if (isMMS) {
//       _launchURL("mms:$phone?body=${Uri.encodeComponent(message)}");
//     } else {
//       _launchURL("sms:$phone?body=${Uri.encodeComponent(message)}");
//     }
//   }

//   Future<void> _saveContactFromQR() async {
//     final status = await fc.FlutterContacts.permissions.request(fc.PermissionType.readWrite);
//     if (status == fc.PermissionStatus.granted) {
//       try {
//         String name = "QR Contact";
//         String phone = "";
//         if (widget.rawValue.contains('N:')) {
//           name = widget.rawValue.split('N:')[1].split(';')[0];
//         }
//         if (widget.rawValue.contains('TEL:')) {
//           phone = widget.rawValue.split('TEL:')[1].split(';')[0];
//         }

//         final newContact = fc.Contact(
//           name: fc.Name(first: name),
//           phones: phone.isNotEmpty ? [fc.Phone(number: phone, label: fc.Label(fc.PhoneLabel.mobile))] : [],
//         );
        
//         await fc.FlutterContacts.create(newContact);

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               backgroundColor: Colors.green,
//               content: Text('Contact added successfully to your phone! 🎉'),
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
//         }
//       }
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Contacts permission denied.')),
//         );
//       }
//     }
//   }

//   Future<ui.Image?> _loadImageFromFile(String path) async {
//     final file = File(path);
//     if (!await file.exists()) return null;
//     final bytes = await file.readAsBytes();
//     final codec = await ui.instantiateImageCodec(bytes);
//     final frame = await codec.getNextFrame();
//     return frame.image;
//   }

//   Future<Uint8List?> _captureQrImage() async {
//     try {
//       RenderRepaintBoundary boundary = _qrBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       return byteData?.buffer.asUint8List();
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error capturing QR image: $e");
//       }
//       return null;
//     }
//   }

//   Future<void> _copyQrAction() async {
//     Uint8List? pngBytes = await _captureQrImage();
    
//     if (pngBytes != null) {
//       try {
//         if (kIsWeb) {
//           await Clipboard.setData(ClipboardData(text: widget.rawValue));
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('QR Code content copied to clipboard! 📋')),
//           );
//         } else {
//           await Pasteboard.writeImage(pngBytes);
          
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               backgroundColor: Colors.green,
//               content: Text('Code PNG Image copied to clipboard! Now you can paste it anywhere. 📋🖼️'),
//             ),
//           );
//         }
//       } catch (e) {
//         await Clipboard.setData(ClipboardData(text: widget.rawValue));
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Text content copied instead! 📋')),
//         );
//       }
//     } else {
//       await Clipboard.setData(ClipboardData(text: widget.rawValue));
//     }
//   }

//   Future<void> _shareQrAction() async {
//     Uint8List? pngBytes = await _captureQrImage();
//     if (pngBytes != null) {
//       try {
//         if (kIsWeb) {
//           Share.share(widget.rawValue, subject: 'Share QR Code');
//         } else {
//           final tempDir = await getTemporaryDirectory();
//           final file = await File('${tempDir.path}/qr_code_share.png').create();
//           await file.writeAsBytes(pngBytes);
          
//           await Share.shareXFiles([XFile(file.path)], text: 'Scan this QR Code!');
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           print("Sharing failed: $e");
//         }
//       }
//     } else {
//       Share.share(widget.rawValue);
//     }
//   }

//   Future<void> _saveQrAction() async {
//     if (_isSaving) return;
//     setState(() => _isSaving = true);

//     Uint8List? pngBytes = await _captureQrImage();
//     if (pngBytes == null) {
//       setState(() => _isSaving = false);
//       return;
//     }

//     if (kIsWeb) {
//       try {
//         final html.Blob blob = html.Blob([pngBytes]);
//         final url = html.Url.createObjectUrlFromBlob(blob);
//         final anchor = html.AnchorElement(href: url)
//           ..setAttribute("download", "qrcode_${DateTime.now().millisecondsSinceEpoch}.png")
//           ..click();
//         html.Url.revokeObjectUrl(url);

//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('QR Code image downloaded successfully! 📥')),
//         );
//       } catch (e) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
//       } finally {
//         setState(() => _isSaving = false);
//       }
//     } else {
//       try {
//         final hasAccess = await Gal.hasAccess();
//         if (!hasAccess) {
//           await Gal.requestAccess();
//         }

//         final tempDir = await getTemporaryDirectory();
//         final String filePath = '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
//         final File imgFile = File(filePath);
//         await imgFile.writeAsBytes(pngBytes);

//         await Gal.putImage(filePath);

//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(backgroundColor: Colors.green, content: Text('QR Code image saved to Gallery! 🎉')),
//         );
//       } catch (e) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(backgroundColor: Colors.redAccent, content: Text('Failed to save image: $e')),
//         );
//       } finally {
//         setState(() => _isSaving = false);
//       }
//     }
//   }

//   b_widget.Barcode _getBarcodeType(String tag) {
//     String currentTag = tag.toLowerCase().trim();

//     if (currentTag.isEmpty) {
//       final isOnlyNumbers = RegExp(r'^\d+$').hasMatch(widget.rawValue);
//       final isAlphanumeric = RegExp(r'^[A-Za-z0-9\-.\s+$%/]+$').hasMatch(widget.rawValue);

//       if (isOnlyNumbers) {
//         if (widget.rawValue.length == 8) {
//           currentTag = 'ean8';
//         } else if (widget.rawValue.length == 13) {
//           currentTag = 'ean13';
//         } else if (widget.rawValue.length == 12) {
//           currentTag = 'upca';
//         } else if (widget.rawValue.length == 14) {
//           currentTag = 'itf14';
//         } else {
//           currentTag = 'code128';
//         }
//       } else if (isAlphanumeric) {
//         if (widget.rawValue.startsWith('*') && widget.rawValue.endsWith('*')) {
//           currentTag = 'code39';
//         } else {
//           currentTag = 'code128';
//         }
//       } else {
//         currentTag = 'code128';
//       }
//     }

//     switch (currentTag) {
//       case 'ean8': return b_widget.Barcode.ean8();
//       case 'ean13': return b_widget.Barcode.ean13();
//       case 'upce': return b_widget.Barcode.code128();
//       case 'upca': return b_widget.Barcode.upcA();
//       case 'code39': return b_widget.Barcode.code39();
//       case 'code93': return b_widget.Barcode.code93();
//       case 'code128': return b_widget.Barcode.code128();
//       case 'pdf417': return b_widget.Barcode.pdf417();
//       case 'codabar': return b_widget.Barcode.codabar();
//       default: return b_widget.Barcode.code128();
//     }
//   }

//   ImageProvider? _getEmbeddedImage() {
//     if (widget.customLogoPath != null && widget.customLogoPath!.isNotEmpty) {
//       return FileImage(File(widget.customLogoPath!));
//     }
//     if (_selectedLogoAsset != null) {
//       return AssetImage(_selectedLogoAsset!);
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       appBar: AppBar(
//         title: const Text('Result', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           if (widget.itemId != null)
//             IconButton(
//               icon: Icon(_isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
//               onPressed: () async {
//                 await HistoryService.toggleFavorite(id: widget.itemId!);
//                 setState(() {
//                   _isFav = !_isFav;
//                 });
//               },
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1E1E1E),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   widget.rawValue,
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),

//             const Divider(color: Colors.grey, height: 1),

//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: _buildDynamicButtons(),
//                 ),
//               ),
//             ),

//             if (!widget.isBarcodeResult) ...[
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.0),
//                 child: Text('Select Center Logo (Optional)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 height: 50,
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     GestureDetector(
//                       onTap: () => setState(() => _selectedLogoAsset = null),
//                       child: Container(
//                         margin: const EdgeInsets.only(right: 12),
//                         width: 42,
//                         decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white10, border: Border.all(color: Colors.white24)),
//                         child: const Icon(Icons.block, color: Colors.redAccent, size: 18),
//                       ),
//                     ),
//                     ..._logoAssets.entries.map((entry) {
//                       final isSelected = _selectedLogoAsset == entry.value;
//                       return GestureDetector(
//                         onTap: () => setState(() => _selectedLogoAsset = entry.value),
//                         child: Container(
//                           margin: const EdgeInsets.only(right: 12),
//                           padding: const EdgeInsets.all(4),
//                           width: 42,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2.5),
//                           ),
//                           child: Image.asset(entry.value, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.black, size: 16)),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ],

//             const SizedBox(height: 30),

//             Center(
//               child: RepaintBoundary(
//                 key: _qrBoundaryKey,
//                 child: Container(
//                   color: widget.qrBgColor, 
//                   padding: const EdgeInsets.all(16),
//                   child: widget.isBarcodeResult
//                       ? b_widget.BarcodeWidget(
//                           barcode: _getBarcodeType(widget.barcodeTypeTag),
//                           data: widget.rawValue.isEmpty ? "12345678" : widget.rawValue,
//                           width: 250,
//                           height: 90,
//                           style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                           errorBuilder: (context, error) => const Text('Invalid data format', style: TextStyle(color: Colors.red)),
//                         )
//                       : QrImageView(
//                           data: widget.rawValue, 
//                           version: QrVersions.auto, 
//                           size: 160.0,
//                           gapless: true,
//                           eyeStyle: QrEyeStyle(
//                             eyeShape: QrEyeShape.square,
//                             color: widget.qrColor,
//                           ),
//                           dataModuleStyle: QrDataModuleStyle(
//                             dataModuleShape: QrDataModuleShape.square,
//                             color: widget.qrColor,
//                           ),
//                           embeddedImage: _getEmbeddedImage(),
//                           embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(32, 32)),
//                         ),
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildUniversalBottomBar(),
//     );
//   }

//   List<Widget> _buildDynamicButtons() {
//     List<Widget> buttons = [];

//     if (_isWifi) {
//       buttons.add(_actionIconButton(icon: Icons.wifi, label: 'Connect', onTap: _connectToWifi));
//     }
//     else if (_isEmail) {
//       buttons.add(_actionIconButton(
//         icon: Icons.email_outlined,
//         label: 'Send Email',
//         onTap: () => _launchURL("mailto:${widget.rawValue.replaceAll('MATMSG:TO:', '').split(';')[0]}"),
//       ));
//     }
//     else if (_isPhone) {
//       buttons.add(_actionIconButton(icon: Icons.phone, label: 'Call', onTap: () => _launchURL(widget.rawValue)));
//     }
//     else if (_isContact) {
//       buttons.add(_actionIconButton(icon: Icons.person_add_alt_1_rounded, label: 'Add contact', onTap: _saveContactFromQR));
//     }
//     else if (_isSMS) {
//       buttons.add(_actionIconButton(icon: Icons.chat_bubble_outline, label: 'Send SMS', onTap: () => _sendSMS(isMMS: false)));
//       buttons.add(const SizedBox(width: 20));
//       buttons.add(_actionIconButton(icon: Icons.image_outlined, label: 'Send MMS', onTap: () => _sendSMS(isMMS: true)));
//     }
//     else if (_isGeo || widget.rawValue.toLowerCase().contains('bangladesh') || widget.rawValue.toLowerCase().contains('dhaka')) {
//       buttons.add(_actionIconButton(icon: Icons.location_on_rounded, label: 'Show Map', onTap: _openInMap));
//     }
//     else if (_isUrl) {
//       buttons.add(_actionIconButton(icon: Icons.open_in_browser, label: 'Open', onTap: () => _launchURL(widget.rawValue)));
//     }
//     else {
//       buttons.add(_actionIconButton(icon: Icons.search, label: 'Search Google', onTap: _searchOnGoogle));
//     }

//     return buttons;
//   }

//   Widget _actionIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.blue, size: 36),
//           const SizedBox(height: 8),
//           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildUniversalBottomBar() {
//     return Container(
//       color: const Color(0xFF1E1E1E),
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.copy, color: Colors.white),
//             onPressed: _copyQrAction,
//             tooltip: 'Copy Code',
//           ),
//           IconButton(
//             icon: const Icon(Icons.share, color: Colors.white),
//             onPressed: _shareQrAction,
//             tooltip: 'Share QR Image',
//           ),
//           _isSaving 
//               ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//               : IconButton(
//                   icon: const Icon(Icons.save, color: Colors.white),
//                   onPressed: _saveQrAction,
//                   tooltip: 'Save QR Image',
//                 ),
//         ],
//       ),
//     );
//   }
// }













// lib/screens/scan_result_screen.dart
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart' as b_widget;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wifi_iot/wifi_iot.dart'; 
import 'package:flutter_contacts/flutter_contacts.dart' as fc; 
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html; 
import 'package:path_provider/path_provider.dart'; 
import 'package:gal/gal.dart'; 
import 'package:pasteboard/pasteboard.dart'; 
import 'dart:io';
import '../services/history_service.dart';
import 'form_screens/generic_form_screen.dart'; // Edit অপশনের জন্য Form screen import

class ScanResultScreen extends StatefulWidget {
  final String rawValue;
  final bool isBarcodeResult;
  final String barcodeTypeTag;
  final String? itemId;
  final Color qrColor; 
  final Color qrBgColor; 
  final String? customLogoPath; 

  const ScanResultScreen({
    super.key,
    required this.rawValue,
    this.isBarcodeResult = false,
    this.barcodeTypeTag = "",
    this.itemId,
    this.qrColor = Colors.black, 
    this.qrBgColor = Colors.white, 
    this.customLogoPath, 
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isFav = false;
  bool _isSaving = false; 
  
  final GlobalKey _qrBoundaryKey = GlobalKey(); 

  String? _selectedLogoAsset;

  final Map<String, String> _logoAssets = {
    'WiFi': 'assets/logos/wifi.png',
    'Facebook': 'assets/logos/facebook.png',
    'YouTube': 'assets/logos/youtube.png',
    'WhatsApp': 'assets/logos/whatsapp.png',
    'Email': 'assets/logos/email.png',
  };

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.itemId != null && widget.itemId!.isNotEmpty) {
      final status = await HistoryService.isFavorite(widget.itemId!);
      if (mounted) {
        setState(() {
          _isFav = status;
        });
      }
    }
  }

  bool get _isWifi => widget.rawValue.startsWith('WIFI:');
  bool get _isEmail => widget.rawValue.startsWith('MATMSG:') || widget.rawValue.startsWith('mailto:');
  bool get _isPhone => widget.rawValue.startsWith('tel:');
  bool get _isSMS => widget.rawValue.startsWith('smsto:');
  bool get _isGeo => widget.rawValue.startsWith('geo:');
  bool get _isUrl => widget.rawValue.startsWith('http://') || widget.rawValue.startsWith('https://');
  bool get _isContact => widget.rawValue.startsWith('MCARD:') || widget.rawValue.startsWith('BEGIN:VCARD');

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _searchOnGoogle() {
    final String query = Uri.encodeComponent(widget.rawValue);
    _launchURL("https://www.google.com/search?q=$query");
  }

  // --- WiFi Connection Fixed with Location Permission ---
  Future<void> _connectToWifi() async {
    // অ্যান্ড্রয়েড ১০+ ভার্সনে WiFi স্ক্র্যানিং/কানেকশনের জন্য লোকেশন পারমিশন আবশ্যক
    var locStatus = await Permission.location.request();
    if (!locStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text("Location permission & GPS are required to connect WiFi!"),
          ),
        );
      }
      return;
    }

    final String data = widget.rawValue;
    final parts = data.substring(5).split(';');
    String ssid = "";
    String pass = "";
    String security = "WPA"; 

    for (var part in parts) {
      if (part.startsWith('S:')) ssid = part.substring(2);
      if (part.startsWith('P:')) pass = part.substring(2);
      if (part.startsWith('T:')) security = part.substring(2);
    }

    if (ssid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid WiFi QR Code: Missing SSID")));
      }
      return;
    }

    try {
      bool isEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!isEnabled) {
        await WiFiForIoTPlugin.setEnabled(true);
        await Future.delayed(const Duration(seconds: 1));
      }

      NetworkSecurity sec = NetworkSecurity.WPA;
      final secUpper = security.toUpperCase();
      if (secUpper.contains('WEP')) {
        sec = NetworkSecurity.WEP;
      } else if (secUpper.contains('NOPASS') || secUpper.contains('NO PASS')) {
        sec = NetworkSecurity.NONE;
      }

      final isConnected = await WiFiForIoTPlugin.connect(
        ssid,
        password: pass,
        security: sec,
        joinOnce: false,
      );

      if (mounted) {
        if (isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Connected successfully! 🎉")));
        } else {
          // Force connect fallback
          await WiFiForIoTPlugin.forceWifiUsage(true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.blueAccent, content: Text("Connecting... Please check Wi-Fi settings.")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text("WiFi Connection error: $e")));
      }
    }
  }

  // --- Dynamic Edit Option Logic ---
  void _navigateToEditScreen() {
    String formType = 'text';
    String title = 'Edit Text';

    if (widget.isBarcodeResult) {
      formType = 'barcode';
      title = 'Edit Barcode';
    } else if (_isUrl) {
      formType = 'url';
      title = 'Edit URL';
    } else if (_isWifi) {
      formType = 'wifi';
      title = 'Edit WiFi';
    } else if (_isEmail) {
      formType = 'email';
      title = 'Edit Email';
    } else if (_isSMS) {
      formType = 'sms';
      title = 'Edit SMS';
    } else if (_isContact) {
      formType = 'contact';
      title = 'Edit Contact';
    } else if (_isPhone) {
      formType = 'phone';
      title = 'Edit Phone';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericFormScreen(
          formType: formType,
          title: title,
          isBarcode: widget.isBarcodeResult,
        ),
      ),
    );
  }

  void _openInMap() {
    String query = widget.rawValue;
    if (_isGeo) {
      query = widget.rawValue.replaceAll('geo:', '');
    }
    _launchURL("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
  }

  void _sendSMS({bool isMMS = false}) {
    final String cleanData = widget.rawValue.replaceAll('smsto:', '');
    final List<String> parts = cleanData.split(':');
    final String phone = parts.isNotEmpty ? parts[0] : '';
    final String message = parts.length > 1 ? parts[1] : '';

    if (isMMS) {
      _launchURL("mms:$phone?body=${Uri.encodeComponent(message)}");
    } else {
      _launchURL("sms:$phone?body=${Uri.encodeComponent(message)}");
    }
  }

  Future<void> _saveContactFromQR() async {
    final status = await fc.FlutterContacts.permissions.request(fc.PermissionType.readWrite);
    if (status == fc.PermissionStatus.granted) {
      try {
        String name = "QR Contact";
        String phone = "";
        if (widget.rawValue.contains('N:')) {
          name = widget.rawValue.split('N:')[1].split(';')[0];
        }
        if (widget.rawValue.contains('TEL:')) {
          phone = widget.rawValue.split('TEL:')[1].split(';')[0];
        }

        final newContact = fc.Contact(
          name: fc.Name(first: name),
          phones: phone.isNotEmpty ? [fc.Phone(number: phone, label: fc.Label(fc.PhoneLabel.mobile))] : [],
        );
        
        await fc.FlutterContacts.create(newContact);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Contact added successfully to your phone! 🎉'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied.')),
        );
      }
    }
  }

  Future<Uint8List?> _captureQrImage() async {
    try {
      RenderRepaintBoundary boundary = _qrBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) {
        print("Error capturing QR image: $e");
      }
      return null;
    }
  }

  Future<void> _copyQrAction() async {
    Uint8List? pngBytes = await _captureQrImage();
    
    if (pngBytes != null) {
      try {
        if (kIsWeb) {
          await Clipboard.setData(ClipboardData(text: widget.rawValue));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code content copied to clipboard! 📋')),
          );
        } else {
          await Pasteboard.writeImage(pngBytes);
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Code PNG Image copied to clipboard! Now you can paste it anywhere. 📋🖼️'),
            ),
          );
        }
      } catch (e) {
        await Clipboard.setData(ClipboardData(text: widget.rawValue));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text content copied instead! 📋')),
        );
      }
    } else {
      await Clipboard.setData(ClipboardData(text: widget.rawValue));
    }
  }

  Future<void> _shareQrAction() async {
    Uint8List? pngBytes = await _captureQrImage();
    if (pngBytes != null) {
      try {
        if (kIsWeb) {
          Share.share(widget.rawValue, subject: 'Share QR Code');
        } else {
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/qr_code_share.png').create();
          await file.writeAsBytes(pngBytes);
          
          await Share.shareXFiles([XFile(file.path)], text: 'Scan this QR Code!');
        }
      } catch (e) {
        if (kDebugMode) {
          print("Sharing failed: $e");
        }
      }
    } else {
      Share.share(widget.rawValue);
    }
  }

  Future<void> _saveQrAction() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    Uint8List? pngBytes = await _captureQrImage();
    if (pngBytes == null) {
      setState(() => _isSaving = false);
      return;
    }

    if (kIsWeb) {
      try {
        final html.Blob blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "qrcode_${DateTime.now().millisecondsSinceEpoch}.png")
          ..click();
        html.Url.revokeObjectUrl(url);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code image downloaded successfully! 📥')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      } finally {
        setState(() => _isSaving = false);
      }
    } else {
      try {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }

        final tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
        final File imgFile = File(filePath);
        await imgFile.writeAsBytes(pngBytes);

        await Gal.putImage(filePath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('QR Code image saved to Gallery! 🎉')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Failed to save image: $e')),
        );
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  b_widget.Barcode _getBarcodeType(String tag) {
    String currentTag = tag.toLowerCase().trim();

    if (currentTag.isEmpty) {
      final isOnlyNumbers = RegExp(r'^\d+$').hasMatch(widget.rawValue);
      final isAlphanumeric = RegExp(r'^[A-Za-z0-9\-.\s+$%/]+$').hasMatch(widget.rawValue);

      if (isOnlyNumbers) {
        if (widget.rawValue.length == 8) {
          currentTag = 'ean8';
        } else if (widget.rawValue.length == 13) {
          currentTag = 'ean13';
        } else if (widget.rawValue.length == 12) {
          currentTag = 'upca';
        } else if (widget.rawValue.length == 14) {
          currentTag = 'itf14';
        } else {
          currentTag = 'code128';
        }
      } else if (isAlphanumeric) {
        if (widget.rawValue.startsWith('*') && widget.rawValue.endsWith('*')) {
          currentTag = 'code39';
        } else {
          currentTag = 'code128';
        }
      } else {
        currentTag = 'code128';
      }
    }

    switch (currentTag) {
      case 'ean8': return b_widget.Barcode.ean8();
      case 'ean13': return b_widget.Barcode.ean13();
      case 'upce': return b_widget.Barcode.code128();
      case 'upca': return b_widget.Barcode.upcA();
      case 'code39': return b_widget.Barcode.code39();
      case 'code93': return b_widget.Barcode.code93();
      case 'code128': return b_widget.Barcode.code128();
      case 'pdf417': return b_widget.Barcode.pdf417();
      case 'codabar': return b_widget.Barcode.codabar();
      default: return b_widget.Barcode.code128();
    }
  }

  ImageProvider? _getEmbeddedImage() {
    if (widget.customLogoPath != null && widget.customLogoPath!.isNotEmpty) {
      return FileImage(File(widget.customLogoPath!));
    }
    if (_selectedLogoAsset != null) {
      return AssetImage(_selectedLogoAsset!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Result', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Edit Button Top Right Action
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Colors.orangeAccent, size: 28),
            tooltip: 'Edit & Re-generate',
            onPressed: _navigateToEditScreen,
          ),
          if (widget.itemId != null)
            IconButton(
              icon: Icon(_isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
              onPressed: () async {
                await HistoryService.toggleFavorite(id: widget.itemId!);
                setState(() {
                  _isFav = !_isFav;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.rawValue,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const Divider(color: Colors.grey, height: 1),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _buildDynamicButtons(),
                ),
              ),
            ),

            if (!widget.isBarcodeResult) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Select Center Logo (Optional)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedLogoAsset = null),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 42,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white10, border: Border.all(color: Colors.white24)),
                        child: const Icon(Icons.block, color: Colors.redAccent, size: 18),
                      ),
                    ),
                    ..._logoAssets.entries.map((entry) {
                      final isSelected = _selectedLogoAsset == entry.value;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedLogoAsset = entry.value),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(4),
                          width: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2.5),
                          ),
                          child: Image.asset(entry.value, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.black, size: 16)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            Center(
              child: RepaintBoundary(
                key: _qrBoundaryKey,
                child: Container(
                  color: widget.qrBgColor, 
                  padding: const EdgeInsets.all(16),
                  child: widget.isBarcodeResult
                      ? b_widget.BarcodeWidget(
                          barcode: _getBarcodeType(widget.barcodeTypeTag),
                          data: widget.rawValue.isEmpty ? "12345678" : widget.rawValue,
                          width: 250,
                          height: 90,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          errorBuilder: (context, error) => const Text('Invalid data format', style: TextStyle(color: Colors.red)),
                        )
                      : QrImageView(
                          data: widget.rawValue, 
                          version: QrVersions.auto, 
                          size: 160.0,
                          gapless: true,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: widget.qrColor,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: widget.qrColor,
                          ),
                          embeddedImage: _getEmbeddedImage(),
                          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(32, 32)),
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildUniversalBottomBar(),
    );
  }

  List<Widget> _buildDynamicButtons() {
    List<Widget> buttons = [];

    // 1. Edit Button in Dynamic Action List
    buttons.add(_actionIconButton(icon: Icons.edit_note, label: 'Edit Content', onTap: _navigateToEditScreen));
    buttons.add(const SizedBox(width: 20));

    if (_isWifi) {
      buttons.add(_actionIconButton(icon: Icons.wifi, label: 'Connect', onTap: _connectToWifi));
    }
    else if (_isEmail) {
      buttons.add(_actionIconButton(
        icon: Icons.email_outlined,
        label: 'Send Email',
        onTap: () => _launchURL("mailto:${widget.rawValue.replaceAll('MATMSG:TO:', '').split(';')[0]}"),
      ));
    }
    else if (_isPhone) {
      buttons.add(_actionIconButton(icon: Icons.phone, label: 'Call', onTap: () => _launchURL(widget.rawValue)));
    }
    else if (_isContact) {
      buttons.add(_actionIconButton(icon: Icons.person_add_alt_1_rounded, label: 'Add contact', onTap: _saveContactFromQR));
    }
    else if (_isSMS) {
      buttons.add(_actionIconButton(icon: Icons.chat_bubble_outline, label: 'Send SMS', onTap: () => _sendSMS(isMMS: false)));
      buttons.add(const SizedBox(width: 20));
      buttons.add(_actionIconButton(icon: Icons.image_outlined, label: 'Send MMS', onTap: () => _sendSMS(isMMS: true)));
    }
    else if (_isGeo || widget.rawValue.toLowerCase().contains('bangladesh') || widget.rawValue.toLowerCase().contains('dhaka')) {
      buttons.add(_actionIconButton(icon: Icons.location_on_rounded, label: 'Show Map', onTap: _openInMap));
    }
    else if (_isUrl) {
      buttons.add(_actionIconButton(icon: Icons.open_in_browser, label: 'Open', onTap: () => _launchURL(widget.rawValue)));
    }
    else {
      buttons.add(_actionIconButton(icon: Icons.search, label: 'Search Google', onTap: _searchOnGoogle));
    }

    return buttons;
  }

  Widget _actionIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 36),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildUniversalBottomBar() {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: _copyQrAction,
            tooltip: 'Copy Code',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareQrAction,
            tooltip: 'Share QR Image',
          ),
          _isSaving 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: _saveQrAction,
                  tooltip: 'Save QR Image',
                ),
        ],
      ),
    );
  }
}