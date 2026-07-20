



// // lib/widgets/custom_drawer.dart
// import 'package:flutter/material.dart';
// import '../screens/home_screen.dart';
// import '../screens/create_qr_screen.dart';
// import '../screens/my_qrcode_screen.dart';
// import '../screens/history_screen.dart';
// import '../screens/favorites_screen.dart';
// import '../screens/settings_screen.dart';
// import '../screens/image_scan_screen.dart'; // নতুন স্ক্রিন ইম্পোর্ট

// class CustomDrawer extends StatelessWidget {
//   final Function(Color) onChangeColor;
//   const CustomDrawer({super.key, required this.onChangeColor});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Container(
//         color: const Color(0xFF1E1E1E),
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Theme.of(context).primaryColor),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text('Shortfy QR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
//                   SizedBox(height: 5),
//                   Text('Scan & Generate easily', style: TextStyle(color: Colors.white70)),
//                 ],
//               ),
//             ),
//             // ১. লাইভ ক্যামেরা স্ক্যান (HomeScreen)
//             _drawerItem(Icons.qr_code_scanner, 'Scan', context, HomeScreen(onChangeColor: onChangeColor)),
            
//             // ২. গ্যালারি ইমেজ স্ক্যান (ImageScanScreen - সাথে অটো-ওপেন ফ্ল্যাগ)
//             _drawerItem(
//               Icons.photo_library_rounded, 
//               'Scan Image', 
//               context, 
//               ImageScanScreen(onChangeColor: onChangeColor, autoOpenGallery: true),
//             ),

//             // ৩. কিউআর তৈরি করার স্ক্রিন (CreateQRScreen)
//             _drawerItem(Icons.edit, 'Create QR', context, CreateQRScreen(onChangeColor: onChangeColor)),
            
//             _drawerItem(Icons.qr_code_2_rounded, 'My QR Code', context, MyQRCodeScreen(onChangeColor: onChangeColor)),
//             _drawerItem(Icons.history, 'History', context, HistoryScreen(onChangeColor: onChangeColor)),
//             _drawerItem(Icons.star_rounded, 'Favorites', context, FavoritesScreen(onChangeColor: onChangeColor)),
//             _drawerItem(Icons.settings, 'Settings', context, SettingsScreen(onChangeColor: onChangeColor)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _drawerItem(IconData icon, String title, BuildContext context, Widget targetScreen) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.white70),
//       title: Text(title, style: const TextStyle(color: Colors.white)),
//       onTap: () {
//         Navigator.pop(context);
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => targetScreen));
//       },
//     );
//   }
// }







// lib/widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // শেয়ার করার মূল প্যাকেজ
import '../screens/home_screen.dart';
import '../screens/create_qr_screen.dart';
import '../screens/my_qrcode_screen.dart';
import '../screens/history_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/image_scan_screen.dart';
import '../screens/about_screen.dart';

class CustomDrawer extends StatelessWidget {
  final Function(Color) onChangeColor;
  const CustomDrawer({super.key, required this.onChangeColor});

  // --- শেয়ার উইজেটের ব্যাকএন্ড লজিক ---
  void _shareAppAction(BuildContext context) {
    Navigator.pop(context); // প্রথমে ড্রয়ারটি স্ক্রিন থেকে সরিয়ে দেওয়া হলো
    
    // আপনার অ্যাপের ইউনিক প্যাকেজ আইডি (যা প্লে-স্টোরে আপলোড করার সময় ব্যবহার করবেন)
    const String packageName = 'com.yourcompany.quickscanqr'; 
    const String playStoreLink = 'https://play.google.com/store/apps/details?id=$packageName';
    
    // যে মেসেজটি হোয়াটসঅ্যাপ বা মেসেঞ্জারে বন্ধুদের কাছে যাবে
    const String shareMessage = 
        'Hey! Try QuickScan QR & Barcode 📲\n\n'
        'It\'s a super-fast QR & Barcode Scanner and Generator. '
        'Scan from photos, customize codes with logos, and use bulk scan mode for free!\n\n'
        'Download from Play Store:\n$playStoreLink';
    
    // ফোনের অফিশিয়াল শেয়ার প্যানেল বা শিট ওপেন করা
    Share.share(shareMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 10, 10, 10), // ডার্ক ব্যাকগ্রাউন্ড
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ড্রয়ার হেডার
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'QuickScan', 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'QR & Barcode Utility', 
                    style: TextStyle(color: Color.fromARGB(179, 254, 253, 253), fontSize: 13),
                  ),
                ],
              ),
            ),
            
            // ১. লাইভ ক্যামেরা স্ক্যান (HomeScreen)
            _drawerItem(Icons.qr_code_scanner, 'Scan', context, HomeScreen(onChangeColor: onChangeColor)),
            
            // ২. গ্যালারি ইমেজ স্ক্যান (ImageScanScreen)
            _drawerItem(
              Icons.photo_library_rounded, 
              'Scan Image', 
              context, 
              ImageScanScreen(onChangeColor: onChangeColor, autoOpenGallery: true),
            ),

            // ৩. কিউআর তৈরি করার স্ক্রিন (CreateQRScreen)
            _drawerItem(Icons.edit, 'Create QR', context, CreateQRScreen(onChangeColor: onChangeColor)),
            
            // ৪. কাস্টম কিউআর লিস্ট, হিস্ট্রি ও সেটিংস
            _drawerItem(Icons.qr_code_2_rounded, 'My QR Code', context, MyQRCodeScreen(onChangeColor: onChangeColor)),
            _drawerItem(Icons.history, 'History', context, HistoryScreen(onChangeColor: onChangeColor)),
            _drawerItem(Icons.star_rounded, 'Favorites', context, FavoritesScreen(onChangeColor: onChangeColor)),
            _drawerItem(Icons.settings, 'Settings', context, SettingsScreen(onChangeColor: onChangeColor)),
            
            // একটি সুন্দর ডিভাইডার লাইন
            const Divider(color: Colors.white10, height: 20, thickness: 1.2),

            // ৫. নতুন যুক্ত করা About App স্ক্রিন বাটন
            _drawerItem(Icons.info_outline_rounded, 'About App', context, AboutScreen(onChangeColor: onChangeColor)),

            // 🌟 ৬. নতুন যুক্ত করা Share App উইজেট বাটন
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.white70),
              title: const Text(
                'Share App', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              onTap: () => _shareAppAction(context), // ট্যাপ করলে শেয়ার ফাংশন রান হবে
            ),
          ],
        ),
      ),
    );
  }

  // স্ক্রিন পরিবর্তনের জন্য কমন ড্রয়ার আইটেম মেথড
  Widget _drawerItem(IconData icon, String title, BuildContext context, Widget targetScreen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // ড্রয়ার বন্ধ হবে
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => targetScreen),
        ); // নতুন স্ক্রিনে চলে যাবে
      },
    );
  }
}