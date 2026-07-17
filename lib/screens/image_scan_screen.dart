

// lib/screens/image_scan_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../widgets/custom_drawer.dart'; 
import '../services/history_service.dart'; 
import 'scan_result_screen.dart';

class ImageScanScreen extends StatefulWidget {
  final Function(Color) onChangeColor;
  final bool autoOpenGallery; // ড্রয়ার থেকে সরাসরি ওপেনের জন্য ফ্ল্যাগ

  const ImageScanScreen({
    super.key, 
    required this.onChangeColor,
    this.autoOpenGallery = false,
  });

  @override
  State<ImageScanScreen> createState() => _ImageScanScreenState();
}

class _ImageScanScreenState extends State<ImageScanScreen> {
  File? _selectedImage;
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // স্ক্রিন বিল্ড হওয়ার পর যদি ফ্ল্যাগ ট্রু থাকে তবে গ্যালারি ওপেন হবে
    if (widget.autoOpenGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickAndScanImage();
      });
    }
  }

  Future<void> _pickAndScanImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _isScanning = true;
    });

    final InputImage inputImage = InputImage.fromFilePath(image.path);
    
    // বারকোড এবং কিউআর কোড উভয় ফরম্যাটই যাতে গ্যালারি থেকে স্ক্যান করা যায়
    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

    try {
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final Barcode barcode = barcodes.first;
        final String? qrValue = barcode.rawValue;
        
        if (qrValue != null && qrValue.isNotEmpty) {
          
          // হিস্ট্রি স্ক্রিনের সাথে সামঞ্জস্য রেখে টাইপ সেট করা
          String type = 'image_scan';
          bool isBarcode = barcode.format != BarcodeFormat.qrCode;

          if (!isBarcode) {
            if (qrValue.startsWith('WIFI:')) {
              type = 'wifi';
            } else if (qrValue.startsWith('tel:')) {
              type = 'phone';
            } else if (qrValue.startsWith('http')) {
              type = 'image_qr'; // আপনার HistoryScreen-এর ম্যাপিং অনুযায়ী 'IMAGE TO QR' লেবেল পাবে
            } else {
              type = 'text';
            }
          } else {
            type = 'barcode'; // বারকোড হলে সরাসরি বারকোড টাইপ
          }

          final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

          // গ্যালারি ইমেজ স্ক্যান হিস্ট্রিতে ইউনিক আইডি সহ সেভ করা হলো
          await HistoryService.addToStorage(
            isMyQR: false,
            type: type,
            title: qrValue,
            isBarcode: isBarcode,
            barcodeTypeTag: isBarcode ? 'code128' : '', // বারকোড ফরম্যাট ট্যাগ
            customId: commonId,
          );

          if (!mounted) return;
          
          // ১ নম্বর ফিচারের কাস্টম কালার সাপোর্ট সহ রেজাল্ট স্ক্রিনে পাঠানো হলো
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanResultScreen(
                rawValue: qrValue,
                isBarcodeResult: isBarcode,
                barcodeTypeTag: isBarcode ? 'code128' : '',
                itemId: commonId,
                qrColor: Colors.black, // ডিফল্ট কাস্টম কালার সাপোর্ট
                qrBgColor: Colors.white,
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;
        _showNoQRDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning image: $e')),
        );
      }
    } finally {
      barcodeScanner.close();
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _showNoQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.amber),
            SizedBox(width: 10),
            Text('No Code Found', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'The selected image does not contain any valid QR Code or Barcode. Please try another image.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Image Scan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(onChangeColor: widget.onChangeColor), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null) ...[
                Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                const Icon(Icons.image_outlined, size: 100, color: Colors.white30),
                const SizedBox(height: 20),
                const Text(
                  'Upload an image to detect QR / Barcode',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 30),
              ],
              if (_isScanning)
                const CircularProgressIndicator(color: Colors.blue)
              else
                ElevatedButton.icon(
                  onPressed: _pickAndScanImage,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text('Select Image from Gallery', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}