// lib/screens/scan_result_screen.dart
import 'dart:core' as core;
import 'dart:core';
import 'dart:io';
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
  String? _selectedLogoAsset;

  // কাস্টমাইজেশন স্টেট ভেরিয়েবলসমূহ
  late Color _dotsColor;
  late Color _eyeColor;
  late Color _bgColor;
  QrDataModuleShape _dotShape = QrDataModuleShape.square;
  QrEyeShape _eyeShape = QrEyeShape.square;
  double _dotScale = 1.0;
  String _selectedFrame = 'None';
  int _selectedTemplateIndex = 0;

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
      'dots': Colors.black,
      'eye': Colors.black,
      'bg': Colors.white,
      'dotShape': QrDataModuleShape.square,
      'eyeShape': QrEyeShape.square,
      'frame': 'None',
    },
    {
      'name': 'Modern Dots',
      'dots': const Color(0xFF1E3A8A),
      'eye': const Color(0xFF2563EB),
      'bg': Colors.white,
      'dotShape': QrDataModuleShape.circle,
      'eyeShape': QrEyeShape.circle,
      'frame': 'Simple Border',
    },
    {
      'name': 'Scan Badge',
      'dots': Colors.black,
      'eye': const Color(0xFFDC2626),
      'bg': Colors.white,
      'dotShape': QrDataModuleShape.square,
      'eyeShape': QrEyeShape.circle,
      'frame': 'Scan Me Bottom',
    },
    {
      'name': 'Emerald Pro',
      'dots': const Color(0xFF065F46),
      'eye': const Color(0xFF059669),
      'bg': const Color(0xFFECFDF5),
      'dotShape': QrDataModuleShape.circle,
      'eyeShape': QrEyeShape.square,
      'frame': 'Badge Top',
    },
    {
      'name': 'Royal Gold',
      'dots': const Color(0xFF78350F),
      'eye': const Color(0xFFD97706),
      'bg': const Color(0xFFFEF3C7),
      'dotShape': QrDataModuleShape.circle,
      'eyeShape': QrEyeShape.circle,
      'frame': 'Scan Me Bottom',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dotsColor = widget.qrColor;
    _eyeColor = widget.qrColor;
    _bgColor = widget.qrBgColor;
    _checkFavoriteStatus();
  }

  void _applyTemplate(int index) {
    final t = _templates[index];
    setState(() {
      _selectedTemplateIndex = index;
      _dotsColor = t['dots'] as Color;
      _eyeColor = t['eye'] as Color;
      _bgColor = t['bg'] as Color;
      _dotShape = t['dotShape'] as QrDataModuleShape;
      _eyeShape = t['eyeShape'] as QrEyeShape;
      _selectedFrame = t['frame'] as String;
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
    final core.List<String> parts = data.substring(5).split(';');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid WiFi QR Code: Missing SSID")),
        );
      }
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueAccent,
            content: Text("Connecting to Wi-Fi... Please wait."),
            duration: Duration(seconds: 2),
          ),
        );
      }

      bool isEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!isEnabled) {
        await WiFiForIoTPlugin.setEnabled(true);
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Connected successfully! 🎉"),
            ),
          );
        } else {
          await WiFiForIoTPlugin.forceWifiUsage(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text("Please check Wi-Fi settings to confirm connection."),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("WiFi Connection error: $e"),
          ),
        );
      }
    }
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

  ImageProvider? _getEmbeddedImage() {
    if (widget.customLogoPath != null && widget.customLogoPath!.isNotEmpty) {
      return FileImage(File(widget.customLogoPath!));
    }
    if (_selectedLogoAsset != null) {
      return AssetImage(_selectedLogoAsset!);
    }
    return null;
  }

  Widget _buildFramedQrContainer(Widget qrChild) {
    if (_selectedFrame == 'Simple Border') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _eyeColor, width: 4),
        ),
        child: qrChild,
      );
    } else if (_selectedFrame == 'Scan Me Bottom') {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _eyeColor, width: 3.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrChild,
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
              decoration: BoxDecoration(
                color: _eyeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'SCAN ME',
                style: TextStyle(
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
          border: Border.all(color: _eyeColor, width: 3.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: _eyeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SCAN HERE',
                style: TextStyle(
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

            // QR কোড এবং ফ্রেম (RepaintBoundary এর ভেতরে যাতে একসাথে সেভ হয়)
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
                        QrImageView(
                          data: widget.rawValue,
                          version: QrVersions.auto,
                          size: 175.0,
                          gapless: _dotScale >= 0.9,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          eyeStyle: QrEyeStyle(
                            eyeShape: _eyeShape,
                            color: _eyeColor,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: _dotShape,
                            color: _dotsColor,
                          ),
                          embeddedImage: _getEmbeddedImage(),
                          embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(38, 38)),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // কাস্টমাইজেশন অ্যাকর্ডিয়ন মেনুসমূহ (যদি বারকোড না হয়)
            if (!widget.isBarcodeResult)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // ১. Templates
                    _buildAccordionSection(
                      icon: Icons.palette_outlined,
                      title: 'Templates',
                      initiallyExpanded: true,
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
                                    Icon(Icons.qr_code_2, color: t['eye'] as Color, size: 22),
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

                    const SizedBox(height: 10),

                    // ২. Appearance & Dots Size
                    _buildAccordionSection(
                      icon: Icons.color_lens_outlined,
                      title: 'Appearance & Dots Size',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildColorSelectorRow('Background Colour', _bgColor, (c) => setState(() => _bgColor = c)),
                          const SizedBox(height: 12),
                          _buildColorSelectorRow('Dots Colour', _dotsColor, (c) => setState(() => _dotsColor = c)),
                          const SizedBox(height: 12),
                          _buildColorSelectorRow('Marker Colour (Corners)', _eyeColor, (c) => setState(() => _eyeColor = c)),
                          const Divider(color: Colors.white12, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Dots Density / Scale', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              Text('Dot Scale: ${_dotScale.toStringAsFixed(1)}', style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Slider(
                            value: _dotScale,
                            min: 0.5,
                            max: 1.0,
                            divisions: 5,
                            activeColor: Colors.blueAccent,
                            onChanged: (val) => setState(() => _dotScale = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ৩. Shape & Form
                    _buildAccordionSection(
                      icon: Icons.grid_view_rounded,
                      title: 'Shape & Form',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dots Style', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildShapeChip('Square Dots', Icons.crop_square, _dotShape == QrDataModuleShape.square, () => setState(() => _dotShape = QrDataModuleShape.square)),
                              const SizedBox(width: 12),
                              _buildShapeChip('Circle Dots', Icons.circle, _dotShape == QrDataModuleShape.circle, () => setState(() => _dotShape = QrDataModuleShape.circle)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Marker Border & Centre', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildShapeChip('Square Marker', Icons.check_box_outline_blank, _eyeShape == QrEyeShape.square, () => setState(() => _eyeShape = QrEyeShape.square)),
                              const SizedBox(width: 12),
                              _buildShapeChip('Circle Marker', Icons.radio_button_unchecked, _eyeShape == QrEyeShape.circle, () => setState(() => _eyeShape = QrEyeShape.circle)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ৪. Frames
                    _buildAccordionSection(
                      icon: Icons.crop_free_rounded,
                      title: 'Frames',
                      child: Wrap(
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
                    ),

                    const SizedBox(height: 10),

                    // ৫. Center Logo
                    _buildAccordionSection(
                      icon: Icons.image_outlined,
                      title: 'Center Logo',
                      child: SizedBox(
                        height: 46,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _selectedLogoAsset = null),
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

  Widget _buildColorSelectorRow(String label, Color currentColor, Function(Color) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _paletteColors.length,
            itemBuilder: (context, index) {
              final color = _paletteColors[index];
              final isSelected = currentColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.white30,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: color == Colors.white || color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShapeChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.blueAccent : Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
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