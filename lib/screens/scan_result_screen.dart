
// // // lib/screens/scan_result_screen.dart
// // import 'dart:convert';
// // import 'dart:ui' as ui;
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/rendering.dart';
// // import 'package:flutter/services.dart';
// // import 'package:qr_flutter/qr_flutter.dart';
// // import 'package:barcode_widget/barcode_widget.dart' as b_widget;
// // import 'package:url_launcher/url_launcher.dart';
// // import 'package:share_plus/share_plus.dart';
// // import 'package:wifi_connector/wifi_connector.dart';
// // import 'package:contacts_service/contacts_service.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:universal_html/html.dart' as html; 
// // import 'package:path_provider/path_provider.dart'; 
// // import 'package:gal/gal.dart'; 
// // import 'dart:io';
// // import '../services/history_service.dart';

// // class ScanResultScreen extends StatefulWidget {
// //   final String rawValue;
// //   final bool isBarcodeResult;
// //   final String barcodeTypeTag;
// //   final String? itemId;
// //   final Color qrColor; 
// //   final Color qrBgColor; 

// //   const ScanResultScreen({
// //     super.key,
// //     required this.rawValue,
// //     this.isBarcodeResult = false,
// //     this.barcodeTypeTag = "",
// //     this.itemId,
// //     this.qrColor = Colors.black, 
// //     this.qrBgColor = Colors.white, 
// //   });

// //   @override
// //   State<ScanResultScreen> createState() => _ScanResultScreenState();
// // }

// // class _ScanResultScreenState extends State<ScanResultScreen> {
// //   bool _isFav = false;
// //   bool _isSaving = false; 
  
// //   final GlobalKey _qrBoundaryKey = GlobalKey(); 

// //   String? _selectedLogoAsset;

// //   final Map<String, String> _logoAssets = {
// //     'WiFi': 'assets/logos/wifi.png',
// //     'Facebook': 'assets/logos/facebook.png',
// //     'YouTube': 'assets/logos/youtube.png',
// //     'WhatsApp': 'assets/logos/whatsapp.png',
// //     'Email': 'assets/logos/email.png',
// //   };

// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkFavoriteStatus();
// //   }

// //   Future<void> _checkFavoriteStatus() async {
// //     if (widget.itemId != null && widget.itemId!.isNotEmpty) {
// //       final status = await HistoryService.isFavorite(widget.itemId!);
// //       if (mounted) {
// //         setState(() {
// //           _isFav = status;
// //         });
// //       }
// //     }
// //   }

// //   bool get _isWifi => widget.rawValue.startsWith('WIFI:');
// //   bool get _isEmail => widget.rawValue.startsWith('MATMSG:') || widget.rawValue.startsWith('mailto:');
// //   bool get _isPhone => widget.rawValue.startsWith('tel:');
// //   bool get _isSMS => widget.rawValue.startsWith('smsto:');
// //   bool get _isGeo => widget.rawValue.startsWith('geo:');
// //   bool get _isUrl => widget.rawValue.startsWith('http://') || widget.rawValue.startsWith('https://');
// //   bool get _isContact => widget.rawValue.startsWith('MCARD:') || widget.rawValue.startsWith('BEGIN:VCARD');

// //   Future<void> _launchURL(String urlString) async {
// //     final Uri url = Uri.parse(urlString);
// //     if (await canLaunchUrl(url)) {
// //       await launchUrl(url, mode: LaunchMode.externalApplication);
// //     }
// //   }

// //   void _searchOnGoogle() {
// //     final String query = Uri.encodeComponent(widget.rawValue);
// //     _launchURL("https://www.google.com/search?q=$query");
// //   }

// //   Future<void> _connectToWifi() async {
// //     final String data = widget.rawValue;
// //     final parts = data.substring(5).split(';');
// //     String ssid = "";
// //     String pass = "";
// //     for (var part in parts) {
// //       if (part.startsWith('S:')) ssid = part.substring(2);
// //       if (part.startsWith('P:')) pass = part.substring(2);
// //     }
// //     try {
// //       final isConnected = await WifiConnector.connectToWifi(ssid: ssid, password: pass);
// //       if (isConnected && mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connected successfully!")));
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("WiFi Connection error: $e")));
// //       }
// //     }
// //   }

