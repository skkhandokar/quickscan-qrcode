// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import '../services/history_service.dart'; 
// import 'scan_result_screen.dart'; 

// class CreateImageQRScreen extends StatefulWidget {
//   const CreateImageQRScreen({super.key});

//   @override
//   State<CreateImageQRScreen> createState() => _CreateImageQRScreenState();
// }

// class _CreateImageQRScreenState extends State<CreateImageQRScreen> {
//   File? _imageFile;
//   bool _isUploading = false;
//   final ImagePicker _picker = ImagePicker();

//   final String _imgBBApiKey = "bc7a0c667b6f65a444311579f68b0afd"; 

//   Future<void> _selectImage() async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery, 
//       imageQuality: 70, 
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _uploadAndGenerateQR() async {
//     if (_imageFile == null) return;

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBBApiKey'),
//       );
//       request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

//       final response = await request.send();
//       if (response.statusCode == 200) {
//         final responseData = await response.stream.bytesToString();
//         final jsonResponse = jsonDecode(responseData);
//         final String imageUrl = jsonResponse['data']['url'];

//         if (!mounted) return;

//         final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

//         // শুধুমাত্র সাধারণ হিস্ট্রিতে একবারই ডেটা পাঠানো হচ্ছে
//         await HistoryService.addToStorage(
//           isMyQR: false,
//           type: 'image_qr',
//           title: imageUrl,
//           customId: commonId,
//         );

//         if (!mounted) return;

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ScanResultScreen(
//               rawValue: imageUrl, 
//               isBarcodeResult: false, 
//               itemId: commonId, 
//             ),
//           ),
//         );
//       } else {
//         throw Exception('Failed to upload image. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e. Try again.')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Create Image QR', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_imageFile != null) ...[
//                 Container(
//                   height: 250,
//                   width: 250,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(color: Colors.blueAccent, width: 2),
//                     image: DecorationImage(
//                       image: FileImage(_imageFile!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//               ] else ...[
//                 const Icon(
//                   Icons.add_photo_alternate_outlined, 
//                   size: 100, 
//                   color: Colors.white30,
//                 ),
//                 const SizedBox(height: 15),
//                 const Text(
//                   'Select an image to convert into QR', 
//                   style: TextStyle(color: Colors.white54, fontSize: 16),
//                 ),
//                 const SizedBox(height: 30),
//               ],
              
//               if (_isUploading) ...[
//                 const CircularProgressIndicator(color: Colors.blue),
//                 const SizedBox(height: 15),
//                 const Text(
//                   'Uploading image and generating QR...', 
//                   style: TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ] else ...[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _selectImage,
//                       icon: const Icon(Icons.photo_library, color: Colors.white),
//                       label: const Text('Choose Image', style: TextStyle(color: Colors.white)),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[800],
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                     if (_imageFile != null)
//                       ElevatedButton.icon(
//                         onPressed: _uploadAndGenerateQR,
//                         icon: const Icon(Icons.qr_code, color: Colors.white),
//                         label: const Text('Generate QR', style: TextStyle(color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                   ],
//                 )
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












// lib/screens/create_image_qr_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/history_service.dart'; 
import 'scan_result_screen.dart'; 

class CreateImageQRScreen extends StatefulWidget {
  const CreateImageQRScreen({super.key});

  @override
  State<CreateImageQRScreen> createState() => _CreateImageQRScreenState();
}

class _CreateImageQRScreenState extends State<CreateImageQRScreen> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // --- নতুন ফিচার: কোড টাইপ সিলেক্ট করার ভেরিয়েবল (QR Code বা Barcode) ---
  String _selectedOutputType = 'QR Code'; // ডিফল্ট সিলেকশন

  final String _imgBBApiKey = "bc7a0c667b6f65a444311579f68b0afd"; 

  Future<void> _selectImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70, 
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAndGenerateQR() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBBApiKey'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        final String imageUrl = jsonResponse['data']['url'];

        if (!mounted) return;

        final String commonId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // ইউজার বারকোড সিলেক্ট করলে টাইপ হবে 'barcode', অন্যথায় 'image_qr'
        final bool generateAsBarcode = _selectedOutputType == 'Barcode';
        final String historyType = generateAsBarcode ? 'barcode' : 'image_qr';

        // ডাটাবেজ/হিস্ট্রিতে ডেটা সেভ করা হচ্ছে
        await HistoryService.addToStorage(
          isMyQR: false,
          type: historyType,
          title: imageUrl,
          isBarcode: generateAsBarcode,
          barcodeTypeTag: generateAsBarcode ? 'code128' : '', // ইমেজের লিংকের জন্য Code 128 বেস্ট ফরম্যাট
          customId: commonId,
        );

        if (!mounted) return;

        // রেজাল্ট স্ক্রিনে সঠিক টাইপ ফ্ল্যাগ সহ ডেটা পাঠানো
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              rawValue: imageUrl, 
              isBarcodeResult: generateAsBarcode, 
              barcodeTypeTag: generateAsBarcode ? 'code128' : '',
              itemId: commonId, 
            ),
          ),
        );
      } else {
        throw Exception('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Create Image QR / Barcode', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile != null) ...[
                Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    image: DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                const Icon(
                  Icons.add_photo_alternate_outlined, 
                  size: 100, 
                  color: Colors.white30,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Select an image to convert into Code', 
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 25),
              ],

              // --- নতুন UI উপাদান: জেনারেশন টাইপ সিলেক্টর বাটন ---
              if (_imageFile != null && !_isUploading) ...[
                const Text(
                  'Select Output Format:',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFormatOption('QR Code', Icons.qr_code),
                    const SizedBox(width: 15),
                    _buildFormatOption('Barcode', Icons.reorder),
                  ],
                ),
                const SizedBox(height: 25),
              ],
              
              if (_isUploading) ...[
                const CircularProgressIndicator(color: Colors.blue),
                const SizedBox(height: 15),
                Text(
                  'Uploading image and generating $_selectedOutputType...', 
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _selectImage,
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: const Text('Choose Image', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (_imageFile != null)
                      ElevatedButton.icon(
                        onPressed: _uploadAndGenerateQR,
                        icon: Icon(
                          _selectedOutputType == 'Barcode' ? Icons.reorder : Icons.qr_code, 
                          color: Colors.white,
                        ),
                        label: Text('Generate $_selectedOutputType', style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  // কাস্টম ফরম্যাট বাটন ডিজাইনার উইজেট
  Widget _buildFormatOption(String type, IconData icon) {
    final bool isSelected = _selectedOutputType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOutputType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.white54, size: 20),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}