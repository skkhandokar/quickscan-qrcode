import 'package:flutter/material.dart';
import '../scan_result_screen.dart'; 
import '../../services/history_service.dart'; 

class SimpleFormScreen extends StatefulWidget {
  final String title;
  const SimpleFormScreen({super.key, required this.title});

  @override
  State<SimpleFormScreen> createState() => _SimpleFormScreenState();
}

class _SimpleFormScreenState extends State<SimpleFormScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitSimpleForm() async {
    final String content = _controller.text.trim();
    if (content.isNotEmpty) {
      final String commonId = DateTime.now().millisecondsSinceEpoch.toString();

      // ১টি মাত্র সেভ লজিক (যা শুধু সাধারণ হিস্ট্রিতে যাবে)
      await HistoryService.addToStorage(
        isMyQR: false,
        type: 'text',
        title: content,
        customId: commonId,
      );

      if (!mounted) return;

      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          rawValue: content,
          isBarcodeResult: false, 
          barcodeTypeTag: "",
          itemId: commonId,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter some details first!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Create ${widget.title}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blueAccent, size: 28),
            onPressed: _submitSimpleForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: widget.title == 'Notes' || widget.title == 'Biodata' ? 5 : 1,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter ${widget.title} details',
                labelStyle: const TextStyle(color: Colors.white54),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}