// //   void _openInMap() {
// //     String query = widget.rawValue;
// //     if (_isGeo) {
// //       query = widget.rawValue.replaceAll('geo:', '');
// //     }
// //     _launchURL("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
// //   }

// //   void _sendSMS({bool isMMS = false}) {
// //     final String cleanData = widget.rawValue.replaceAll('smsto:', '');
// //     final List<String> parts = cleanData.split(':');
// //     final String phone = parts.isNotEmpty ? parts[0] : '';
// //     final String message = parts.length > 1 ? parts[1] : '';

// //     if (isMMS) {
// //       _launchURL("mms:$phone?body=${Uri.encodeComponent(message)}");
// //     } else {
// //       _launchURL("sms:$phone?body=${Uri.encodeComponent(message)}");
// //     }
// //   }

// //   Future<void> _saveContactFromQR() async {
// //     final PermissionStatus permission = await Permission.contacts.request();
// //     if (permission.isGranted) {
// //       try {
// //         String name = "QR Contact";
// //         String phone = "";
// //         if (widget.rawValue.contains('N:')) {
// //           name = widget.rawValue.split('N:')[1].split(';')[0];
// //         }
// //         if (widget.rawValue.contains('TEL:')) {
// //           phone = widget.rawValue.split('TEL:')[1].split(';')[0];
// //         }

// //         Contact newContact = Contact(
// //           givenName: name,
// //           phones: [Item(label: "mobile", value: phone)],
// //         );
// //         await ContactsService.addContact(newContact);
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(content: Text('Contact added successfully to your phone!')),
// //           );
// //         }
// //       } catch (e) {
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
// //         }
// //       }
// //     }
// //   }

// //   Future<Uint8List?> _captureQrImage() async {
// //     try {
// //       RenderRepaintBoundary boundary = _qrBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
// //       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
// //       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //       return byteData?.buffer.asUint8List();
// //     } catch (e) {
// //       if (kDebugMode) {
// //         print("Error capturing QR image: $e");
// //       }
// //       return null;
// //     }
// //   }

// //   Future<void> _copyQrAction() async {
// //     await Clipboard.setData(ClipboardData(text: widget.rawValue));
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('QR Code content copied to clipboard! 📋')),
// //     );
// //   }

// //   Future<void> _shareQrAction() async {
// //     Uint8List? pngBytes = await _captureQrImage();
// //     if (pngBytes != null) {
// //       try {
// //         if (kIsWeb) {
// //           Share.share(widget.rawValue, subject: 'Share QR Code');
// //         } else {
// //           final tempDir = await getTemporaryDirectory();
// //           final file = await File('${tempDir.path}/qr_code_share.png').create();
// //           await file.writeAsBytes(pngBytes);
          
// //           await Share.shareXFiles([XFile(file.path)], text: 'Scan this QR Code!');
// //         }
// //       } catch (e) {
// //         if (kDebugMode) {
// //           print("Sharing failed: $e");
// //         }
// //       }
// //     } else {
// //       Share.share(widget.rawValue);
// //     }
// //   }

// //   Future<void> _saveQrAction() async {
// //     if (_isSaving) return;
// //     setState(() => _isSaving = true);

// //     Uint8List? pngBytes = await _captureQrImage();
// //     if (pngBytes == null) {
// //       setState(() => _isSaving = false);
// //       return;
// //     }

// //     if (kIsWeb) {
// //       try {
// //         final blob = html.Blob([pngBytes]);
// //         final url = html.Url.createObjectUrlFromBlob(blob);
// //         final anchor = html.AnchorElement(href: url)
// //           ..setAttribute("download", "qrcode_${DateTime.now().millisecondsSinceEpoch}.png")
// //           ..click();
// //         html.Url.revokeObjectUrl(url);

// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('QR Code image downloaded successfully! 📥')),
// //         );
// //       } catch (e) {
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
// //       } finally {
// //         setState(() => _isSaving = false);
// //       }
// //     } else {
// //       try {
// //         final hasAccess = await Gal.hasAccess();
// //         if (!hasAccess) {
// //           await Gal.requestAccess();
// //         }

