




// // lib/screens/create_qr_screen.dart
// import 'package:flutter/material.dart';
// import '../widgets/custom_drawer.dart';
// import './generic_form_screen.dart'; 

// class CreateQRScreen extends StatefulWidget {
//   final Function(Color) onChangeColor;
//   const CreateQRScreen({super.key, required this.onChangeColor});

//   @override
//   State<CreateQRScreen> createState() => _CreateQRScreenState();
// }

// class _CreateQRScreenState extends State<CreateQRScreen> {
//   // নতুন ১টি অপশন (Clipboard to QR) সহ আপডেট করা কিউআর লিস্ট
//   final List<Map<String, dynamic>> _qrOptions = [
//     // --- নতুন সংযোজন: ক্লিপবোর্ড টু কিউআর ফিচার ---
//     {
//       'icon': Icons.assignment_returned,
//       'title': 'Clipboard to QR',
//       'type': 'text', 
//       'color': Colors.greenAccent.shade400,
//     },
//     {
//       'icon': Icons.link,
//       'title': 'Website URL',
//       'type': 'url',
//       'color': Colors.blue,
//     },
//     // --- ১. সোশ্যাল মিডিয়া হাব ---
//     {
//       'icon': Icons.chat_rounded,
//       'title': 'WhatsApp Chat',
//       'type': 'url',
//       'color': Colors.greenAccent.shade700,
//     },
//     {
//       'icon': Icons.facebook,
//       'title': 'Facebook Page',
//       'type': 'url',
//       'color': const Color(0xFF1877F2),
//     },
//     {
//       'icon': Icons.play_circle_fill_rounded,
//       'title': 'YouTube Link',
//       'type': 'url',
//       'color': Colors.red,
//     },
//     // --- ২. পেমেন্ট ও বিজনেস কিউআর ---
//     {
//       'icon': Icons.payments_rounded,
//       'title': 'PayPal / Payment',
//       'type': 'url',
//       'color': Colors.amber.shade700,
//     },
//     // --- ৩. ফাইল ও ক্লাউড শেয়ারিং ---
//     {
//       'icon': Icons.cloud_circle_rounded,
//       'title': 'Google Drive / PDF',
//       'type': 'url',
//       'color': Colors.blue.shade700,
//     },
//     // --- স্ট্যান্ডার্ড ক্যাটাগরিগুলো ---
//     {
//       'icon': Icons.text_fields,
//       'title': 'Plain Text',
//       'type': 'text',
//       'color': Colors.orange,
//     },
//     {
//       'icon': Icons.wifi,
//       'title': 'WiFi Network',
//       'type': 'wifi',
//       'color': Colors.green,
//     },
//     {
//       'icon': Icons.contact_mail,
//       'title': 'Contact (vCard)',
//       'type': 'contact',
//       'color': Colors.teal,
//     },
//     {
//       'icon': Icons.sms,
//       'title': 'SMS Message',
//       'type': 'sms',
//       'color': Colors.purple,
//     },
//     {
//       'icon': Icons.phone,
//       'title': 'Phone Number',
//       'type': 'phone',
//       'color': Colors.indigo,
//     },
//     {
//       'icon': Icons.email,
//       'title': 'Email Message',
//       'type': 'email',
//       'color': Colors.redAccent,
//     },
//     {
//       'icon': Icons.location_on,
//       'title': 'Geo Location',
//       'type': 'geo',
//       'color': Colors.pink,
//     },
//     {
//       'icon': Icons.calendar_today,
//       'title': 'Calendar Event',
//       'type': 'calendar',
//       'color': Colors.cyan,
//     },
//   ];

//   final List<Map<String, dynamic>> _barcodeOptions = [
//     {'title': 'EAN-8', 'type': 'ean8'},
//     {'title': 'EAN-13', 'type': 'ean13'},
//     {'title': 'Code 128', 'type': 'code128'},
//     {'title': 'UPC-A', 'type': 'upca'},
//     {'title': 'UPC-E (Compact Retail)', 'type': 'upce'},
//     {'title': 'Code 39 (Alphanumeric)', 'type': 'code39'},
//     {'title': 'ISBN (Book Barcode)', 'type': 'isbn'},
//     {'title': 'ITF-14 (Shipping Carton)', 'type': 'itf14'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           title: const Text('Create QR / Barcode', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           iconTheme: const IconThemeData(color: Colors.white),
//           bottom: const TabBar(
//             indicatorColor: Colors.blueAccent,
//             labelColor: Colors.blueAccent,
//             unselectedLabelColor: Colors.white54,
//             tabs: [
//               Tab(text: 'QR CODE'),
//               Tab(text: 'BARCODE'),
//             ],
//           ),
//         ),
//         drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
//         body: TabBarView(
//           children: [
//             // ১. কিউআর কোড অপশনগুলোর গ্রিড ভিউ
//             GridView.builder(
//               padding: const EdgeInsets.all(20.0),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 15,
//                 mainAxisSpacing: 15,
//                 childAspectRatio: 1.2,
//               ),
//               itemCount: _qrOptions.length,
//               itemBuilder: (context, index) {
//                 final option = _qrOptions[index];
//                 return InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => GenericFormScreen(
//                           formType: option['type'],
//                           title: option['title'],
//                           isBarcode: false,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     color: const Color(0xFF1E1E1E),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: option['color'].withOpacity(0.15),
//                           radius: 26,
//                           child: Icon(option['icon'], color: option['color'], size: 28),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           option['title'],
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),

