// // lib/services/history_service.dart
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class HistoryService {
//   static const String _keyHistory = 'qr_history_list';
//   static const String _keyUserProfile = 'user_profile_data'; // মাই কিউআরের জন্য প্রোফাইল কী

//   // ১. সাধারণ স্ক্যান ও জেনারেট হিস্ট্রি সেভ করার ফাংশন (Duplicate Prevented & Safe)
//   static Future<void> addToStorage({
//     required bool isMyQR, 
//     required String type,
//     required String title,
//     bool isBarcode = false,
//     String barcodeTypeTag = "",
//     String? customId,
//   }) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
    
//     final String key = _keyHistory;
//     final List<String> existingList = prefs.getStringList(key) ?? [];

//     // --- DUPLICATE CHECK LOGIC START ---
//     if (existingList.isNotEmpty) {
//       try {
//         final Map<String, dynamic> lastItem = jsonDecode(existingList.first);
        
//         // একই কনটেন্ট এবং টাইপ হলে ডুপ্লিকেট চেক সক্রিয় হবে
//         if (lastItem['title'] == title && lastItem['type'] == type) {
//           int lastTimestamp = int.tryParse(lastItem['id'] ?? '') ?? 0;
//           int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          
//           // যদি ব্যবধান ২ সেকেন্ডের (২০০০ মিলিসেকেন্ড) কম হয়, তবে ডুপ্লিকেট হিসেবে বাদ দেবে
//           if (lastTimestamp != 0 && (currentTimestamp - lastTimestamp).abs() < 2000) {
//             print("Duplicate entry prevented for title: $title");
//             return; 
//           }
//         }
//       } catch (e) {
//         // parsing error হলে সেভ হওয়া কন্টিনিউ করবে
//       }
//     }
//     // --- DUPLICATE CHECK LOGIC END ---

//     final DateTime now = DateTime.now();
//     final String formattedDate = 
//         "${now.month}/${now.day}/${now.year % 100} "
//         "${now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour)}:"
//         "${now.minute.toString().padLeft(2, '0')} "
//         "${now.hour >= 12 ? 'PM' : 'AM'}";

//     // timestamp-কে সিস্টেম ট্র্যাকিংয়ের জন্য ব্যবহার করা হচ্ছে
//     final String uniqueId = customId ?? DateTime.now().millisecondsSinceEpoch.toString();

//     final Map<String, dynamic> newItem = {
//       'id': uniqueId,
//       'type': type,
//       'title': title,
//       'subtitle': formattedDate,
//       'isBarcode': isBarcode ? "true" : "false",
//       'barcodeTypeTag': barcodeTypeTag,
//       'isFavorite': "false", 
//     };

//     existingList.insert(0, jsonEncode(newItem));
//     await prefs.setStringList(key, existingList);
//   }

//   // ২. হিস্ট্রি রিড করার ফাংশন
//   static Future<List<Map<String, String>>> getList(bool isMyQR) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<String> jsonList = prefs.getStringList(_keyHistory) ?? [];

//     return jsonList.map((item) {
//       final Map<String, dynamic> decoded = jsonDecode(item);
//       return decoded.map((key, value) => MapEntry(key, value.toString()));
//     }).toList();
//   }

//   // ৩. হিস্ট্রি থেকে র-ডেটা (Raw Data) রিড করার মেথড
//   static Future<List<dynamic>> getItems() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<String> jsonList = prefs.getStringList(_keyHistory) ?? [];
//     return jsonList.map((item) => jsonDecode(item)).toList();
//   }

//   // --- ৫ নম্বর ফিচারের জন্য ফাংশন: CSV Export (Excel & Import Both Friendly) ---
//   static Future<String> exportHistoryToCSV() async {
//     final List<Map<String, String>> historyList = await getList(false);

//     // এক্সেল বা সিএসভি ফাইলের প্রথম লাইনের হেডার (কলামের নামসমূহ)
//     StringBuffer csvBuilder = StringBuffer();
//     csvBuilder.writeln("ID,Category,Content,Date,Is Barcode,Is Favorite");

//     // লুপ চালিয়ে প্রতিটি ডেটা রো (Row) কমা দিয়ে সাজানো
//     for (var item in historyList) {
//       String id = item['id'] ?? '';
      
//       // এক্সেলের বৈজ্ঞানিক রূপ (E+) ঠেকাতে এবং পরবর্তীতে ইমপোর্ট নিরাপদ রাখতে 
//       // স্ট্যান্ডার্ড এক্সেল ফর্মুলা ফরম্যাট ব্যবহার করা হলো।
//       String excelId = '="$id"'; 

//       String type = item['type'] ?? 'text';
      
//       // গুরুত্বপূর্ণ: কন্টেন্টের ভেতর কমা বা এন্টার থাকলে যাতে এক্সেল শিট ভেঙে না যায়
//       String title = item['title'] ?? '';
//       title = '"${title.replaceAll('"', '""')}"'; 

//       String subtitle = item['subtitle'] ?? '';
//       String isBarcode = item['isBarcode'] ?? 'false';
//       String isFavorite = item['isFavorite'] ?? 'false';

//       // কমা সেপারেটেড লাইন তৈরি করে বিল্ডারে যোগ করা
//       csvBuilder.writeln("$excelId,$type,$title,$subtitle,$isBarcode,$isFavorite");
//     }

//     return csvBuilder.toString();
//   }

//   // --- নতুন সংযোজন: CSV ফাইল থেকে ব্যাকআপ অ্যাপের ভেতর IMPORT করার ফাংশন ---
//   static Future<bool> importHistoryFromCSV(String csvRawString) async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final List<String> currentList = prefs.getStringList(_keyHistory) ?? [];
      
//       // লাইন বাই লাইন ডাটা ভাগ করা
//       List<String> lines = csvRawString.split('\n');
//       if (lines.isEmpty) return false;

//       bool dataImported = false;

//       // প্রথম লাইনটি হেডার (ID,Category...) তাই i = 1 থেকে লুপ শুরু করা হলো
//       for (int i = 1; i < lines.length; i++) {
//         String line = lines[i].trim();
//         if (line.isEmpty) continue;

//         // কমা দিয়ে ডাটা আলাদা করা (সিম্পল স্প্লিট লজিক)
//         // ক্যারেক্টার প্রোটেকশনসহ ডাটা রিড করার প্রফেশনাল রেজেক্স
//         final RegExp csvRegExp = RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)');
//         List<String> columns = line.split(csvRegExp);

//         if (columns.length >= 6) {
//           String rawId = columns[0].trim();
//           String type = columns[1].trim();
//           String title = columns[2].trim();
//           String subtitle = columns[3].trim();
//           String isBarcode = columns[4].trim();
//           String isFavorite = columns[5].trim();

//           // ১. আইডি ক্লিনিক লজিক ( ="12345" থেকে পিওর "12345" বের করা )
//           if (rawId.startsWith('="') && rawId.endsWith('"')) {
//             rawId = rawId.substring(2, rawId.length - 1);
//           }

//           // ২. টাইটেলের ডাবল কোটেশন রিমুভ করা
//           if (title.startsWith('"') && title.endsWith('"')) {
//             title = title.substring(1, title.length - 1);
//             title = title.replaceAll('""', '"'); // এস্কেপ ক্যারেক্টার ঠিক করা
//           }

//           // ৩. ডুপ্লিকেট ইম্পোর্ট রোধ করা (ডাটাবেজে অলরেডি এই আইডি আছে কিনা চেক)
//           bool isAlreadyExist = currentList.any((itemStr) {
//             final Map<String, dynamic> item = jsonDecode(itemStr);
//             return item['id'] == rawId;
//           });

//           if (!isAlreadyExist) {
//             final Map<String, dynamic> importedItem = {
//               'id': rawId,
//               'type': type,
//               'title': title,
//               'subtitle': subtitle,
//               'isBarcode': isBarcode,
//               'barcodeTypeTag': type == 'barcode' ? 'code128' : '', // সেফ ফলব্যাক
//               'isFavorite': isFavorite,
//             };

//             // নতুন ডাটা লিস্টে পুশ করা
//             currentList.add(jsonEncode(importedItem));
//             dataImported = true;
//           }
//         }
//       }

//       if (dataImported) {
//         // আইডি ক্রনোলজি অনুযায়ী হিস্ট্রি সর্ট করা (নতুনগুলো ওপরে থাকবে)
//         currentList.sort((a, b) {
//           final idA = jsonDecode(a)['id'] ?? '';
//           final idB = jsonDecode(b)['id'] ?? '';
//           return idB.compareTo(idA);
//         });
        
//         await prefs.setStringList(_keyHistory, currentList);
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print("Error importing CSV: $e");
//       return false;
//     }
//   }

//   // ৪. ইউজার প্রোফাইল সেভ করার ফাংশন (My QR এর জন্য)
//   static Future<void> saveUserProfile(Map<String, String> profileData) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_keyUserProfile, jsonEncode(profileData));
//   }

//   // ৫. ইউজার প্রোফাইল রিড করার ফাংশন
//   static Future<Map<String, String>?> getUserProfile() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? data = prefs.getString(_keyUserProfile);
//     if (data == null) return null;
//     final Map<String, dynamic> decoded = jsonDecode(data);
//     return decoded.map((key, value) => MapEntry(key, value.toString()));
//   }

//   // ৬. প্রোফাইল ডিলিট/রিসেট করার ফাংশন
//   static Future<void> deleteUserProfile() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyUserProfile);
//   }

//   // ৭. স্পেসিফিক কোনো আইডি ফেভারিট তালিকায় আছে কিনা তা চেক করার মেথড
//   static Future<bool> isFavorite(String id) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<String> historyList = prefs.getStringList(_keyHistory) ?? [];

//     for (var itemStr in historyList) {
//       try {
//         final Map<String, dynamic> item = jsonDecode(itemStr);
//         if (item['id'] == id && item['isFavorite'] == "true") {
//           return true;
//         }
//       } catch (e) {
//         continue; 
//       }
//     }
//     return false;
//   }

//   // ৮. ফেভারিট টগল করার মেথড
//   static Future<void> toggleFavorite({required String id}) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<String> historyList = prefs.getStringList(_keyHistory) ?? [];

//     final List<String> updatedHistory = historyList.map((itemStr) {
//       final Map<String, dynamic> item = jsonDecode(itemStr);
//       if (item['id'] == id) {
//         item['isFavorite'] = item['isFavorite'] == "true" ? "false" : "true";
//       }
//       return jsonEncode(item);
//     }).toList();
//     await prefs.setStringList(_keyHistory, updatedHistory);
//   }

//   // ৯. একক হিস্ট্রি আইটেম ডিলিট
//   static Future<void> deleteSingleItem({required String id, required bool isMyQR}) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<String> existingList = prefs.getStringList(_keyHistory) ?? [];

//     existingList.removeWhere((itemStr) {
//       final Map<String, dynamic> item = jsonDecode(itemStr);
//       return item['id'] == id;
//     });

//     await prefs.setStringList(_keyHistory, existingList);
//   }

//   // ১০. সম্পূর্ণ হিস্ট্রি ডিলিট
//   static Future<void> clearStorage(bool isMyQR) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyHistory);
//   } 
// }









// lib/services/history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _keyHistory = 'qr_history_list';
  static const String _keyUserProfile = 'user_profile_data';
  
  // ৫ নম্বর ফিচারের অটো-অ্যাকশন সেটিংস কীসমূহ
  static const String _keyAutoCopy = 'settings_auto_copy';
  static const String _keyAutoOpen = 'settings_auto_open';

  // --- স্মার্ট অটো-অ্যাকশন সেটিংস সেভ ও রিড করার মেথড ---
  static Future<void> setAutoSettings(bool autoCopy, bool autoOpen) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoCopy, autoCopy);
    await prefs.setBool(_keyAutoOpen, autoOpen);
  }

  static Future<Map<String, bool>> getAutoSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'autoCopy': prefs.getBool(_keyAutoCopy) ?? false,
      'autoOpen': prefs.getBool(_keyAutoOpen) ?? false,
    };
  }

  // ১. সাধারণ স্ক্যান ও জেনারেট হিস্ট্রি সেভ করার ফাংশন (Duplicate Prevented & Safe)
  static Future<void> addToStorage({
    required bool isMyQR, 
    required String type,
    required String title,
    bool isBarcode = false,
    String barcodeTypeTag = "",
    String? customId,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = _keyHistory;
    final List<String> existingList = prefs.getStringList(key) ?? [];

    // --- DUPLICATE CHECK LOGIC START ---
    if (existingList.isNotEmpty) {
      try {
        final Map<String, dynamic> lastItem = jsonDecode(existingList.first);
        if (lastItem['title'] == title && lastItem['type'] == type) {
          int lastTimestamp = int.tryParse(lastItem['id'] ?? '') ?? 0;
          int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
          if (lastTimestamp != 0 && (currentTimestamp - lastTimestamp).abs() < 2000) {
            print("Duplicate entry prevented for title: $title");
            return; 
          }
        }
      } catch (e) {
        // parsing error
      }
    }

    final DateTime now = DateTime.now();
    final String formattedDate = 
        "${now.month}/${now.day}/${now.year % 100} "
        "${now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour)}:"
        "${now.minute.toString().padLeft(2, '0')} "
        "${now.hour >= 12 ? 'PM' : 'AM'}";

    final String uniqueId = customId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final Map<String, dynamic> newItem = {
      'id': uniqueId,
      'type': type,
      'title': title,
      'subtitle': formattedDate,
      'isBarcode': isBarcode ? "true" : "false",
      'barcodeTypeTag': barcodeTypeTag,
      'isFavorite': "false", 
    };

    existingList.insert(0, jsonEncode(newItem));
    await prefs.setStringList(key, existingList);
  }

  // ২. হিস্ট্রি রিড করার ফাংশন
  static Future<List<Map<String, String>>> getList(bool isMyQR) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_keyHistory) ?? [];
    return jsonList.map((item) {
      final Map<String, dynamic> decoded = jsonDecode(item);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }).toList();
  }

  // ৩. হিস্ট্রি থেকে র-ডেটা (Raw Data) রিড করার মেথড
  static Future<List<dynamic>> getItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_keyHistory) ?? [];
    return jsonList.map((item) => jsonDecode(item)).toList();
  }

  // CSV Export (Excel & Import Both Friendly)
  static Future<String> exportHistoryToCSV() async {
    final List<Map<String, String>> historyList = await getList(false);
    StringBuffer csvBuilder = StringBuffer();
    csvBuilder.writeln("ID,Category,Content,Date,Is Barcode,Is Favorite");

    for (var item in historyList) {
      String id = item['id'] ?? '';
      String excelId = '="$id"'; 
      String type = item['type'] ?? 'text';
      String title = item['title'] ?? '';
      title = '"${title.replaceAll('"', '""')}"'; 
      String subtitle = item['subtitle'] ?? '';
      String isBarcode = item['isBarcode'] ?? 'false';
      String isFavorite = item['isFavorite'] ?? 'false';

      csvBuilder.writeln("$excelId,$type,$title,$subtitle,$isBarcode,$isFavorite");
    }
    return csvBuilder.toString();
  }

  // CSV ফাইল থেকে ব্যাকআপ অ্যাপের ভেতর IMPORT করার ফাংশন
  static Future<bool> importHistoryFromCSV(String csvRawString) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> currentList = prefs.getStringList(_keyHistory) ?? [];
      List<String> lines = csvRawString.split('\n');
      if (lines.isEmpty) return false;

      bool dataImported = false;
      final RegExp csvRegExp = RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)');

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        List<String> columns = line.split(csvRegExp);
        if (columns.length >= 6) {
          String rawId = columns[0].trim();
          String type = columns[1].trim();
          String title = columns[2].trim();
          String subtitle = columns[3].trim();
          String isBarcode = columns[4].trim();
          String isFavorite = columns[5].trim();

          if (rawId.startsWith('="') && rawId.endsWith('"')) {
            rawId = rawId.substring(2, rawId.length - 1);
          }
          if (title.startsWith('"') && title.endsWith('"')) {
            title = title.substring(1, title.length - 1);
            title = title.replaceAll('""', '"');
          }

          bool isAlreadyExist = currentList.any((itemStr) {
            final Map<String, dynamic> item = jsonDecode(itemStr);
            return item['id'] == rawId;
          });

          if (!isAlreadyExist) {
            final Map<String, dynamic> importedItem = {
              'id': rawId,
              'type': type,
              'title': title,
              'subtitle': subtitle,
              'isBarcode': isBarcode,
              'barcodeTypeTag': type == 'barcode' ? 'code128' : '',
              'isFavorite': isFavorite,
            };
            currentList.add(jsonEncode(importedItem));
            dataImported = true;
          }
        }
      }

      if (dataImported) {
        currentList.sort((a, b) {
          final idA = jsonDecode(a)['id'] ?? '';
          final idB = jsonDecode(b)['id'] ?? '';
          return idB.compareTo(idA);
        });
        await prefs.setStringList(_keyHistory, currentList);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ৪. ইউজার প্রোফাইল সেভ করার ফাংশন
  static Future<void> saveUserProfile(Map<String, String> profileData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserProfile, jsonEncode(profileData));
  }

  // ৫. ইউজার প্রোফাইল রিড করার ফাংশন
  static Future<Map<String, String>?> getUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyUserProfile);
    if (data == null) return null;
    final Map<String, dynamic> decoded = jsonDecode(data);
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  static Future<void> deleteUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserProfile);
  }

  static Future<bool> isFavorite(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> historyList = prefs.getStringList(_keyHistory) ?? [];
    for (var itemStr in historyList) {
      try {
        final Map<String, dynamic> item = jsonDecode(itemStr);
        if (item['id'] == id && item['isFavorite'] == "true") return true;
      } catch (e) {
        continue; 
      }
    }
    return false;
  }

  static Future<void> toggleFavorite({required String id}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> historyList = prefs.getStringList(_keyHistory) ?? [];
    final List<String> updatedHistory = historyList.map((itemStr) {
      final Map<String, dynamic> item = jsonDecode(itemStr);
      if (item['id'] == id) {
        item['isFavorite'] = item['isFavorite'] == "true" ? "false" : "true";
      }
      return jsonEncode(item);
    }).toList();
    await prefs.setStringList(_keyHistory, updatedHistory);
  }

  static Future<void> deleteSingleItem({required String id, required bool isMyQR}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> existingList = prefs.getStringList(_keyHistory) ?? [];
    existingList.removeWhere((itemStr) => jsonDecode(itemStr)['id'] == id);
    await prefs.setStringList(_keyHistory, existingList);
  }

  static Future<void> clearStorage(bool isMyQR) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  } 
}