// //         final tempDir = await getTemporaryDirectory();
// //         final String filePath = '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
// //         final File imgFile = File(filePath);
// //         await imgFile.writeAsBytes(pngBytes);

// //         await Gal.putImage(filePath);

// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(backgroundColor: Colors.green, content: Text('QR Code image saved to Gallery! 🎉')),
// //         );
// //       } catch (e) {
// //         if (!mounted) return;
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(backgroundColor: Colors.redAccent, content: Text('Failed to save image: $e')),
// //         );
// //       } finally {
// //         setState(() => _isSaving = false);
// //       }
// //     }
// //   }

// // b_widget.Barcode _getBarcodeType(String tag) {
// //     String currentTag = tag.toLowerCase().trim();

// //     // হিস্ট্রি বা ফেভারিট থেকে আসার সময় যদি ট্যাগ খালি থাকে, তবে অটো-ডিটেক্ট লজিক:
// //     if (currentTag.isEmpty) {
// //       final isOnlyNumbers = RegExp(r'^\d+$').hasMatch(widget.rawValue);
// //       final isAlphanumeric = RegExp(r'^[A-Za-z0-9\-.\s+$%/]+$').hasMatch(widget.rawValue);

// //       if (isOnlyNumbers) {
// //         if (widget.rawValue.length == 8) {
// //           currentTag = 'ean8';
// //         } else if (widget.rawValue.length == 13) {
// //           currentTag = 'ean13';
// //         } else if (widget.rawValue.length == 12) {
// //           currentTag = 'upca';
// //         } else if (widget.rawValue.length == 14) {
// //           currentTag = 'itf14';
// //         } else {
// //           currentTag = 'code128'; // সংখ্যার অন্য যেকোনো দৈর্ঘ্যের জন্য সবচেয়ে নিরাপদ
// //         }
// //       } else if (isAlphanumeric) {
// //         // সংখ্যা এবং ইংরেজি অক্ষর মেশানো থাকলে Code 39 বা Code 128 বেস্ট
// //         if (widget.rawValue.startsWith('*') && widget.rawValue.endsWith('*')) {
// //           currentTag = 'code39';
// //         } else {
// //           currentTag = 'code128';
// //         }
// //       } else {
// //         currentTag = 'code128'; // যেকোনো জটিল ডেটার জন্য আলটিমেট ফলব্যাক
// //       }
// //     }

