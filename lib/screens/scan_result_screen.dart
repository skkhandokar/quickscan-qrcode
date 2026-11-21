// // lib/screens/scan_result_screen.dart
// import 'dart:core' as core;
// import 'dart:core';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:barcode_widget/barcode_widget.dart' as b_widget;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter_contacts/flutter_contacts.dart' as fc;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:universal_html/html.dart' as html;
// import 'package:path_provider/path_provider.dart';
// import 'package:gal/gal.dart';
// import 'package:pasteboard/pasteboard.dart';
// import '../services/history_service.dart';
// import './generic_form_screen.dart';

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

//   // কাস্টমাইজেশন স্টেট ভেরিয়েবলসমূহ
//   late Color _dotsColor;
//   late Color _eyeColor;
//   late Color _bgColor;
//   QrDataModuleShape _dotShape = QrDataModuleShape.square;
//   QrEyeShape _eyeShape = QrEyeShape.square;
//   double _dotScale = 1.0;
//   String _selectedFrame = 'None';
//   int _selectedTemplateIndex = 0;

//   final Map<String, String> _logoAssets = {
//     'WiFi': 'assets/logos/wifi.png',
//     'Facebook': 'assets/logos/facebook.png',
//     'YouTube': 'assets/logos/youtube.png',
//     'WhatsApp': 'assets/logos/whatsapp.png',
//     'Email': 'assets/logos/email.png',
//   };

//   final core.List<Color> _paletteColors = [
//     Colors.black,
//     Colors.white,
//     const Color(0xFF1E3A8A),
//     const Color(0xFF2563EB),
//     const Color(0xFF059669),
//     const Color(0xFFDC2626),
//     const Color(0xFF7C3AED),
//     const Color(0xFFD97706),
//     const Color(0xFFDB2777),
//     const Color(0xFFFEF3C7),
//     const Color(0xFFDBEAFE),
//   ];

//   final core.List<core.Map<core.String, core.dynamic>> _templates = [
//     {
//       'name': 'Classic',
//       'dots': Colors.black,
//       'eye': Colors.black,
//       'bg': Colors.white,
//       'dotShape': QrDataModuleShape.square,
//       'eyeShape': QrEyeShape.square,
//       'frame': 'None',
//     },
//     {
//       'name': 'Modern Dots',
//       'dots': const Color(0xFF1E3A8A),
//       'eye': const Color(0xFF2563EB),
//       'bg': Colors.white,
//       'dotShape': QrDataModuleShape.circle,
//       'eyeShape': QrEyeShape.circle,
//       'frame': 'Simple Border',
//     },
//     {
//       'name': 'Scan Badge',
//       'dots': Colors.black,
//       'eye': const Color(0xFFDC2626),
//       'bg': Colors.white,
//       'dotShape': QrDataModuleShape.square,
//       'eyeShape': QrEyeShape.circle,
//       'frame': 'Scan Me Bottom',
//     },
//     {
//       'name': 'Emerald Pro',
//       'dots': const Color(0xFF065F46),
//       'eye': const Color(0xFF059669),
//       'bg': const Color(0xFFECFDF5),
//       'dotShape': QrDataModuleShape.circle,
//       'eyeShape': QrEyeShape.square,
//       'frame': 'Badge Top',
//     },
//     {
//       'name': 'Royal Gold',
//       'dots': const Color(0xFF78350F),
//       'eye': const Color(0xFFD97706),
//       'bg': const Color(0xFFFEF3C7),
//       'dotShape': QrDataModuleShape.circle,
//       'eyeShape': QrEyeShape.circle,
//       'frame': 'Scan Me Bottom',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _dotsColor = widget.qrColor;
//     _eyeColor = widget.qrColor;
//     _bgColor = widget.qrBgColor;
//     _checkFavoriteStatus();
//   }

//   void _applyTemplate(int index) {
//     final t = _templates[index];
//     setState(() {
//       _selectedTemplateIndex = index;
//       _dotsColor = t['dots'] as Color;
//       _eyeColor = t['eye'] as Color;
//       _bgColor = t['bg'] as Color;
//       _dotShape = t['dotShape'] as QrDataModuleShape;
//       _eyeShape = t['eyeShape'] as QrEyeShape;
//       _selectedFrame = t['frame'] as String;
//     });
//   }

//   Future<void> _exportSingleQrToCSV() async {
//     try {
//       StringBuffer csvBuilder = StringBuffer();
//       csvBuilder.writeln("ID,Category,Content,Date,Is Barcode");

//       String id = widget.itemId ?? DateTime.now().millisecondsSinceEpoch.toString();
//       String excelId = '="$id"';
//       String type = widget.isBarcodeResult ? 'barcode' : 'qr_code';
//       String content = '"${widget.rawValue.replaceAll('"', '""')}"';

//       DateTime now = DateTime.now();
//       String formattedDate =
//           "${now.month}/${now.day}/${now.year % 100} ${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

//       csvBuilder.writeln("$excelId,$type,$content,$formattedDate,${widget.isBarcodeResult}");

//       if (kIsWeb) {
//         final bytes = Uri.encodeComponent(csvBuilder.toString());
//         html.AnchorElement(href: "data:text/csv;charset=utf-8,%EF%BB%BF$bytes")
//           ..setAttribute("download", "quickscan_item_$id.csv")
//           ..click();

//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Item CSV downloaded successfully! 📊'),
//             backgroundColor: Colors.blueAccent,
//           ),
//         );
//       } else {
//         Directory? directory;
//         if (Platform.isAndroid) {
//           directory = Directory('/storage/emulated/0/Download');
//           if (!await directory.exists()) {
//             directory = await getExternalStorageDirectory();
//           }
//         } else if (Platform.isIOS) {
//           directory = await getApplicationDocumentsDirectory();
//         }

//         if (directory != null) {
//           final String filePath = "${directory.path}/quickscan_item_$id.csv";
//           final File file = File(filePath);
//           await file.writeAsString(csvBuilder.toString());

//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('CSV saved to Downloads:\n$filePath 💾'),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 4),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('CSV Export failed: $e'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
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
//     try {
//       String formattedUrl = urlString.trim();
//       if (!formattedUrl.startsWith('http://') &&
//           !formattedUrl.startsWith('https://') &&
//           !formattedUrl.startsWith('mailto:') &&
//           !formattedUrl.startsWith('tel:') &&
//           !formattedUrl.startsWith('sms:') &&
//           !formattedUrl.startsWith('mms:') &&
//           !formattedUrl.startsWith('geo:')) {
//         formattedUrl = 'https://$formattedUrl';
//       }

//       final Uri url = Uri.parse(formattedUrl);
//       bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
//       if (!launched) {
//         await launchUrl(url, mode: LaunchMode.platformDefault);
//       }
//     } catch (e) {
//       debugPrint("Could not launch $urlString: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: Colors.redAccent,
//             content: Text("Cannot open link: $e"),
//           ),
//         );
//       }
//     }
//   }

//   void _searchOnGoogle() {
//     final String query = Uri.encodeComponent(widget.rawValue.trim());
//     _launchURL("https://www.google.com/search?q=$query");
//   }

//   void _openInMap() {
//     String query = widget.rawValue;
//     if (_isGeo) {
//       query = widget.rawValue.replaceAll('geo:', '');
//     }
//     _launchURL("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
//   }

