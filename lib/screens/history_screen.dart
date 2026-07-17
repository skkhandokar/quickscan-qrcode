



// // lib/screens/history_screen.dart
// import 'package:flutter/material.dart';
// import '../widgets/custom_drawer.dart';
// import '../services/history_service.dart';
// import 'scan_result_screen.dart';

// class HistoryScreen extends StatefulWidget {
//   final Function(Color) onChangeColor;
//   const HistoryScreen({super.key, required this.onChangeColor});

//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   List<Map<String, String>> _allHistory = [];
//   List<Map<String, String>> _displayedHistory = [];
//   bool _isLoading = true;
//   bool _showOnlyFavorites = false;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//     _searchController.addListener(_filterHistory);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadHistory() async {
//     setState(() => _isLoading = true);
//     final data = await HistoryService.getList(false); 
//     setState(() {
//       _allHistory = data;
//       _isLoading = false;
//       _filterHistory();
//     });
//   }

//   void _filterHistory() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _displayedHistory = _allHistory.where((item) {
//         final title = item['title']!.toLowerCase();
//         final type = item['type']!.toLowerCase();
//         final matchesSearch = title.contains(query) || type.contains(query);
//         final matchesFavorite = !_showOnlyFavorites || item['isFavorite'] == 'true';
//         return matchesSearch && matchesFavorite;
//       }).toList();
//     });
//   }

//   // ডাটার ভেতরে স্ট্রাকচার বা প্রিফিক্স চেক করে সুনির্দিষ্ট ও সঠিক টাইপ রিটার্ন করার মেথড
//   String _getTypeLabel(String title, String type) {
//     final String cleanTitle = title.trim();
//     final String cleanType = type.toLowerCase();

//     if (cleanTitle.startsWith('WIFI:')) {
//       return 'WIFI';
//     } else if (cleanTitle.startsWith('MATMSG:') || cleanTitle.startsWith('mailto:')) {
//       return 'EMAIL';
//     } else if (cleanTitle.startsWith('smsto:') || cleanTitle.startsWith('sms:')) {
//       return 'SMS';
//     } else if (cleanTitle.startsWith('MCARD:') || cleanTitle.startsWith('BEGIN:VCARD')) {
//       return 'CONTACT';
//     } else if (cleanTitle.startsWith('tel:')) {
//       return 'PHONE';
//     } else if (cleanTitle.startsWith('geo:')) {
//       return 'GEO';
//     } else if (cleanTitle.startsWith('BEGIN:VEVENT')) {
//       return 'CALENDAR';
//     } else if (cleanTitle.startsWith('http://') || cleanTitle.startsWith('https://')) {
//       if (cleanType == 'image_qr') return 'IMAGE TO QR';
//       return 'URL';
//     } else {
//       if (cleanType == 'barcode') return 'BARCODE';
//       if (cleanType == 'image_scan') return 'IMAGE SCAN';
//       return 'TEXT';
//     }
//   }

//   // সঠিক ক্যাটাগরি অনুযায়ী প্রফেশনাল আইকন রিটার্ন করার মেথড
//   IconData _getIconForType(String title, String type) {
//     final String cleanTitle = title.trim();
//     final String cleanType = type.toLowerCase();