// //     // ট্যাগ অনুযায়ী সঠিক বারকোড অবজেক্ট রিটার্ন
// //     switch (currentTag) {
// //       case 'ean8': return b_widget.Barcode.ean8();
// //       case 'ean13': return b_widget.Barcode.ean13();
// //       case 'upce': return b_widget.Barcode.code128(); // মেথড এরর এড়াতে নিরাপদ ফলব্যাক
// //       case 'upca': return b_widget.Barcode.upcA();
// //       case 'code39': return b_widget.Barcode.code39();
// //       case 'code93': return b_widget.Barcode.code93();
// //       case 'code128': return b_widget.Barcode.code128();
// //       case 'pdf417': return b_widget.Barcode.pdf417();
// //       case 'codabar': return b_widget.Barcode.codabar();
// //       default: return b_widget.Barcode.code128();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFF121212),
// //       appBar: AppBar(
// //         title: const Text('Result', style: TextStyle(color: Colors.white)),
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         iconTheme: const IconThemeData(color: Colors.white),
// //         actions: [
// //           if (widget.itemId != null)
// //             IconButton(
// //               icon: Icon(_isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
// //               onPressed: () async {
// //                 await HistoryService.toggleFavorite(id: widget.itemId!);
// //                 setState(() {
// //                   _isFav = !_isFav;
// //                 });
// //               },
// //             ),
// //         ],
// //       ),
// //       // --- ওভারফ্লো ফিক্স করার জন্য মেইন বডিকে SingleChildScrollView এবং কলামে সাজানো হলো ---
// //       body: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: Container(
// //                 width: double.infinity,
// //                 padding: const EdgeInsets.all(15),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF1E1E1E),
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: Text(
// //                   widget.rawValue,
// //                   style: const TextStyle(color: Colors.white, fontSize: 16),
// //                 ),
// //               ),
// //             ),

// //             const Divider(color: Colors.grey, height: 1),

// //             Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: SingleChildScrollView(
// //                 scrollDirection: Axis.horizontal,
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.start,
// //                   children: _buildDynamicButtons(),
// //                 ),
// //               ),
// //             ),

// //             // কাস্টম লোগো সিলেকশন বার
// //             if (!widget.isBarcodeResult) ...[
// //               const Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 20.0),
// //                 child: Text('Select Center Logo (Optional)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
// //               ),
// //               const SizedBox(height: 8),
// //               Container(
// //                 height: 50,
// //                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
// //                 child: ListView(
// //                   scrollDirection: Axis.horizontal,
// //                   children: [
// //                     GestureDetector(
// //                       onTap: () => setState(() => _selectedLogoAsset = null),
// //                       child: Container(
// //                         margin: const EdgeInsets.only(right: 12),
// //                         width: 42,
// //                         decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white10, border: Border.all(color: Colors.white24)),
// //                         child: const Icon(Icons.block, color: Colors.redAccent, size: 18),
// //                       ),
// //                     ),
// //                     ..._logoAssets.entries.map((entry) {
// //                       final isSelected = _selectedLogoAsset == entry.value;
// //                       return GestureDetector(
// //                         onTap: () => setState(() => _selectedLogoAsset = entry.value),
// //                         child: Container(
// //                           margin: const EdgeInsets.only(right: 12),
// //                           padding: const EdgeInsets.all(4),
// //                           width: 42,
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             shape: BoxShape.circle,
// //                             border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2.5),
// //                           ),
// //                           child: Image.asset(entry.value, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.black, size: 16)),
// //                         ),
// //                       );
// //                     }).toList(),
// //                   ],
// //                 ),
// //               ),
// //             ],

// //             // ওভারফ্লো এড়াতে Spacer এর বদলে নির্দিষ্ট সাইজের প্যাডিং বা বক্স ব্যবহার করা হলো
// //             const SizedBox(height: 30),

// //             // কিউআর কোড জেনারেটর
// //             Center(
// //               child: RepaintBoundary(
// //                 key: _qrBoundaryKey,
// //                 child: Container(
// //                   color: widget.qrBgColor, 
// //                   padding: const EdgeInsets.all(16),
// //                   child: widget.isBarcodeResult
// //                       ? b_widget.BarcodeWidget(
// //                           barcode: _getBarcodeType(widget.barcodeTypeTag),
// //                           data: widget.rawValue.isEmpty ? "12345678" : widget.rawValue,
// //                           width: 250,
// //                           height: 90,
// //                           style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
// //                           errorBuilder: (context, error) => const Text('Invalid data format', style: TextStyle(color: Colors.red)),
// //                         )
// //                       : QrImageView(
// //                           data: widget.rawValue, 
// //                           version: QrVersions.auto, 
// //                           size: 160.0,
// //                           gapless: true,
// //                           eyeStyle: QrEyeStyle(
// //                             eyeShape: QrEyeShape.square,
// //                             color: widget.qrColor,
// //                           ),
// //                           dataModuleStyle: QrDataModuleStyle(
// //                             dataModuleShape: QrDataModuleShape.square,
// //                             color: widget.qrColor,
// //                           ),
// //                           embeddedImage: _selectedLogoAsset != null ? AssetImage(_selectedLogoAsset!) : null,
// //                           embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(32, 32)),
// //                         ),
// //                 ),
// //               ),
// //             ),
            
// //             const SizedBox(height: 40),
// //           ],
// //         ),
// //       ),
// //       // বটম বারটিকে একদম নিচে ফিক্সড রাখার জন্য Scaffolds-এর bottomNavigationBar ব্যবহার করা হলো
// //       bottomNavigationBar: _buildUniversalBottomBar(),
// //     );
// //   }

// //   List<Widget> _buildDynamicButtons() {
// //     List<Widget> buttons = [];

// //     if (_isWifi) {
// //       buttons.add(_actionIconButton(icon: Icons.wifi, label: 'Connect', onTap: _connectToWifi));
// //     }
// //     else if (_isEmail) {
// //       buttons.add(_actionIconButton(
// //         icon: Icons.email_outlined,
// //         label: 'Send Email',
// //         onTap: () => _launchURL("mailto:${widget.rawValue.replaceAll('MATMSG:TO:', '').split(';')[0]}"),
// //       ));
// //     }
// //     else if (_isPhone) {
// //       buttons.add(_actionIconButton(icon: Icons.phone, label: 'Call', onTap: () => _launchURL(widget.rawValue)));
// //     }
// //     else if (_isContact) {
// //       buttons.add(_actionIconButton(icon: Icons.person_add_alt_1_rounded, label: 'Add contact', onTap: _saveContactFromQR));
// //     }
// //     else if (_isSMS) {
// //       buttons.add(_actionIconButton(icon: Icons.chat_bubble_outline, label: 'Send SMS', onTap: () => _sendSMS(isMMS: false)));
// //       buttons.add(const SizedBox(width: 20));
// //       buttons.add(_actionIconButton(icon: Icons.image_outlined, label: 'Send MMS', onTap: () => _sendSMS(isMMS: true)));
// //     }
// //     else if (_isGeo || widget.rawValue.toLowerCase().contains('bangladesh') || widget.rawValue.toLowerCase().contains('dhaka')) {
// //       buttons.add(_actionIconButton(icon: Icons.location_on_rounded, label: 'Show Map', onTap: _openInMap));
// //     }
// //     else if (_isUrl) {
// //       buttons.add(_actionIconButton(icon: Icons.open_in_browser, label: 'Open', onTap: () => _launchURL(widget.rawValue)));
// //     }
// //     else {
// //       buttons.add(_actionIconButton(icon: Icons.search, label: 'Search Google', onTap: _searchOnGoogle));
// //     }

// //     return buttons;
// //   }

// //   Widget _actionIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
// //     return InkWell(
// //       onTap: onTap,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, color: Colors.blue, size: 36),
// //           const SizedBox(height: 8),
// //           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildUniversalBottomBar() {
// //     return Container(
// //       color: const Color(0xFF1E1E1E),
// //       padding: const EdgeInsets.symmetric(vertical: 12),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children: [
// //           IconButton(
// //             icon: const Icon(Icons.copy, color: Colors.white),
// //             onPressed: _copyQrAction,
// //             tooltip: 'Copy Code',
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.share, color: Colors.white),
// //             onPressed: _shareQrAction,
// //             tooltip: 'Share QR Image',
// //           ),
// //           _isSaving 
// //               ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //               : IconButton(
// //                   icon: const Icon(Icons.save, color: Colors.white),
// //                   onPressed: _saveQrAction,
// //                   tooltip: 'Save QR Image',
// //                 ),
// //         ],
// //       ),
// //     );
// //   }
// // }



























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
// import 'package:wifi_connector/wifi_connector.dart';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:universal_html/html.dart' as html; 
// import 'package:path_provider/path_provider.dart'; 
// import 'package:gal/gal.dart'; 
// import 'package:pasteboard/pasteboard.dart'; // নতুন প্যাকেজ ইম্পোর্ট
// import 'dart:io';
// import '../services/history_service.dart';

