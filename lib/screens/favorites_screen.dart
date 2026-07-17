// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../services/history_service.dart';
import 'scan_result_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final Function(Color) onChangeColor;
  const FavoritesScreen({super.key, required this.onChangeColor});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, String>> _favoriteItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final allHistory = await HistoryService.getList(false);
    
    setState(() {
      _favoriteItems = allHistory.where((item) => item['isFavorite'] == 'true').toList();
      _isLoading = false;
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

  // সঠিক ক্যাটাগরি অনুযায়ী প্রফেশনাল আইকন রিটার্ন করার মেথড
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _favoriteItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border_rounded, size: 80, color: Colors.white24),
                      SizedBox(height: 15),
                      Text(
                        'No favorite items yet!',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Tap the star icon on any scanned or created QR code to save it here.',
                        style: TextStyle(color: Colors.white30, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = _favoriteItems[index];
                    final String displayTitle = item['title']!;
                    final String itemType = item['type'] ?? '';

                    return Card(
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
                              icon: const Icon(Icons.star, color: Colors.amber),
                              onPressed: () async {
                                await HistoryService.toggleFavorite(id: item['id']!);
                                _loadFavorites(); 
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
                          ).then((value) => _loadFavorites()); 
                        },
                      ),
                    );
                  },
                ),
    );
  }
}