//   void _sendEmail() {
//     String email = widget.rawValue;
//     if (email.startsWith('MATMSG:')) {
//       RegExp toExp = RegExp(r'TO:(.*?);');
//       if (toExp.hasMatch(email)) {
//         email = toExp.firstMatch(email)!.group(1) ?? '';
//       }
//     } else if (email.startsWith('mailto:')) {
//       email = email.replaceAll('mailto:', '');
//     }
//     _launchURL("mailto:${email.trim()}");
//   }

//   // --- আপডেট করা নিরাপদ ওয়াইফাই কানেক্ট মেথড (wifi_iot বাদ দিয়ে ক্লিপবোর্ড ও সেটিংস ফ্লো) ---
//   Future<void> _connectToWifi() async {
//     final String data = widget.rawValue;
//     final core.List<String> parts = data.substring(5).split(';');
//     String ssid = "";
//     String pass = "";

//     for (var part in parts) {
//       if (part.startsWith('S:')) ssid = part.substring(2);
//       if (part.startsWith('P:')) pass = part.substring(2);
//     }

//     if (ssid.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Invalid WiFi QR Code: Missing SSID")),
//         );
//       }
//       return;
//     }

//     if (pass.isNotEmpty) {
//       await Clipboard.setData(ClipboardData(text: pass));
//     }

//     if (!mounted) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E1E),
//         title: const Row(
//           children: [
//             Icon(Icons.wifi, color: Colors.blueAccent),
//             SizedBox(width: 10),
//             Text('Connect to Wi-Fi', style: TextStyle(color: Colors.white, fontSize: 18)),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Network (SSID): $ssid', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             if (pass.isNotEmpty) ...[
//               Text('Password: $pass', style: const TextStyle(color: Colors.greenAccent)),
//               const SizedBox(height: 10),
//               const Text(
//                 '✅ Password copied to clipboard! Open Wi-Fi settings, select the network, and paste the password.',
//                 style: TextStyle(color: Colors.white70, fontSize: 12),
//               ),
//             ] else
//               const Text('Open network (No password required).', style: TextStyle(color: Colors.white70, fontSize: 12)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
//             onPressed: () async {
//               Navigator.pop(context);
//               try {
//                 if (Platform.isAndroid) {
//                   await launchUrl(Uri.parse('android.settings.WIFI_SETTINGS'));
//                 } else {
//                   await launchUrl(Uri.parse('App-Prefs:root=WIFI'));
//                 }
//               } catch (_) {
//                 if (mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Password copied! Please open your phone's Wi-Fi settings.")),
//                   );
//                 }
//               }
//             },
//             child: const Text('Open Wi-Fi Settings', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToEditScreen() {
//     String formType = 'text';
//     String title = 'Edit Text';

//     if (widget.isBarcodeResult) {
//       formType = 'barcode';
//       title = 'Edit Barcode';
//     } else if (_isUrl) {
//       formType = 'url';
//       title = 'Edit URL';
//     } else if (_isWifi) {
//       formType = 'wifi';
//       title = 'Edit WiFi';
//     } else if (_isEmail) {
//       formType = 'email';
//       title = 'Edit Email';
//     } else if (_isSMS) {
//       formType = 'sms';
//       title = 'Edit SMS';
//     } else if (_isContact) {
//       formType = 'contact';
//       title = 'Edit Contact';
//     } else if (_isPhone) {
//       formType = 'phone';
//       title = 'Edit Phone';
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GenericFormScreen(
//           formType: formType,
//           title: title,
//           isBarcode: widget.isBarcodeResult,
//           initialData: widget.rawValue,
//         ),
//       ),
//     );
//   }

//   void _sendSMS({bool isMMS = false}) {
//     final String cleanData = widget.rawValue.replaceAll('smsto:', '');
//     final core.List<String> parts = cleanData.split(':');
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
//           phones: phone.isNotEmpty
//               ? [fc.Phone(number: phone, label: fc.Label(fc.PhoneLabel.mobile))]
//               : [],
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
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed: $e')),
//           );
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

//   Future<Uint8List?> _captureQrImage() async {
//     try {
//       RenderRepaintBoundary boundary =
//           _qrBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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
//         if (kDebugMode) print("Sharing failed: $e");
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
//         html.AnchorElement(href: url)
//           ..setAttribute("download", "qrcode_${DateTime.now().millisecondsSinceEpoch}.png")
//           ..click();
//         html.Url.revokeObjectUrl(url);
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('QR Code image downloaded successfully! 📥')),
//         );
//       } catch (e) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Download failed: $e')),
//         );
//       } finally {
//         setState(() => _isSaving = false);
//       }
//     } else {
//       try {
//         final hasAccess = await Gal.hasAccess();
//         if (!hasAccess) await Gal.requestAccess();

//         final tempDir = await getTemporaryDirectory();
//         final String filePath = '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
//         final File imgFile = File(filePath);
//         await imgFile.writeAsBytes(pngBytes);
//         await Gal.putImage(filePath);

//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             backgroundColor: Colors.green,
//             content: Text('QR Code image saved to Gallery! 🎉'),
//           ),
//         );
//       } catch (e) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: Colors.redAccent,
//             content: Text('Failed to save image: $e'),
//           ),
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
//       case 'ean8':
//         return b_widget.Barcode.ean8();
//       case 'ean13':
//         return b_widget.Barcode.ean13();
//       case 'upce':
//         return b_widget.Barcode.code128();
//       case 'upca':
//         return b_widget.Barcode.upcA();
//       case 'code39':
//         return b_widget.Barcode.code39();
//       case 'code93':
//         return b_widget.Barcode.code93();
//       case 'code128':
//         return b_widget.Barcode.code128();
//       case 'pdf417':
//         return b_widget.Barcode.pdf417();
//       case 'codabar':
//         return b_widget.Barcode.codabar();
//       default:
//         return b_widget.Barcode.code128();
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

//   Widget _buildFramedQrContainer(Widget qrChild) {
//     if (_selectedFrame == 'Simple Border') {
//       return Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: _bgColor,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: _eyeColor, width: 4),
//         ),
//         child: qrChild,
//       );
//     } else if (_selectedFrame == 'Scan Me Bottom') {
//       return Container(
//         padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
//         decoration: BoxDecoration(
//           color: _bgColor,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: _eyeColor, width: 3.5),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             qrChild,
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
//               decoration: BoxDecoration(
//                 color: _eyeColor,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Text(
//                 'SCAN ME',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w900,
//                   fontSize: 13,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (_selectedFrame == 'Badge Top') {
//       return Container(
//         padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
//         decoration: BoxDecoration(
//           color: _bgColor,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: _eyeColor, width: 3.5),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
//               decoration: BoxDecoration(
//                 color: _eyeColor,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 'SCAN HERE',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 11,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             qrChild,
//           ],
//         ),
//       );
//     }

//     return Container(
//       color: _bgColor,
//       padding: const EdgeInsets.all(16),
//       child: qrChild,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       appBar: AppBar(
//         title: const Text('Result & Customize', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit_note_rounded, color: Colors.orangeAccent, size: 28),
//             tooltip: 'Edit & Re-generate',
//             onPressed: _navigateToEditScreen,
//           ),
//           if (widget.itemId != null)
//             IconButton(
//               icon: Icon(_isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
//               onPressed: () async {
//                 await HistoryService.toggleFavorite(id: widget.itemId!);
//                 setState(() => _isFav = !_isFav);
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

//             const SizedBox(height: 15),