// class ScanResultScreen extends StatefulWidget {
//   final String rawValue;
//   final bool isBarcodeResult;
//   final String barcodeTypeTag;
//   final String? itemId;
//   final Color qrColor; 
//   final Color qrBgColor; 
//   final String? customLogoPath; // নতুন ফিচার: কাস্টম লোগো ইমেজ ফাইল পাথ রিসিভ করার জন্য

//   const ScanResultScreen({
//     super.key,
//     required this.rawValue,
//     this.isBarcodeResult = false,
//     this.barcodeTypeTag = "",
//     this.itemId,
//     this.qrColor = Colors.black, 
//     this.qrBgColor = Colors.white, 
//     this.customLogoPath, // কনস্ট্রাক্টর এ যুক্ত করা হলো
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

//   Future<void> _connectToWifi() async {
//     final String data = widget.rawValue;
//     final parts = data.substring(5).split(';');
//     String ssid = "";
//     String pass = "";
//     for (var part in parts) {
//       if (part.startsWith('S:')) ssid = part.substring(2);
//       if (part.startsWith('P:')) pass = part.substring(2);
//     }
//     try {
//       final isConnected = await WifiConnector.connectToWifi(ssid: ssid, password: pass);
//       if (isConnected && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connected successfully!")));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("WiFi Connection error: $e")));
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
//     final PermissionStatus permission = await Permission.contacts.request();
//     if (permission.isGranted) {
//       try {
//         String name = "QR Contact";
//         String phone = "";
//         if (widget.rawValue.contains('N:')) {
//           name = widget.rawValue.split('N:')[1].split(';')[0];
//         }
//         if (widget.rawValue.contains('TEL:')) {
//           phone = widget.rawValue.split('TEL:')[1].split(';')[0];
//         }

