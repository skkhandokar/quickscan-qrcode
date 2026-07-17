// // lib/screens/create_qr_screen.dart
// import 'package:flutter/material.dart';
// import '../widgets/custom_drawer.dart';
// import 'form_screens/all_forms.dart';
// import 'create_image_qr_screen.dart'; 

// // ইম্পোর্ট পাথ আপনার প্রজেক্ট স্ট্রাকচার অনুযায়ী নিখুঁত করা হলো
// import 'form_screens/simple_form_screen.dart'; 
// import 'form_screens/wifi_form_screen.dart'; 

// class CreateQRScreen extends StatelessWidget {
//   final Function(Color) onChangeColor;
//   const CreateQRScreen({super.key, required this.onChangeColor});

//   @override
//   Widget build(BuildContext context) {
//     // কিউআর টাইপসমূহ
//     final List<Map<String, dynamic>> qrTypes = [
//       {'icon': Icons.link, 'title': 'URL', 'tag': 'url'},
//       {'icon': Icons.text_fields, 'title': 'Text', 'tag': 'text'},
//       {'icon': Icons.image, 'title': 'Image to QR', 'tag': 'image'}, 
//       {'icon': Icons.person, 'title': 'Contact', 'tag': 'contact'},
//       {'icon': Icons.email, 'title': 'Email', 'tag': 'email'},
//       {'icon': Icons.sms, 'title': 'SMS', 'tag': 'sms'},
//       {'icon': Icons.location_on, 'title': 'Geo', 'tag': 'geo'},
//       {'icon': Icons.phone, 'title': 'Phone', 'tag': 'phone'},
//       {'icon': Icons.calendar_month, 'title': 'Calendar', 'tag': 'calendar'},
//       {'icon': Icons.wifi, 'title': 'Wifi', 'tag': 'wifi'},
//     ];

//     // বারকোড টাইপসমূহ
//     final List<Map<String, dynamic>> barcodeTypes = [
//       {'title': 'EAN_8', 'tag': 'ean8'},
//       {'title': 'EAN_13', 'tag': 'ean13'},
//       {'title': 'UPC_E', 'tag': 'upce'},
//       {'title': 'UPC_A', 'tag': 'upca'},
//       {'title': 'CODE_39', 'tag': 'code39'},
//       {'title': 'CODE_93', 'tag': 'code93'},
//       {'title': 'CODE_128', 'tag': 'code128'},
//       {'title': 'ITF', 'tag': 'itf'},
//       {'title': 'PDF_417', 'tag': 'pdf417'},
//       {'title': 'CODABAR', 'tag': 'codabar'},
//     ];

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Create', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       drawer: CustomDrawer(onChangeColor: onChangeColor),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ListView.separated(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: qrTypes.length,
//               separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
//               itemBuilder: (context, index) {
//                 final item = qrTypes[index];
//                 return ListTile(
//                   leading: Icon(item['icon'], color: Colors.white70),
//                   title: Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 16)),
//                   onTap: () {
//                     // ১. ইমেজ কিউআর হলে ডেডিকেটেড স্ক্রিনে যাবে
//                     if (item['tag'] == 'image') {
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (context) => const CreateImageQRScreen(),
//                       ));
//                     } 
//                     // ২. ওয়াইফাই কিউআর হলে সরাসরি WifiFormScreen-এ যাবে
//                     else if (item['tag'] == 'wifi') {
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (context) => const WifiFormScreen(),
//                       ));
//                     } 
//                     // ৩. টেক্সট কিউআর হলে সরাসরি SimpleFormScreen-এ যাবে
//                     else if (item['tag'] == 'text') {
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (context) => const SimpleFormScreen(title: 'Text'),
//                       ));
//                     } 
//                     // ৪. অন্য সব সাধারণ কিউআর টাইপের জন্য GenericFormScreen (all_forms) এ যাবে
//                     else {
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (context) => GenericFormScreen(formType: item['tag'], title: item['title']),
//                       ));
//                     }
//                   },
//                 );
//               },
//             ),
            
//             const Padding(
//               padding: EdgeInsets.only(left: 16.0, top: 20, bottom: 10),
//               child: Text(
//                 'Other types',
//                 style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//             ),

//             ListView.separated(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: barcodeTypes.length,
//               separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
//               itemBuilder: (context, index) {
//                 final item = barcodeTypes[index];
//                 return ListTile(
//                   leading: const Icon(Icons.reorder, color: Colors.white70),
//                   title: Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 16)),
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(
//                       builder: (context) => GenericFormScreen(formType: item['tag'], title: item['title'], isBarcode: true),
//                     ));
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



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
//   // নতুন ৩টি টাইপ (সোশ্যাল মিডিয়া, পেমেন্ট ও ড্রাইভ ফাইল) সহ আপডেট করা কিউআর লিস্ট
//   final List<Map<String, dynamic>> _qrOptions = [
//     {
//       'icon': Icons.link,
//       'title': 'Website URL',
//       'type': 'url',
//       'color': Colors.blue,
//     },
//     // --- ১. সোশ্যাল মিডিয়া হাব (WhatsApp, FB, YouTube এর জন্য কাস্টমাইজড) ---
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
//       'color': const Color(0xFF1877F2), // ফেসবুক অফিশিয়াল ব্লু
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
//     // --- ৩. ফাইল ও ক্লাউড শেয়ারিং ---
//     {
//       'icon': Icons.cloud_circle_rounded,
//       'title': 'Google Drive / PDF',
//       'type': 'url',
//       'color': Colors.blue.shade700,
//     },
//     // --- আগের বাকি স্ট্যান্ডার্ড ক্যাটাগরিগুলো ---
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
//             // কিউআর কোড অপশনগুলোর গ্রিড ভিউ (নতুন টাইপ সহ)
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

//             // বারকোড অপশনগুলোর গ্রিড ভিউ
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
  // নতুন ১টি অপশন (Clipboard to QR) সহ আপডেট করা কিউআর লিস্ট
  final List<Map<String, dynamic>> _qrOptions = [
    // --- নতুন সংযোজন: ক্লিপবোর্ড টু কিউআর ফিচার ---
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