//             Center(
//               child: RepaintBoundary(
//                 key: _qrBoundaryKey,
//                 child: widget.isBarcodeResult
//                     ? Container(
//                         color: Colors.white,
//                         padding: const EdgeInsets.all(16),
//                         child: b_widget.BarcodeWidget(
//                           barcode: _getBarcodeType(widget.barcodeTypeTag),
//                           data: widget.rawValue.isEmpty ? "12345678" : widget.rawValue,
//                           width: 250,
//                           height: 90,
//                           style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                           errorBuilder: (context, error) => const Text(
//                             'Invalid data format',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       )
//                     : _buildFramedQrContainer(
//                         QrImageView(
//                           data: widget.rawValue,
//                           version: QrVersions.auto,
//                           size: 175.0,
//                           gapless: _dotScale >= 0.9,
//                           errorCorrectionLevel: QrErrorCorrectLevel.H,
//                           eyeStyle: QrEyeStyle(
//                             eyeShape: _eyeShape,
//                             color: _eyeColor,
//                           ),
//                           dataModuleStyle: QrDataModuleStyle(
//                             dataModuleShape: _dotShape,
//                             color: _dotsColor,
//                           ),
//                           embeddedImage: _getEmbeddedImage(),
//                           embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(38, 38)),
//                         ),
//                       ),
//               ),
//             ),

//             const SizedBox(height: 25),