//     if (cleanTitle.startsWith('WIFI:')) {
//       return Icons.wifi;
//     } else if (cleanTitle.startsWith('MATMSG:') || cleanTitle.startsWith('mailto:')) {
//       return Icons.email;
//     } else if (cleanTitle.startsWith('smsto:') || cleanTitle.startsWith('sms:')) {
//       return Icons.sms;
//     } else if (cleanTitle.startsWith('MCARD:') || cleanTitle.startsWith('BEGIN:VCARD')) {
//       return Icons.contact_mail;
//     } else if (cleanTitle.startsWith('tel:')) {
//       return Icons.phone;
//     } else if (cleanTitle.startsWith('geo:')) {
//       return Icons.location_on;
//     } else if (cleanTitle.startsWith('BEGIN:VEVENT')) {
//       return Icons.calendar_today;
//     } else if (cleanTitle.startsWith('http://') || cleanTitle.startsWith('https://')) {
//       if (cleanType == 'image_qr') return Icons.image;
//       return Icons.link;
//     } else {
//       if (cleanType == 'barcode') return Icons.reorder;
//       if (cleanType == 'image_scan') return Icons.image_search;
//       return Icons.text_fields;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('History', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: Icon(_showOnlyFavorites ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
//             onPressed: () {
//               setState(() {
//                 _showOnlyFavorites = !_showOnlyFavorites;
//                 _filterHistory();
//               });
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 28),
//             onPressed: () async {
//               bool? confirm = await showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   backgroundColor: const Color(0xFF1E1E1E),
//                   title: const Text('Clear History?', style: TextStyle(color: Colors.white)),
//                   content: const Text('Are you sure you want to delete all history?', style: TextStyle(color: Colors.white70)),
//                   actions: [
//                     TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text('Clear All', style: TextStyle(color: Colors.red)),
//                     ),
//                   ],
//                 ),
//               );
//               if (confirm == true) {
//                 await HistoryService.clearStorage(false);
//                 _loadHistory();
//               }
//             },
//           ),
//         ],
//       ),
//       drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
//             child: TextField(
//               controller: _searchController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Search history...',
//                 hintStyle: const TextStyle(color: Colors.white30),
//                 prefixIcon: const Icon(Icons.search, color: Colors.white54),
//                 filled: true,
//                 fillColor: const Color(0xFF1E1E1E),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Colors.blue))
//                 : _displayedHistory.isEmpty
//                     ? const Center(child: Text('No history found!', style: TextStyle(color: Colors.white54, fontSize: 16)))
//                     : ListView.builder(
//                         itemCount: _displayedHistory.length,
//                         itemBuilder: (context, index) {
//                           final item = _displayedHistory[index];
//                           final bool isFav = item['isFavorite'] == 'true';
//                           final String displayTitle = item['title']!;
//                           final String itemType = item['type'] ?? '';

