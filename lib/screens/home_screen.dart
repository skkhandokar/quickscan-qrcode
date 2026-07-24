

// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;
import 'package:url_launcher/url_launcher.dart'; // অটো ব্রাউজার ওপেনের জন্য
import '../widgets/custom_drawer.dart';
import '../services/history_service.dart'; 
import 'scan_result_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Color) onChangeColor;
  const HomeScreen({super.key, required this.onChangeColor});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  
  double _zoomFactor = 0.0;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  // --- ৪ নম্বর ফিচার: বাল্ক মোড ভেরিয়েবলসমূহ ---
  bool _isBulkMode = false;
  final List<String> _bulkScannedList = [];

  // --- ৫ নম্বর ফিচার: স্মার্ট অটো-অ্যাকশন সেটিংস ট্র্যাকিং ---
  bool _autoCopy = false;
  bool _autoOpen = false;

  @override
  void initState() {
    super.initState();
    _loadAutoSettings(); // স্ক্রিন ওপেন হওয়ার সময় সেটিংস লোড হবে
  }

  Future<void> _loadAutoSettings() async {
    final settings = await HistoryService.getAutoSettings();
    setState(() {
      _autoCopy = settings['autoCopy'] ?? false;
      _autoOpen = settings['autoOpen'] ?? false;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // গ্যালারি থেকে ছবি নিয়ে স্ক্যান করার মেথড (বারকোড ডিটেকশন ও কাস্টম আইডি ফিক্স সহ)
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final mlkit.InputImage inputImage = mlkit.InputImage.fromFilePath(image.path);
      final mlkit.BarcodeScanner barcodeScanner = mlkit.BarcodeScanner(formats: [mlkit.BarcodeFormat.all]);
      
      try {
        final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
        
        if (barcodes.isNotEmpty) {
          final mlkit.Barcode barcode = barcodes.first;
          final String rawValue = barcode.rawValue ?? "";
          
          if (rawValue.isNotEmpty) {
            bool isBarcode = barcode.format != mlkit.BarcodeFormat.qrCode;
            String type = isBarcode ? 'barcode' : 'url';
            
            if (!isBarcode) {
              if (rawValue.startsWith('WIFI:')) {
                type = 'wifi';
              } else if (rawValue.startsWith('tel:')) {
                type = 'phone';
              } else if (!rawValue.startsWith('http')) {
                type = 'text';
              }
            }

            final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

            await HistoryService.addToStorage(
              isMyQR: false,
              type: type,
              title: isBarcode ? "Barcode: $rawValue" : rawValue,
              isBarcode: isBarcode,
              barcodeTypeTag: isBarcode ? 'code128' : '',
              customId: commonId,
            );

            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ScanResultScreen(
                rawValue: rawValue,
                isBarcodeResult: isBarcode,
                barcodeTypeTag: isBarcode ? 'code128' : '',
                itemId: commonId,
              ),
            ));
          }
        } else {
          _showErrorSnackBar("No QR Code or Barcode found in this image!");
        }
      } catch (e) {
        _showErrorSnackBar("Failed to scan image: $e");
      } finally {
        barcodeScanner.close();
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  // --- লাইভ ক্যামেরা দিয়ে কোড ডিটেক্ট করার কোর মেথড ---
  void _onLiveCodeDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String rawValue = barcodes.first.rawValue ?? "";
    if (rawValue.isEmpty) return;

    bool isBarcode = barcodes.first.format != BarcodeFormat.qrCode;

    // --- কেস ১: যদি বাল্ক মোড একটিভ থাকে ---
    if (_isBulkMode) {
      if (!_bulkScannedList.contains(rawValue)) {
        HapticFeedback.vibrate(); // স্ক্যান সফল বুঝাতে মৃদু কম্পন
        setState(() {
          _bulkScannedList.add(rawValue);
        });

        String type = isBarcode ? 'barcode' : 'text';
        await HistoryService.addToStorage(
          isMyQR: false,
          type: type,
          title: rawValue,
          isBarcode: isBarcode,
          barcodeTypeTag: isBarcode ? 'code128' : '',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bulk Scanned: $rawValue (${_bulkScannedList.length} Items)'),
            duration: const Duration(milliseconds: 800),
            backgroundColor: Colors.green,
          ),
        );
      }
    } 
    // --- কেস ২: সাধারণ স্ক্যান মোড (স্মার্ট অটো অ্যাকশন সহ) ---
    else {
      cameraController.stop(); // পরবর্তী ক্যামেরা ফ্রেম হোল্ড করা হলো

      // ৫ নম্বর ফিচার: অটোমেটিক ক্লিপবোর্ডে কপি করা
      if (_autoCopy) {
        await Clipboard.setData(ClipboardData(text: rawValue));
      }

      // ৫ নম্বর ফিচার: অটোমেটিক ব্রাউজারে লিংক ওপেন করা
      if (_autoOpen && (rawValue.startsWith('http://') || rawValue.startsWith('https://'))) {
        final Uri url = Uri.parse(rawValue);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          cameraController.start(); // ব্রাউজার থেকে অ্যাপে ব্যাক আসলে ক্যামেরা অন করার প্রস্তুতি
          return;
        }
      }

      String type = isBarcode ? 'barcode' : 'url';
      if (!isBarcode) {
        if (rawValue.startsWith('WIFI:')) {
          type = 'wifi';
        } else if (rawValue.startsWith('tel:')) {
          type = 'phone';
        } else if (!rawValue.startsWith('http')) {
          type = 'text';
        }
      }

      final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

      await HistoryService.addToStorage(
        isMyQR: false,
        type: type,
        title: rawValue,
        isBarcode: isBarcode,
        barcodeTypeTag: isBarcode ? 'code128' : '',
        customId: commonId,
      );

      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          rawValue: rawValue,
          isBarcodeResult: isBarcode,
          barcodeTypeTag: isBarcode ? 'code128' : '',
          itemId: commonId,
        ),
      ));
      cameraController.start(); // রেজাল্ট স্ক্রিন থেকে ব্যাক আসলে ক্যামেরা আবার লাইভ হবে
    }
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // ৪ নম্বর ফিচার: বাল্ক মোড অন/অফ করার বাটন
          IconButton(
            icon: Icon(
              _isBulkMode ? Icons.layers : Icons.layers_clear, 
              color: _isBulkMode ? Colors.greenAccent : Colors.white
            ),
            tooltip: 'Bulk Scan Mode',
            onPressed: () {
              setState(() {
                _isBulkMode = !_isBulkMode;
                if (!_isBulkMode) _bulkScannedList.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isBulkMode ? 'Bulk Scan Mode Activated 📦' : 'Standard Scan Mode Activated')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.image, color: Colors.white), onPressed: _pickImageFromGallery),
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: _isFlashOn ? Colors.amber : Colors.white),
            onPressed: () {
              cameraController.toggleTorch();
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
          IconButton(
            icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear, color: Colors.white),
            onPressed: () {
              cameraController.switchCamera();
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
            },
          ),
        ],
      ),
      drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onLiveCodeDetected, // আমাদের আপডেটেড ডিটেকশন মেথড যুক্ত হলো
          ),
          
          // স্ক্যানার বক্স ওভারলে গাইডলাইন
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: _isBulkMode ? Colors.greenAccent : activeColor, width: 4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Stack(
                children: [
                  Center(child: Divider(color: Colors.red, thickness: 2)),
                ],
              ),
            ),
          ),
          
          // ৫ নম্বর ফিচার: অটো অ্যাকশন সেটিংস ফ্লোটিং সুইচ প্যানেল (ক্যামেরার একদম নিচে)
          Positioned(
            bottom: 110, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85), 
                borderRadius: BorderRadius.circular(15), 
                border: Border.all(color: Colors.white12)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Auto Copy to Clipboard', style: TextStyle(color: Colors.white, fontSize: 13)),
                    value: _autoCopy,
                    dense: true,
                    activeThumbColor: Colors.blueAccent,
                    onChanged: (val) {
                      setState(() => _autoCopy = val);
                      HistoryService.setAutoSettings(_autoCopy, _autoOpen);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Auto Open Web Links', style: TextStyle(color: Colors.white, fontSize: 13)),
                    value: _autoOpen,
                    dense: true,
                    activeThumbColor: Colors.blueAccent,
                    onChanged: (val) {
                      setState(() => _autoOpen = val);
                      HistoryService.setAutoSettings(_autoCopy, _autoOpen);
                    },
                  ),
                ],
              ),
            ),
          ),

          // জুম স্লাইডার কন্ট্রোল
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Row(
              children: [
                const Icon(Icons.zoom_out, color: Colors.white70),
                Expanded(
                  child: Slider(
                    activeColor: _isBulkMode ? Colors.greenAccent : activeColor,
                    value: _zoomFactor,
                    onChanged: (v) {
                      setState(() {
                        _zoomFactor = v;
                        cameraController.setZoomScale(v);
                      });
                    },
                  ),
                ),
                const Icon(Icons.zoom_in, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}