//             if (!widget.isBarcodeResult)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   children: [
//                     _buildAccordionSection(
//                       icon: Icons.palette_outlined,
//                       title: 'Templates',
//                       initiallyExpanded: true,
//                       child: SizedBox(
//                         height: 65,
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: _templates.length,
//                           itemBuilder: (context, index) {
//                             final t = _templates[index];
//                             final isSelected = _selectedTemplateIndex == index;
//                             return GestureDetector(
//                               onTap: () => _applyTemplate(index),
//                               child: Container(
//                                 margin: const EdgeInsets.only(right: 10),
//                                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   color: t['bg'] as Color,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: isSelected ? Colors.blueAccent : Colors.white24,
//                                     width: isSelected ? 3 : 1,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.qr_code_2, color: t['eye'] as Color, size: 22),
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       t['name'] as String,
//                                       style: TextStyle(
//                                         color: t['dots'] as Color,
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     _buildAccordionSection(
//                       icon: Icons.color_lens_outlined,
//                       title: 'Appearance & Dots Size',
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildColorSelectorRow('Background Colour', _bgColor, (c) => setState(() => _bgColor = c)),
//                           const SizedBox(height: 12),
//                           _buildColorSelectorRow('Dots Colour', _dotsColor, (c) => setState(() => _dotsColor = c)),
//                           const SizedBox(height: 12),
//                           _buildColorSelectorRow('Marker Colour (Corners)', _eyeColor, (c) => setState(() => _eyeColor = c)),
//                           const Divider(color: Colors.white12, height: 24),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text('Dots Density / Scale', style: TextStyle(color: Colors.white70, fontSize: 13)),
//                               Text('Dot Scale: ${_dotScale.toStringAsFixed(1)}', style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
//                             ],
//                           ),
//                           Slider(
//                             value: _dotScale,
//                             min: 0.5,
//                             max: 1.0,
//                             divisions: 5,
//                             activeColor: Colors.blueAccent,
//                             onChanged: (val) => setState(() => _dotScale = val),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     _buildAccordionSection(
//                       icon: Icons.grid_view_rounded,
//                       title: 'Shape & Form',
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Dots Style', style: TextStyle(color: Colors.white70, fontSize: 13)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               _buildShapeChip('Square Dots', Icons.crop_square, _dotShape == QrDataModuleShape.square, () => setState(() => _dotShape = QrDataModuleShape.square)),
//                               const SizedBox(width: 12),
//                               _buildShapeChip('Circle Dots', Icons.circle, _dotShape == QrDataModuleShape.circle, () => setState(() => _dotShape = QrDataModuleShape.circle)),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           const Text('Marker Border & Centre', style: TextStyle(color: Colors.white70, fontSize: 13)),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               _buildShapeChip('Square Marker', Icons.check_box_outline_blank, _eyeShape == QrEyeShape.square, () => setState(() => _eyeShape = QrEyeShape.square)),
//                               const SizedBox(width: 12),
//                               _buildShapeChip('Circle Marker', Icons.radio_button_unchecked, _eyeShape == QrEyeShape.circle, () => setState(() => _eyeShape = QrEyeShape.circle)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     _buildAccordionSection(
//                       icon: Icons.crop_free_rounded,
//                       title: 'Frames',
//                       child: Wrap(
//                         spacing: 10,
//                         runSpacing: 10,
//                         children: ['None', 'Simple Border', 'Scan Me Bottom', 'Badge Top'].map((frame) {
//                           final isSelected = _selectedFrame == frame;
//                           return ChoiceChip(
//                             label: Text(frame),
//                             selected: isSelected,
//                             selectedColor: Colors.blueAccent,
//                             backgroundColor: Colors.white10,
//                             labelStyle: TextStyle(
//                               color: isSelected ? Colors.white : Colors.white70,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                             onSelected: (_) => setState(() => _selectedFrame = frame),
//                           );
//                         }).toList(),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     _buildAccordionSection(
//                       icon: Icons.image_outlined,
//                       title: 'Center Logo',
//                       child: SizedBox(
//                         height: 46,
//                         child: ListView(
//                           scrollDirection: Axis.horizontal,
//                           children: [
//                             GestureDetector(
//                               onTap: () => setState(() => _selectedLogoAsset = null),
//                               child: Container(
//                                 margin: const EdgeInsets.only(right: 12),
//                                 width: 42,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Colors.white10,
//                                   border: Border.all(color: Colors.white24),
//                                 ),
//                                 child: const Icon(Icons.block, color: Colors.redAccent, size: 18),
//                               ),
//                             ),
//                             ..._logoAssets.entries.map((entry) {
//                               final isSelected = _selectedLogoAsset == entry.value;
//                               return GestureDetector(
//                                 onTap: () => setState(() => _selectedLogoAsset = entry.value),
//                                 child: Container(
//                                   margin: const EdgeInsets.only(right: 12),
//                                   padding: const EdgeInsets.all(4),
//                                   width: 42,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: isSelected ? Colors.blue : Colors.transparent,
//                                       width: 2.5,
//                                     ),
//                                   ),
//                                   child: Image.asset(
//                                     entry.value,
//                                     fit: BoxFit.contain,
//                                     errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.black, size: 16),
//                                   ),
//                                 ),
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildUniversalBottomBar(),
//     );
//   }

//   Widget _buildAccordionSection({
//     required IconData icon,
//     required String title,
//     required Widget child,
//     bool initiallyExpanded = false,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E1E1E),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.white12),
//       ),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           initiallyExpanded: initiallyExpanded,
//           leading: Icon(icon, color: Colors.blueAccent, size: 22),
//           title: Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 15,
//             ),
//           ),
//           iconColor: Colors.white70,
//           collapsedIconColor: Colors.white54,
//           childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           children: [child],
//         ),
//       ),
//     );
//   }

//   Widget _buildColorSelectorRow(String label, Color currentColor, Function(Color) onSelect) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 36,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _paletteColors.length,
//             itemBuilder: (context, index) {
//               final color = _paletteColors[index];
//               final isSelected = currentColor.toARGB32() == color.toARGB32();
//               return GestureDetector(
//                 onTap: () => onSelect(color),
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 10),
//                   width: 34,
//                   height: 34,
//                   decoration: BoxDecoration(
//                     color: color,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isSelected ? Colors.blueAccent : Colors.white30,
//                       width: isSelected ? 3 : 1,
//                     ),
//                   ),
//                   child: isSelected
//                       ? Icon(
//                           Icons.check,
//                           size: 16,
//                           color: color == Colors.white || color.computeLuminance() > 0.5
//                               ? Colors.black
//                               : Colors.white,
//                         )
//                       : null,
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildShapeChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.white10,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: isSelected ? Colors.blueAccent : Colors.white12,
//               width: 1.5,
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: isSelected ? Colors.blueAccent : Colors.white70, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected ? Colors.blueAccent : Colors.white70,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   core.List<Widget> _buildDynamicButtons() {
//     core.List<Widget> buttons = [];

//     buttons.add(_actionIconButton(icon: Icons.edit_note, label: 'Edit Content', onTap: _navigateToEditScreen));
//     buttons.add(const SizedBox(width: 20));

//     if (_isWifi) {
//       buttons.add(_actionIconButton(icon: Icons.wifi, label: 'Connect', onTap: _connectToWifi));
//     } else if (_isEmail) {
//       buttons.add(_actionIconButton(
//         icon: Icons.email_outlined,
//         label: 'Send Email',
//         onTap: _sendEmail,
//       ));
//     } else if (_isPhone) {
//       buttons.add(_actionIconButton(icon: Icons.phone, label: 'Call', onTap: () => _launchURL(widget.rawValue)));
//     } else if (_isContact) {
//       buttons.add(_actionIconButton(icon: Icons.person_add_alt_1_rounded, label: 'Add contact', onTap: _saveContactFromQR));
//     } else if (_isSMS) {
//       buttons.add(_actionIconButton(icon: Icons.chat_bubble_outline, label: 'Send SMS', onTap: () => _sendSMS(isMMS: false)));
//       buttons.add(const SizedBox(width: 20));
//       buttons.add(_actionIconButton(icon: Icons.image_outlined, label: 'Send MMS', onTap: () => _sendSMS(isMMS: true)));
//     } else if (_isGeo || widget.rawValue.toLowerCase().contains('bangladesh') || widget.rawValue.toLowerCase().contains('dhaka')) {
//       buttons.add(_actionIconButton(icon: Icons.location_on_rounded, label: 'Show Map', onTap: _openInMap));
//     } else if (_isUrl) {
//       buttons.add(_actionIconButton(icon: Icons.open_in_browser, label: 'Open', onTap: () => _launchURL(widget.rawValue)));
//     } else {
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
//           IconButton(
//             icon: const Icon(Icons.description_outlined, color: Colors.greenAccent),
//             onPressed: _exportSingleQrToCSV,
//             tooltip: 'Export CSV Data',
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
import 'dart:core' as core;
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart' as b_widget;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:pasteboard/pasteboard.dart';
import '../services/history_service.dart';
import './generic_form_screen.dart';

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
  final ImagePicker _picker = ImagePicker();

  String? _selectedLogoAsset;
  String? _pickedLogoPath;

  // Appearance states
  late Color _bgColor;
  late Color _dotsColor;
  late Color _markerBorderColor;
  late Color _markerCentreColor;

  late TextEditingController _bgHexController;
  late TextEditingController _dotsHexController;
  late TextEditingController _markerBorderHexController;
  late TextEditingController _markerCentreHexController;
  late TextEditingController _frameLabelController;

  double _dotScale = 0.6;

  // Shape & Form states
  String _dotShape = 'square';
  String _markerBorderShape = 'square';
  String _markerCentreShape = 'square';

  // Frames & Templates states
  String _selectedFrame = 'None';
  int _selectedTemplateIndex = 0;

  static const core.List<core.String> _dotShapeOptions = [
    'square',
    'dots',
    'triangle',
    'star',
    'diamond',
    'lines',
    'bars',
    'rounded',
  ];

  static const core.List<core.String> _markerBorderOptions = [
    'square',
    'rounded',
    'circle',
    'teardrop',
    'dotted',
  ];

  static const core.List<core.String> _markerCentreOptions = [
    'square',
    'rounded',
    'teardrop',
    'star',
    'octagon',
    'plus',
    'grid',
    'diamond',
  ];

  final Map<String, String> _logoAssets = {
    'WiFi': 'assets/logos/wifi.png',
    'Facebook': 'assets/logos/facebook.png',
    'YouTube': 'assets/logos/youtube.png',
    'WhatsApp': 'assets/logos/whatsapp.png',
    'Email': 'assets/logos/email.png',
  };

  final core.List<Color> _paletteColors = [
    Colors.black,
    Colors.white,
    const Color(0xFF0A1A2F),
    const Color(0xFF1E3A8A),
    const Color(0xFF2563EB),
    const Color(0xFF059669),
    const Color(0xFFDC2626),
    const Color(0xFF7C3AED),
    const Color(0xFFD97706),
    const Color(0xFFDB2777),
    const Color(0xFFFEF3C7),
    const Color(0xFFDBEAFE),
  ];

  final core.List<core.Map<core.String, core.dynamic>> _templates = [
    {
      'name': 'Classic',
      'bg': Colors.white,
      'dots': const Color(0xFF0A1A2F),
      'markerBorder': const Color(0xFF0A1A2F),
      'markerCentre': const Color(0xFF0A1A2F),
      'dotScale': 0.6,
      'dotShape': 'square',
      'markerBorderShape': 'square',
      'markerCentreShape': 'square',
      'frame': 'None',
      'frameLabel': 'SCAN ME',
    },
    {
      'name': 'Modern Dots',
      'bg': Colors.white,
      'dots': const Color(0xFF1E3A8A),
      'markerBorder': const Color(0xFF2563EB),
      'markerCentre': const Color(0xFF2563EB),
      'dotScale': 0.7,
      'dotShape': 'dots',
      'markerBorderShape': 'circle',
      'markerCentreShape': 'rounded',
      'frame': 'Simple Border',
      'frameLabel': 'SCAN ME',
    },
    {
      'name': 'Scan Badge',
      'bg': Colors.white,
      'dots': const Color(0xFF0F172A),
      'markerBorder': const Color(0xFFDC2626),
      'markerCentre': const Color(0xFFDC2626),
      'dotScale': 0.8,
      'dotShape': 'diamond',
      'markerBorderShape': 'rounded',
      'markerCentreShape': 'star',
      'frame': 'Scan Me Bottom',
      'frameLabel': 'SCAN ME',
    },
    {
      'name': 'Emerald Pro',
      'bg': const Color(0xFFECFDF5),
      'dots': const Color(0xFF065F46),
      'markerBorder': const Color(0xFF059669),
      'markerCentre': const Color(0xFF059669),
      'dotScale': 0.7,
      'dotShape': 'rounded',
      'markerBorderShape': 'teardrop',
      'markerCentreShape': 'teardrop',
      'frame': 'Badge Top',
      'frameLabel': 'SCAN HERE',
    },
    {
      'name': 'Royal Gold',
      'bg': const Color(0xFFFEF3C7),
      'dots': const Color(0xFF78350F),
      'markerBorder': const Color(0xFFD97706),
      'markerCentre': const Color(0xFFB45309),
      'dotScale': 0.8,
      'dotShape': 'triangle',
      'markerBorderShape': 'dotted',
      'markerCentreShape': 'octagon',
      'frame': 'Scan Me Bottom',
      'frameLabel': 'OFFICIAL QR',
    },
  ];

  String _colorToHex(Color c) {
    final int rgb = c.toARGB32() & 0xFFFFFF;
    return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  Color? _parseHexColor(String raw) {
    final String cleaned = raw.trim().replaceFirst('#', '');
    if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(cleaned)) return null;
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  void _syncHexControllers() {
    _bgHexController.text = _colorToHex(_bgColor);
    _dotsHexController.text = _colorToHex(_dotsColor);
    _markerBorderHexController.text = _colorToHex(_markerBorderColor);
    _markerCentreHexController.text = _colorToHex(_markerCentreColor);
  }

  @override
  void initState() {
    super.initState();
    _bgColor = widget.qrBgColor;
    _dotsColor = widget.qrColor;
    _markerBorderColor = widget.qrColor;
    _markerCentreColor = widget.qrColor;
    _pickedLogoPath = widget.customLogoPath;

    _bgHexController = TextEditingController(text: _colorToHex(_bgColor));
    _dotsHexController = TextEditingController(text: _colorToHex(_dotsColor));
    _markerBorderHexController = TextEditingController(text: _colorToHex(_markerBorderColor));
    _markerCentreHexController = TextEditingController(text: _colorToHex(_markerCentreColor));
    _frameLabelController = TextEditingController(text: 'SCAN ME');

    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _bgHexController.dispose();
    _dotsHexController.dispose();
    _markerBorderHexController.dispose();
    _markerCentreHexController.dispose();
    _frameLabelController.dispose();
    super.dispose();
  }

  void _applyTemplate(int index) {
    final t = _templates[index];
    setState(() {
      _selectedTemplateIndex = index;
      _bgColor = t['bg'] as Color;
      _dotsColor = t['dots'] as Color;
      _markerBorderColor = t['markerBorder'] as Color;
      _markerCentreColor = t['markerCentre'] as Color;
      _dotScale = (t['dotScale'] as double?) ?? 0.6;
      _dotShape = t['dotShape'] as String;
      _markerBorderShape = t['markerBorderShape'] as String;
      _markerCentreShape = t['markerCentreShape'] as String;
      _selectedFrame = t['frame'] as String;
      if (t['frameLabel'] != null && (t['frameLabel'] as String).isNotEmpty) {
        _frameLabelController.text = t['frameLabel'] as String;
      }
      _syncHexControllers();
    });
  }

  Future<void> _pickCustomLogoFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedLogoPath = picked.path;
          _selectedLogoAsset = null;
        });
      }
    } catch (e) {
      debugPrint("Custom logo pick failed: $e");
    }
  }

  void _clearLogoSelection() {
    setState(() {
      _pickedLogoPath = null;
      _selectedLogoAsset = null;
    });
  }

  Future<void> _exportSingleQrToCSV() async {
    try {
      StringBuffer csvBuilder = StringBuffer();
      csvBuilder.writeln("ID,Category,Content,Date,Is Barcode");

      String id = widget.itemId ?? DateTime.now().millisecondsSinceEpoch.toString();
      String excelId = '="$id"';
      String type = widget.isBarcodeResult ? 'barcode' : 'qr_code';
      String content = '"${widget.rawValue.replaceAll('"', '""')}"';

      DateTime now = DateTime.now();
      String formattedDate =
          "${now.month}/${now.day}/${now.year % 100} ${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

      csvBuilder.writeln("$excelId,$type,$content,$formattedDate,${widget.isBarcodeResult}");

      if (kIsWeb) {
        final bytes = Uri.encodeComponent(csvBuilder.toString());
        html.AnchorElement(href: "data:text/csv;charset=utf-8,%EF%BB%BF$bytes")
          ..setAttribute("download", "quickscan_item_$id.csv")
          ..click();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item CSV downloaded successfully! 📊'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      } else {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final String filePath = "${directory.path}/quickscan_item_$id.csv";
          final File file = File(filePath);
          await file.writeAsString(csvBuilder.toString());

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV saved to Downloads:\n$filePath 💾'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV Export failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
    try {
      String formattedUrl = urlString.trim();
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://') &&
          !formattedUrl.startsWith('mailto:') &&
          !formattedUrl.startsWith('tel:') &&
          !formattedUrl.startsWith('sms:') &&
          !formattedUrl.startsWith('mms:') &&
          !formattedUrl.startsWith('geo:')) {
        formattedUrl = 'https://$formattedUrl';
      }

      final Uri url = Uri.parse(formattedUrl);
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Could not launch $urlString: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Cannot open link: $e"),
          ),
        );
      }
    }
  }

  void _searchOnGoogle() {
    final String query = Uri.encodeComponent(widget.rawValue.trim());
    _launchURL("https://www.google.com/search?q=$query");
  }

  void _openInMap() {
    String query = widget.rawValue;
    if (_isGeo) {
      query = widget.rawValue.replaceAll('geo:', '');
    }
    _launchURL("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
  }

  void _sendEmail() {
    String email = widget.rawValue;
    if (email.startsWith('MATMSG:')) {
      RegExp toExp = RegExp(r'TO:(.*?);');
      if (toExp.hasMatch(email)) {
        email = toExp.firstMatch(email)!.group(1) ?? '';
      }
    } else if (email.startsWith('mailto:')) {
      email = email.replaceAll('mailto:', '');
    }
    _launchURL("mailto:${email.trim()}");
  }

  Future<void> _connectToWifi() async {
    final String data = widget.rawValue;
    final core.List<String> parts = data.substring(5).split(';');
    String ssid = "";
    String pass = "";

    for (var part in parts) {
      if (part.startsWith('S:')) ssid = part.substring(2);
      if (part.startsWith('P:')) pass = part.substring(2);
    }

    if (ssid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid WiFi QR Code: Missing SSID")),
        );
      }
      return;
    }

    if (pass.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: pass));
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.wifi, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text('Connect to Wi-Fi', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network (SSID): $ssid', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (pass.isNotEmpty) ...[
              Text('Password: $pass', style: const TextStyle(color: Colors.greenAccent)),
              const SizedBox(height: 10),
              const Text(
                '✅ Password copied to clipboard! Open Wi-Fi settings, select the network, and paste the password.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ] else
              const Text('Open network (No password required).', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (Platform.isAndroid) {
                  await launchUrl(Uri.parse('android.settings.WIFI_SETTINGS'));
                } else {
                  await launchUrl(Uri.parse('App-Prefs:root=WIFI'));
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password copied! Please open your phone's Wi-Fi settings.")),
                  );
                }
              }
            },
            child: const Text('Open Wi-Fi Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
          initialData: widget.rawValue,
        ),
      ),
    );
  }

  void _sendSMS({bool isMMS = false}) {
    final String cleanData = widget.rawValue.replaceAll('smsto:', '');
    final core.List<String> parts = cleanData.split(':');
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
          phones: phone.isNotEmpty
              ? [fc.Phone(number: phone, label: fc.Label(fc.PhoneLabel.mobile))]
              : [],
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')),
          );
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
      RenderRepaintBoundary boundary =
          _qrBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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
        if (kDebugMode) print("Sharing failed: $e");
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
        html.AnchorElement(href: url)
          ..setAttribute("download", "qrcode_${DateTime.now().millisecondsSinceEpoch}.png")
          ..click();
        html.Url.revokeObjectUrl(url);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code image downloaded successfully! 📥')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      } finally {
        setState(() => _isSaving = false);
      }
    } else {
      try {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) await Gal.requestAccess();

        final tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
        final File imgFile = File(filePath);
        await imgFile.writeAsBytes(pngBytes);
        await Gal.putImage(filePath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('QR Code image saved to Gallery! 🎉'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Failed to save image: $e'),
          ),
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
      case 'ean8':
        return b_widget.Barcode.ean8();
      case 'ean13':
        return b_widget.Barcode.ean13();
      case 'upce':
        return b_widget.Barcode.code128();
      case 'upca':
        return b_widget.Barcode.upcA();
      case 'code39':
        return b_widget.Barcode.code39();
      case 'code93':
        return b_widget.Barcode.code93();
      case 'code128':
        return b_widget.Barcode.code128();
      case 'pdf417':
        return b_widget.Barcode.pdf417();
      case 'codabar':
        return b_widget.Barcode.codabar();
      default:
        return b_widget.Barcode.code128();
    }
  }

  QrDataModuleShape _mappedQrModuleShape() {
    if (_dotShape == 'dots' || _dotShape == 'rounded') {
      return QrDataModuleShape.circle;
    }
    return QrDataModuleShape.square;
  }

  QrEyeShape _mappedQrEyeShape() {
    if (_markerBorderShape == 'circle' || _markerBorderShape == 'teardrop') {
      return QrEyeShape.circle;
    }
    return QrEyeShape.square;
  }

  ImageProvider? _getEmbeddedImage() {
    if (_pickedLogoPath != null && _pickedLogoPath!.isNotEmpty) {
      return FileImage(File(_pickedLogoPath!));
    }
    if (_selectedLogoAsset != null) {
      return AssetImage(_selectedLogoAsset!);
    }
    return null;
  }

  String _shapeLabel(String id) {
    switch (id) {
      case 'square':
        return 'Square';
      case 'dots':
        return 'Circle / Dots';
      case 'triangle':
        return 'Triangle';
      case 'star':
        return 'Star';
      case 'diamond':
        return 'Diamond';
      case 'lines':
        return 'Diagonal Lines';
      case 'bars':
        return 'Vertical Bars';
      case 'rounded':
        return 'Rounded';
      case 'circle':
        return 'Circle';
      case 'teardrop':
        return 'Leaf / Teardrop';
      case 'dotted':
        return 'Dotted Square';
      case 'octagon':
        return 'Octagon';
      case 'plus':
        return 'Plus';
      case 'grid':
        return 'Grid Dots';
      default:
        return id;
    }
  }

  Widget _buildFramedQrContainer(Widget qrChild) {
    final String labelText =
        _frameLabelController.text.trim().isEmpty ? 'SCAN ME' : _frameLabelController.text.trim();

    if (_selectedFrame == 'Simple Border') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _markerBorderColor, width: 4),
        ),
        child: qrChild,
      );
    } else if (_selectedFrame == 'Scan Me Bottom') {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _markerBorderColor, width: 3.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrChild,
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
              decoration: BoxDecoration(
                color: _markerBorderColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labelText.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_selectedFrame == 'Badge Top') {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _markerBorderColor, width: 3.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: _markerBorderColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                labelText.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            qrChild,
          ],
        ),
      );
    }

    return Container(
      color: _bgColor,
      padding: const EdgeInsets.all(16),
      child: qrChild,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double qrDisplaySize = 155.0 + (_dotScale * 35.0);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Result & Customize', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
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
                setState(() => _isFav = !_isFav);
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

            const SizedBox(height: 15),

            Center(
              child: RepaintBoundary(
                key: _qrBoundaryKey,
                child: widget.isBarcodeResult
                    ? Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: b_widget.BarcodeWidget(
                          barcode: _getBarcodeType(widget.barcodeTypeTag),
                          data: widget.rawValue.isEmpty ? "12345678" : widget.rawValue,
                          width: 250,
                          height: 90,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          errorBuilder: (context, error) => const Text(
                            'Invalid data format',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    : _buildFramedQrContainer(
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImageView(
                              data: widget.rawValue,
                              version: QrVersions.auto,
                              size: qrDisplaySize,
                              gapless: _dotScale >= 0.9,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                              eyeStyle: QrEyeStyle(
                                eyeShape: _mappedQrEyeShape(),
                                color: _markerBorderColor,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: _mappedQrModuleShape(),
                                color: _dotsColor,
                              ),
                              embeddedImage: _getEmbeddedImage(),
                              embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
                            ),
                            if (_dotShape != 'square' && _dotShape != 'dots')
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _QrPatternOverlayPainter(
                                      dotShape: _dotShape,
                                      markerBorderShape: _markerBorderShape,
                                      markerCentreShape: _markerCentreShape,
                                      dotsColor: _dotsColor,
                                      markerBorderColor: _markerBorderColor,
                                      markerCentreColor: _markerCentreColor,
                                      dotScale: _dotScale,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            if (!widget.isBarcodeResult)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // 1. Appearance
                    _buildAccordionSection(
                      icon: Icons.color_lens_outlined,
                      title: 'Appearance',
                      initiallyExpanded: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHexAndColorField(
                            label: 'Background Colour',
                            currentColor: _bgColor,
                            controller: _bgHexController,
                            onColorChanged: (c) {
                              setState(() {
                                _bgColor = c;
                                _bgHexController.text = _colorToHex(c);
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildHexAndColorField(
                            label: 'Dots Colour',
                            currentColor: _dotsColor,
                            controller: _dotsHexController,
                            onColorChanged: (c) {
                              setState(() {
                                _dotsColor = c;
                                _dotsHexController.text = _colorToHex(c);
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildHexAndColorField(
                            label: 'Marker border colour',
                            currentColor: _markerBorderColor,
                            controller: _markerBorderHexController,
                            onColorChanged: (c) {
                              setState(() {
                                _markerBorderColor = c;
                                _markerBorderHexController.text = _colorToHex(c);
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildHexAndColorField(
                            label: 'Marker centre colour',
                            currentColor: _markerCentreColor,
                            controller: _markerCentreHexController,
                            onColorChanged: (c) {
                              setState(() {
                                _markerCentreColor = c;
                                _markerCentreHexController.text = _colorToHex(c);
                              });
                            },
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          const Center(
                            child: Text(
                              'Dots Size',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Slider(
                            value: _dotScale,
                            min: 0.5,
                            max: 1.0,
                            divisions: 5,
                            activeColor: const Color(0xFF4338CA),
                            onChanged: (val) => setState(() => _dotScale = val),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('0.5', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              Text(
                                'Dot Scale: ${_dotScale.toStringAsFixed(1)}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Text('1.0', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 2. Shape & Form
                    _buildAccordionSection(
                      icon: Icons.grid_view_rounded,
                      title: 'Shape & Form',
                      initiallyExpanded: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dots', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.35,
                            ),
                            itemCount: _dotShapeOptions.length,
                            itemBuilder: (context, index) {
                              final shapeId = _dotShapeOptions[index];
                              final active = _dotShape == shapeId;
                              return _buildShapeGridTile(
                                label: _shapeLabel(shapeId),
                                active: active,
                                onTap: () => setState(() => _dotShape = shapeId),
                                preview: CustomPaint(
                                  size: const Size(44, 44),
                                  painter: _DotShapePreviewPainter(
                                    shapeId: shapeId,
                                    color: active ? Colors.blueAccent : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 18),
                          const Text('Marker Border', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.35,
                            ),
                            itemCount: _markerBorderOptions.length,
                            itemBuilder: (context, index) {
                              final shapeId = _markerBorderOptions[index];
                              final active = _markerBorderShape == shapeId;
                              return _buildShapeGridTile(
                                label: _shapeLabel(shapeId),
                                active: active,
                                onTap: () => setState(() => _markerBorderShape = shapeId),
                                preview: CustomPaint(
                                  size: const Size(44, 44),
                                  painter: _MarkerBorderPreviewPainter(
                                    shapeId: shapeId,
                                    color: active ? Colors.blueAccent : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 18),
                          const Text('Marker Centre', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.35,
                            ),
                            itemCount: _markerCentreOptions.length,
                            itemBuilder: (context, index) {
                              final shapeId = _markerCentreOptions[index];
                              final active = _markerCentreShape == shapeId;
                              return _buildShapeGridTile(
                                label: _shapeLabel(shapeId),
                                active: active,
                                onTap: () => setState(() => _markerCentreShape = shapeId),
                                preview: CustomPaint(
                                  size: const Size(44, 44),
                                  painter: _MarkerCentrePreviewPainter(
                                    shapeId: shapeId,
                                    color: active ? Colors.blueAccent : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 3. Frames
                    _buildAccordionSection(
                      icon: Icons.crop_free_rounded,
                      title: 'Frames',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ['None', 'Simple Border', 'Scan Me Bottom', 'Badge Top'].map((frame) {
                              final isSelected = _selectedFrame == frame;
                              return ChoiceChip(
                                label: Text(frame),
                                selected: isSelected,
                                selectedColor: Colors.blueAccent,
                                backgroundColor: Colors.white10,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                onSelected: (_) => setState(() => _selectedFrame = frame),
                              );
                            }).toList(),
                          ),
                          if (_selectedFrame != 'None') ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _frameLabelController,
                              maxLength: 24,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Frame Label Text',
                                labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 4. Logo
                    _buildAccordionSection(
                      icon: Icons.image_outlined,
                      title: 'Logo',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.photo_library_outlined, size: 16, color: Colors.white),
                                label: Text(_pickedLogoPath != null ? 'Change Custom Logo' : 'Pick Custom Logo'),
                                backgroundColor: _pickedLogoPath != null ? Colors.blueAccent : Colors.white12,
                                labelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                onPressed: _pickCustomLogoFromGallery,
                              ),
                              if (_pickedLogoPath != null || _selectedLogoAsset != null)
                                ActionChip(
                                  avatar: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                  label: const Text('Clear Logo'),
                                  backgroundColor: Colors.white10,
                                  labelStyle: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  onPressed: _clearLogoSelection,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 46,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                GestureDetector(
                                  onTap: _clearLogoSelection,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white10,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: const Icon(Icons.block, color: Colors.redAccent, size: 18),
                                  ),
                                ),
                                ..._logoAssets.entries.map((entry) {
                                  final isSelected = _pickedLogoPath == null && _selectedLogoAsset == entry.value;
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      _pickedLogoPath = null;
                                      _selectedLogoAsset = entry.value;
                                    }),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(4),
                                      width: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Colors.blue : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: Image.asset(
                                        entry.value,
                                        fit: BoxFit.contain,
                                        errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.black, size: 16),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 5. Templates
                    _buildAccordionSection(
                      icon: Icons.palette_outlined,
                      title: 'Templates',
                      child: SizedBox(
                        height: 65,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _templates.length,
                          itemBuilder: (context, index) {
                            final t = _templates[index];
                            final isSelected = _selectedTemplateIndex == index;
                            return GestureDetector(
                              onTap: () => _applyTemplate(index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: t['bg'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? Colors.blueAccent : Colors.white24,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code_2, color: t['markerBorder'] as Color, size: 22),
                                    const SizedBox(height: 2),
                                    Text(
                                      t['name'] as String,
                                      style: TextStyle(
                                        color: t['dots'] as Color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildUniversalBottomBar(),
    );
  }

  Widget _buildHexAndColorField({
    required String label,
    required Color currentColor,
    required TextEditingController controller,
    required Function(Color) onColorChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                final idx = _paletteColors.indexWhere((c) => c.toARGB32() == currentColor.toARGB32());
                final next = _paletteColors[(idx + 1) % _paletteColors.length];
                onColorChanged(next);
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 1.5),
                ),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                maxLength: 7,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                onChanged: (val) {
                  final parsed = _parseHexColor(val);
                  if (parsed != null) {
                    setState(() {
                      if (label == 'Background Colour') {
                        _bgColor = parsed;
                      } else if (label == 'Dots Colour') {
                        _dotsColor = parsed;
                      } else if (label == 'Marker border colour') {
                        _markerBorderColor = parsed;
                      } else if (label == 'Marker centre colour') {
                        _markerCentreColor = parsed;
                      }
                    });
                  }
                },
                decoration: const InputDecoration(
                  counterText: '',
                  prefixText: '#',
                  prefixStyle: TextStyle(color: Colors.white54),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _paletteColors.length,
            itemBuilder: (context, index) {
              final color = _paletteColors[index];
              final isSelected = currentColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.white24,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShapeGridTile({
    required String label,
    required bool active,
    required VoidCallback onTap,
    required Widget preview,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? Colors.blueAccent.withValues(alpha: 0.16) : Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? Colors.blueAccent : Colors.white12,
                width: active ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                preview,
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? Colors.blueAccent : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            const Positioned(
              top: -6,
              right: -6,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccordionSection({
    required IconData icon,
    required String title,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: Colors.blueAccent, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white54,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
  }

  core.List<Widget> _buildDynamicButtons() {
    core.List<Widget> buttons = [];

    buttons.add(_actionIconButton(icon: Icons.edit_note, label: 'Edit Content', onTap: _navigateToEditScreen));
    buttons.add(const SizedBox(width: 20));

    if (_isWifi) {
      buttons.add(_actionIconButton(icon: Icons.wifi, label: 'Connect', onTap: _connectToWifi));
    } else if (_isEmail) {
      buttons.add(_actionIconButton(
        icon: Icons.email_outlined,
        label: 'Send Email',
        onTap: _sendEmail,
      ));
    } else if (_isPhone) {
      buttons.add(_actionIconButton(icon: Icons.phone, label: 'Call', onTap: () => _launchURL(widget.rawValue)));
    } else if (_isContact) {
      buttons.add(_actionIconButton(icon: Icons.person_add_alt_1_rounded, label: 'Add contact', onTap: _saveContactFromQR));
    } else if (_isSMS) {
      buttons.add(_actionIconButton(icon: Icons.chat_bubble_outline, label: 'Send SMS', onTap: () => _sendSMS(isMMS: false)));
      buttons.add(const SizedBox(width: 20));
      buttons.add(_actionIconButton(icon: Icons.image_outlined, label: 'Send MMS', onTap: () => _sendSMS(isMMS: true)));
    } else if (_isGeo || widget.rawValue.toLowerCase().contains('bangladesh') || widget.rawValue.toLowerCase().contains('dhaka')) {
      buttons.add(_actionIconButton(icon: Icons.location_on_rounded, label: 'Show Map', onTap: _openInMap));
    } else if (_isUrl) {
      buttons.add(_actionIconButton(icon: Icons.open_in_browser, label: 'Open', onTap: () => _launchURL(widget.rawValue)));
    } else {
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
          IconButton(
            icon: const Icon(Icons.description_outlined, color: Colors.greenAccent),
            onPressed: _exportSingleQrToCSV,
            tooltip: 'Export CSV Data',
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

class _DotShapePreviewPainter extends CustomPainter {
  final String shapeId;
  final Color color;

  _DotShapePreviewPainter({required this.shapeId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 3, 10, 10), const Radius.circular(2)), borderPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(31, 3, 10, 10), const Radius.circular(2)), borderPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3, 31, 10, 10), const Radius.circular(2)), borderPaint);

    final coords = [
      const Offset(18, 18),
      const Offset(26, 18),
      const Offset(18, 26),
      const Offset(26, 26),
    ];

    for (final pt in coords) {
      if (shapeId == 'dots') {
        canvas.drawCircle(pt + const Offset(2.5, 2.5), 2.5, paint);
      } else if (shapeId == 'triangle') {
        final path = Path()
          ..moveTo(pt.dx + 2.5, pt.dy)
          ..lineTo(pt.dx + 5.5, pt.dy + 5.5)
          ..lineTo(pt.dx - 0.5, pt.dy + 5.5)
          ..close();
        canvas.drawPath(path, paint);
      } else if (shapeId == 'diamond') {
        final path = Path()
          ..moveTo(pt.dx + 2.5, pt.dy)
          ..lineTo(pt.dx + 5.5, pt.dy + 2.8)
          ..lineTo(pt.dx + 2.5, pt.dy + 5.6)
          ..lineTo(pt.dx - 0.5, pt.dy + 2.8)
          ..close();
        canvas.drawPath(path, paint);
      } else if (shapeId == 'lines') {
        canvas.drawLine(pt + const Offset(0, 5), pt + const Offset(5, 0), borderPaint);
      } else if (shapeId == 'bars') {
        canvas.drawRect(Rect.fromLTWH(pt.dx + 1.5, pt.dy, 2.2, 5.5), paint);
      } else if (shapeId == 'rounded') {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pt.dx, pt.dy, 5, 5), const Radius.circular(2.2)), paint);
      } else if (shapeId == 'star') {
        canvas.drawCircle(pt + const Offset(2.5, 2.5), 2.2, paint);
      } else {
        canvas.drawRect(Rect.fromLTWH(pt.dx, pt.dy, 5, 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotShapePreviewPainter oldDelegate) =>
      oldDelegate.shapeId != shapeId || oldDelegate.color != color;
}

class _MarkerBorderPreviewPainter extends CustomPainter {
  final String shapeId;
  final Color color;

  _MarkerBorderPreviewPainter({required this.shapeId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    final rect = Rect.fromLTWH(7, 7, size.width - 14, size.height - 14);

    if (shapeId == 'circle') {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), (size.width - 14) / 2, paint);
    } else if (shapeId == 'rounded') {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);
    } else if (shapeId == 'teardrop') {
      final path = Path()
        ..moveTo(rect.left, rect.top + rect.height * 0.55)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + rect.width * 0.55, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom - rect.height * 0.35)
        ..quadraticBezierTo(rect.right, rect.bottom, rect.left + rect.width * 0.45, rect.bottom)
        ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.top + rect.height * 0.55)
        ..close();
      canvas.drawPath(path, paint);
    } else if (shapeId == 'dotted') {
      const dash = 4.0;
      const gap = 3.5;
      for (double x = rect.left; x < rect.right; x += dash + gap) {
        canvas.drawLine(Offset(x, rect.top), Offset(math.min(x + dash, rect.right), rect.top), paint);
        canvas.drawLine(Offset(x, rect.bottom), Offset(math.min(x + dash, rect.right), rect.bottom), paint);
      }
      for (double y = rect.top; y < rect.bottom; y += dash + gap) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.left, math.min(y + dash, rect.bottom)), paint);
        canvas.drawLine(Offset(rect.right, y), Offset(rect.right, math.min(y + dash, rect.bottom)), paint);
      }
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerBorderPreviewPainter oldDelegate) =>
      oldDelegate.shapeId != shapeId || oldDelegate.color != color;
}

class _MarkerCentrePreviewPainter extends CustomPainter {
  final String shapeId;
  final Color color;

  _MarkerCentrePreviewPainter({required this.shapeId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 13.0;

    if (shapeId == 'rounded') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2), const Radius.circular(6)), paint);
    } else if (shapeId == 'teardrop') {
      final path = Path()
        ..moveTo(cx - r, cy + r * 0.2)
        ..quadraticBezierTo(cx - r, cy - r, cx + r * 0.2, cy - r)
        ..lineTo(cx + r, cy - r)
        ..lineTo(cx + r, cy + r * 0.2)
        ..quadraticBezierTo(cx + r, cy + r, cx, cy + r)
        ..quadraticBezierTo(cx - r, cy + r, cx - r, cy + r * 0.2)
        ..close();
      canvas.drawPath(path, paint);
    } else if (shapeId == 'star') {
      final path = Path();
      for (int i = 0; i < 10; i++) {
        final rad = i.isEven ? r + 1 : r * 0.48;
        final angle = (i * math.pi / 5) - (math.pi / 2);
        final x = cx + rad * math.cos(angle);
        final y = cy + rad * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    } else if (shapeId == 'octagon') {
      final path = Path();
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4) + (math.pi / 8);
        final x = cx + (r + 1) * math.cos(angle);
        final y = cy + (r + 1) * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    } else if (shapeId == 'plus') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 7, height: r * 2), const Radius.circular(2)), paint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: 7), const Radius.circular(2)), paint);
    } else if (shapeId == 'grid') {
      for (final dx in [-8.0, 0.0, 8.0]) {
        for (final dy in [-8.0, 0.0, 8.0]) {
          canvas.drawCircle(Offset(cx + dx, cy + dy), 3.0, paint);
        }
      }
    } else if (shapeId == 'diamond') {
      final path = Path()
        ..moveTo(cx, cy - r - 1)
        ..lineTo(cx + r + 1, cy)
        ..lineTo(cx, cy + r + 1)
        ..lineTo(cx - r - 1, cy)
        ..close();
      canvas.drawPath(path, paint);
    } else {
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerCentrePreviewPainter oldDelegate) =>
      oldDelegate.shapeId != shapeId || oldDelegate.color != color;
}

class _QrPatternOverlayPainter extends CustomPainter {
  final String dotShape;
  final String markerBorderShape;
  final String markerCentreShape;
  final Color dotsColor;
  final Color markerBorderColor;
  final Color markerCentreColor;
  final double dotScale;

  _QrPatternOverlayPainter({
    required this.dotShape,
    required this.markerBorderShape,
    required this.markerCentreShape,
    required this.dotsColor,
    required this.markerBorderColor,
    required this.markerCentreColor,
    required this.dotScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final accentPaint = Paint()
      ..color = dotsColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * dotScale;

    final step = 14.0;
    if (dotShape == 'lines') {
      for (double x = 24; x < size.width - 24; x += step) {
        for (double y = 24; y < size.height - 24; y += step) {
          canvas.drawLine(Offset(x, y + 6), Offset(x + 6, y), accentPaint);
        }
      }
    } else if (dotShape == 'bars') {
      for (double x = 24; x < size.width - 24; x += step) {
        for (double y = 24; y < size.height - 24; y += step) {
          canvas.drawRect(Rect.fromLTWH(x + 2, y, 2.5, 7), accentPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPatternOverlayPainter oldDelegate) => true;
}