//                           return Dismissible(
//                             key: Key(item['id']!),
//                             direction: DismissDirection.endToStart,
//                             background: Container(
//                               alignment: Alignment.centerRight,
//                               padding: const EdgeInsets.only(right: 20.0),
//                               color: Colors.redAccent,
//                               child: const Icon(Icons.delete, color: Colors.white),
//                             ),
//                             onDismissed: (direction) async {
//                               await HistoryService.deleteSingleItem(id: item['id']!, isMyQR: false);
//                               _allHistory.removeWhere((element) => element['id'] == item['id']);
//                               _filterHistory();
//                             },
//                             child: Card(
//                               color: const Color(0xFF1E1E1E),
//                               margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                               child: ListTile(
//                                 leading: CircleAvatar(
//                                   backgroundColor: Colors.black54,
//                                   child: Icon(_getIconForType(displayTitle, itemType), color: Theme.of(context).primaryColor),
//                                 ),
//                                 title: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // টাইপ বা ক্যাটাগরি লেবেল
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                       decoration: BoxDecoration(
//                                         color: Theme.of(context).primaryColor.withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                       child: Text(
//                                         _getTypeLabel(displayTitle, itemType),
//                                         style: TextStyle(
//                                           color: Theme.of(context).primaryColor,
//                                           fontSize: 9,
//                                           fontWeight: FontWeight.bold,
//                                           letterSpacing: 1.0,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       displayTitle, 
//                                       maxLines: 1, 
//                                       overflow: TextOverflow.ellipsis, 
//                                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
//                                     ),
//                                   ],
//                                 ),
//                                 subtitle: Text(item['subtitle']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
//                                 trailing: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : Colors.white30),
//                                       onPressed: () async {
//                                         await HistoryService.toggleFavorite(id: item['id']!);
//                                         _loadHistory(); 
//                                       },
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
//                                       onPressed: () async {
//                                         await HistoryService.deleteSingleItem(id: item['id']!, isMyQR: false);
//                                         _loadHistory();
//                                       },
//                                     ),
//                                     const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
//                                   ],
//                                 ),
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => ScanResultScreen(
//                                         rawValue: displayTitle,
//                                         isBarcodeResult: item['isBarcode'] == 'true',
//                                         barcodeTypeTag: item['barcodeTypeTag'] ?? "",
//                                         itemId: item['id'],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }









// lib/screens/history_screen.dart
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart'; // kIsWeb ট্র্যাকিং এর জন্য
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html; // ওয়েব ডাউনলোডের জন্য
import 'package:file_picker/file_picker.dart'; // নতুন ফাইল পিকার ইম্পোর্ট
import '../widgets/custom_drawer.dart';
import '../services/history_service.dart';
import 'scan_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  final Function(Color) onChangeColor;
  const HistoryScreen({super.key, required this.onChangeColor});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> _allHistory = [];
  List<Map<String, String>> _displayedHistory = [];
  bool _isLoading = true;
  bool _showOnlyFavorites = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_filterHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await HistoryService.getList(false); 
    setState(() {
      _allHistory = data;
      _isLoading = false;
      _filterHistory();
    });
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedHistory = _allHistory.where((item) {
        final title = item['title']!.toLowerCase();
        final type = item['type']!.toLowerCase();
        final matchesSearch = title.contains(query) || type.contains(query);
        final matchesFavorite = !_showOnlyFavorites || item['isFavorite'] == 'true';
        return matchesSearch && matchesFavorite;
      }).toList();
    });
  }

  // ডাটার ভেতরে স্ট্রাকচার বা প্রিফিক্স চেক করে সুনির্দিষ্ট ও সঠিক টাইপ রিটার্ন করার মেথড
  String _getTypeLabel(String title, String type) {
    final String cleanTitle = title.trim();
    final String cleanType = type.toLowerCase();

    if (cleanTitle.startsWith('WIFI:')) {
      return 'WIFI';
    } else if (cleanTitle.startsWith('MATMSG:') || cleanTitle.startsWith('mailto:')) {
      return 'EMAIL';
    } else if (cleanTitle.startsWith('smsto:') || cleanTitle.startsWith('sms:')) {
      return 'SMS';
    } else if (cleanTitle.startsWith('MCARD:') || cleanTitle.startsWith('BEGIN:VCARD')) {
      return 'CONTACT';
    } else if (cleanTitle.startsWith('tel:')) {
      return 'PHONE';
    } else if (cleanTitle.startsWith('geo:')) {
      return 'GEO';
    } else if (cleanTitle.startsWith('BEGIN:VEVENT')) {
      return 'CALENDAR';
    } else if (cleanTitle.startsWith('http://') || cleanTitle.startsWith('https://')) {
      if (cleanType == 'image_qr') return 'IMAGE TO QR';
      return 'URL';
    } else {
      if (cleanType == 'barcode') return 'BARCODE';
      if (cleanType == 'image_scan') return 'IMAGE SCAN';
      return 'TEXT';
    }
  }

  // সঠিক ক্যাটাগরি অনুযায়ী প্রফেশনাল আইকন রিটার্ন করার মেথড
  IconData _getIconForType(String title, String type) {
    final String cleanTitle = title.trim();
    final String cleanType = type.toLowerCase();

    if (cleanTitle.startsWith('WIFI:')) {
      return Icons.wifi;
    } else if (cleanTitle.startsWith('MATMSG:') || cleanTitle.startsWith('mailto:')) {
      return Icons.email;
    } else if (cleanTitle.startsWith('smsto:') || cleanTitle.startsWith('sms:')) {
      return Icons.sms;
    } else if (cleanTitle.startsWith('MCARD:') || cleanTitle.startsWith('BEGIN:VCARD')) {
      return Icons.contact_mail;
    } else if (cleanTitle.startsWith('tel:')) {
      return Icons.phone;
    } else if (cleanTitle.startsWith('geo:')) {
      return Icons.location_on;
    } else if (cleanTitle.startsWith('BEGIN:VEVENT')) {
      return Icons.calendar_today;
    } else if (cleanTitle.startsWith('http://') || cleanTitle.startsWith('https://')) {
      if (cleanType == 'image_qr') return Icons.image;
      return Icons.link;
    } else {
      if (cleanType == 'barcode') return Icons.reorder;
      if (cleanType == 'image_scan') return Icons.image_search;
      return Icons.text_fields;
    }
  }

  // --- ৫ নম্বর ফিচারের জন্য অফলাইন সিএসভি (Excel) এক্সপোর্ট জেনারেটর মেথড ---
  Future<void> _exportBackup() async {
    if (_allHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No history available to export!'), 
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      String csvContent = await HistoryService.exportHistoryToCSV();
      
      if (kIsWeb) {
        final bytes = Uri.encodeComponent(csvContent);
        final anchor = html.AnchorElement(href: "data:text/csv;charset=utf-8,%EF%BB%BF$bytes")
          ..setAttribute("download", "shortfy_qr_history_${DateTime.now().millisecondsSinceEpoch}.csv")
          ..click();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History Excel/CSV file downloaded successfully! 📊'), 
            backgroundColor: Colors.blueAccent,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offline Backup generated & saved successfully! 💾'), 
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- নতুন সংযোজন: ব্যাকআপ ইমপোর্ট করার মেথড ---
  Future<void> _importBackup() async {
    try {
      // ফোন বা কম্পিউটার মেমোরি থেকে শুধুমাত্র .csv ফাইল সিলেক্ট করার অপশন
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        String csvRawString = "";

        if (kIsWeb) {
          // ওয়েবের জন্য বাইট থেকে স্ট্রিং কনভার্ট
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            csvRawString = utf8.decode(bytes);
          }
        } else {
          // মোবাইল বা ডেস্কটপের জন্য সরাসরি ফাইল পাথ থেকে রিড
          final file = java_io_file_fallback(result.files.first.path); 
          if (file != null) {
            csvRawString = await file.readAsString();
          }
        }

        if (csvRawString.isNotEmpty) {
          // আমাদের HistoryService-এর ইম্পোর্ট ফাংশন কল করা হলো
          bool success = await HistoryService.importHistoryFromCSV(csvRawString);

          if (!mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup imported successfully! 🎉'), backgroundColor: Colors.green),
            );
            _loadHistory(); // নতুন হিস্ট্রি লোড করে স্ক্রিন আপডেট করা
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new data found or Invalid CSV file!'), backgroundColor: Colors.orange),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // বিভিন্ন প্ল্যাটফর্মের জন্য ফাইল হ্যান্ডলার হেল্পার
  dynamic java_io_file_fallback(String? path) {
    if (path == null) return null;
    return kIsWeb ? null : java_io_file(path);
  }

dynamic java_io_file(String path) {
    return io.File(path); // সরাসরি ডার্ট আইও ফাইল অবজেক্ট রিটার্ন করবে
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // ১. নতুন সংযোজিত "ইম্পোর্ট বাটন" (ফাইল আপলোড আইকন)
          IconButton(
            icon: const Icon(Icons.file_upload, color: Colors.greenAccent, size: 28),
            tooltip: 'Import Backup (.csv)',
            onPressed: _importBackup,
          ),
          // ২. আপনার এক্সপোর্ট বাটন
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.blueAccent, size: 28),
            tooltip: 'Export to Excel/CSV',
            onPressed: _exportBackup,
          ),
          IconButton(
            icon: Icon(_showOnlyFavorites ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
                _filterHistory();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 28),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text('Clear History?', style: TextStyle(color: Colors.white)),
                  content: const Text('Are you sure you want to delete all history?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await HistoryService.clearStorage(false);
                _loadHistory();
              }
            },
          ),
        ],
      ),
      drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search history...',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : _displayedHistory.isEmpty
                    ? const Center(child: Text('No history found!', style: TextStyle(color: Colors.white54, fontSize: 16)))
                    : ListView.builder(
                        itemCount: _displayedHistory.length,
                        itemBuilder: (context, index) {
                          final item = _displayedHistory[index];
                          final bool isFav = item['isFavorite'] == 'true';
                          final String displayTitle = item['title']!;
                          final String itemType = item['type'] ?? '';

                          return Dismissible(
                            key: Key(item['id']!),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              color: Colors.redAccent,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              await HistoryService.deleteSingleItem(id: item['id']!, isMyQR: false);
                              _allHistory.removeWhere((element) => element['id'] == item['id']);
                              _filterHistory();
                            },
                            child: Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: Icon(_getIconForType(displayTitle, itemType), color: Theme.of(context).primaryColor),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getTypeLabel(displayTitle, itemType),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      displayTitle, 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis, 
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                ),
                                subtitle: Text(item['subtitle']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : Colors.white30),
                                      onPressed: () async {
                                        await HistoryService.toggleFavorite(id: item['id']!);
                                        _loadHistory(); 
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () async {
                                        await HistoryService.deleteSingleItem(id: item['id']!, isMyQR: false);
                                        _loadHistory();
                                      },
                                    ),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScanResultScreen(
                                        rawValue: displayTitle,
                                        isBarcodeResult: item['isBarcode'] == 'true',
                                        barcodeTypeTag: item['barcodeTypeTag'] ?? "",
                                        itemId: item['id'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}