//         Contact newContact = Contact(
//           givenName: name,
//           phones: [Item(label: "mobile", value: phone)],
//         );
//         await ContactsService.addContact(newContact);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Contact added successfully to your phone!')),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
//         }
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
//     // ১. প্রথমে স্ক্রিনের কিউআর বা বারকোডের লাইভ গ্রাফিক্স থেকে PNG Bytes ক্যাপচার করা হচ্ছে
//     Uint8List? pngBytes = await _captureQrImage();
    
//     if (pngBytes != null) {
//       try {
//         if (kIsWeb) {
//           // ওয়েবের জন্য টেক্সট কপি ফলব্যাক
//           await Clipboard.setData(ClipboardData(text: widget.rawValue));
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('QR Code content copied to clipboard! 📋')),
//           );
//         } else {
//           // ২. মোবাইলের জন্য সরাসরি PNG ফাইল ক্লিপবোর্ডে কপি করা হচ্ছে
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
//         // কোনো কারণে ইমেজ কপি ফেইল করলে নিরাপদ ফলব্যাক হিসেবে টেক্সট কপি হবে
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

//   // লোগো রেন্ডারিং এম্বেড সোর্স ডিফাইন করার জন্য নতুন মেথড
//   ImageProvider? _getEmbeddedImage() {
//     // ১. প্রথম অগ্রাধিকার: ইউজারের নিজস্ব আপলোড করা গ্যালারি লোগো
//     if (widget.customLogoPath != null && widget.customLogoPath!.isNotEmpty) {
//       return FileImage(File(widget.customLogoPath!));
//     }
//     // ২. দ্বিতীয় অগ্রাধিকার: অ্যাপের ডিফল্ট চয়েস অ্যাসেট লোগো
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

//             // কাস্টম লোগো সিলেকশন বার (কাস্টম লোগো আপলোড না থাকলেও আগের চয়েস স্লাইডারটি অক্ষুণ্ণ থাকবে)
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
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             ],

//             const SizedBox(height: 30),

//             // কিউআর কোড এবং বারকোড রেন্ডারিং সেকশন
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
//                           // ডাইনামিক সোর্স লজিক দিয়ে এম্বেডেড ইমেজ সেট করা হলো
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
import 'package:wifi_connector/wifi_connector.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc; 
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html; 
import 'package:path_provider/path_provider.dart'; 
import 'package:gal/gal.dart'; 
import 'package:pasteboard/pasteboard.dart'; 
import 'dart:io';
import '../services/history_service.dart';

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

  Future<void> _connectToWifi() async {
    final String data = widget.rawValue;
    final parts = data.substring(5).split(';');
    String ssid = "";
    String pass = "";
    for (var part in parts) {
      if (part.startsWith('S:')) ssid = part.substring(2);
      if (part.startsWith('P:')) pass = part.substring(2);
    }
    try {
      final isConnected = await WifiConnector.connectToWifi(ssid: ssid, password: pass);
      if (isConnected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connected successfully!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("WiFi Connection error: $e")));
      }
    }
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
    if (await fc.FlutterContacts.requestPermission()) {
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
          phones: phone.isNotEmpty ? [fc.Phone(number: phone, label: fc.PhoneLabel.mobile)] : [],
        );
        
        await fc.FlutterContacts.insertContact(newContact);

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

  Future<ui.Image?> _loadImageFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
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
                    }).toList(),
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
        mainAxisSize: MainAxisSize.min, // এখানে MainAxisSize ফিক্স করা হয়েছে
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