//             // ২. বারকোড অপশনগুলোর গ্রিড ভিউ
//             GridView.builder(
//               padding: const EdgeInsets.all(20.0),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 15,
//                 mainAxisSpacing: 15,
//                 childAspectRatio: 1.3,
//               ),
//               itemCount: _barcodeOptions.length,
//               itemBuilder: (context, index) {
//                 final option = _barcodeOptions[index];
//                 return InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => GenericFormScreen(
//                           formType: option['type'],
//                           title: option['title'],
//                           isBarcode: true,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     color: const Color(0xFF1E1E1E),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.reorder, color: Colors.blueAccent, size: 36),
//                         const SizedBox(height: 10),
//                         Text(
//                           option['title'],
//                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

















// lib/screens/create_qr_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import './generic_form_screen.dart'; 

class CreateQRScreen extends StatefulWidget {
  final Function(Color) onChangeColor;
  const CreateQRScreen({super.key, required this.onChangeColor});

  @override
  State<CreateQRScreen> createState() => _CreateQRScreenState();
}

class _CreateQRScreenState extends State<CreateQRScreen> {
  // ফাইল টু কিউআর সহ আপডেট করা কিউআর লিস্ট
  final List<Map<String, dynamic>> _qrOptions = [
    // --- নতুন সংযোজন: ফাইল টু কিউআর অপশন ---
    {
      'icon': Icons.attach_file_rounded,
      'title': 'File to QR',
      'type': 'file', 
      'color': Colors.deepOrangeAccent,
    },
    // --- ক্লিপবোর্ড টু কিউআর ---
    {
      'icon': Icons.assignment_returned,
      'title': 'Clipboard to QR',
      'type': 'text', 
      'color': Colors.greenAccent.shade400,
    },
    {
      'icon': Icons.link,
      'title': 'Website URL',
      'type': 'url',
      'color': Colors.blue,
    },
    // --- ১. সোশ্যাল মিডিয়া হাব ---
    {
      'icon': Icons.chat_rounded,
      'title': 'WhatsApp Chat',
      'type': 'url',
      'color': Colors.greenAccent.shade700,
    },
    {
      'icon': Icons.facebook,
      'title': 'Facebook Page',
      'type': 'url',
      'color': const Color(0xFF1877F2),
    },
    {
      'icon': Icons.play_circle_fill_rounded,
      'title': 'YouTube Link',
      'type': 'url',
      'color': Colors.red,
    },
    // --- ২. পেমেন্ট ও বিজনেস কিউআর ---
    {
      'icon': Icons.payments_rounded,
      'title': 'PayPal / Payment',
      'type': 'url',
      'color': Colors.amber.shade700,
    },
    // --- ৩. ফাইল ও ক্লাউড শেয়ারিং ---
    {
      'icon': Icons.cloud_circle_rounded,
      'title': 'Google Drive / PDF',
      'type': 'url',
      'color': Colors.blue.shade700,
    },
    // --- স্ট্যান্ডার্ড ক্যাটাগরিগুলো ---
    {
      'icon': Icons.text_fields,
      'title': 'Plain Text',
      'type': 'text',
      'color': Colors.orange,
    },
    {
      'icon': Icons.wifi,
      'title': 'WiFi Network',
      'type': 'wifi',
      'color': Colors.green,
    },
    {
      'icon': Icons.contact_mail,
      'title': 'Contact (vCard)',
      'type': 'contact',
      'color': Colors.teal,
    },
    {
      'icon': Icons.sms,
      'title': 'SMS Message',
      'type': 'sms',
      'color': Colors.purple,
    },
    {
      'icon': Icons.phone,
      'title': 'Phone Number',
      'type': 'phone',
      'color': Colors.indigo,
    },
    {
      'icon': Icons.email,
      'title': 'Email Message',
      'type': 'email',
      'color': Colors.redAccent,
    },
    {
      'icon': Icons.location_on,
      'title': 'Geo Location',
      'type': 'geo',
      'color': Colors.pink,
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Calendar Event',
      'type': 'calendar',
      'color': Colors.cyan,
    },
  ];

  final List<Map<String, dynamic>> _barcodeOptions = [
    {'title': 'EAN-8', 'type': 'ean8'},
    {'title': 'EAN-13', 'type': 'ean13'},
    {'title': 'Code 128', 'type': 'code128'},
    {'title': 'UPC-A', 'type': 'upca'},
    {'title': 'UPC-E (Compact Retail)', 'type': 'upce'},
    {'title': 'Code 39 (Alphanumeric)', 'type': 'code39'},
    {'title': 'ISBN (Book Barcode)', 'type': 'isbn'},
    {'title': 'ITF-14 (Shipping Carton)', 'type': 'itf14'},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Create QR / Barcode', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'QR CODE'),
              Tab(text: 'BARCODE'),
            ],
          ),
        ),
        drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
        body: TabBarView(
          children: [
            // ১. কিউআর কোড অপশনগুলোর গ্রিড ভিউ
            GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2,
              ),
              itemCount: _qrOptions.length,
              itemBuilder: (context, index) {
                final option = _qrOptions[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericFormScreen(
                          formType: option['type'],
                          title: option['title'],
                          isBarcode: false,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: option['color'].withOpacity(0.15),
                          radius: 26,
                          child: Icon(option['icon'], color: option['color'], size: 28),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          option['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ২. বারকোড অপশনগুলোর গ্রিড ভিউ
            GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
              ),
              itemCount: _barcodeOptions.length,
              itemBuilder: (context, index) {
                final option = _barcodeOptions[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenericFormScreen(
                          formType: option['type'],
                          title: option['title'],
                          isBarcode: true,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.reorder, color: Colors.blueAccent, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          option['title'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}