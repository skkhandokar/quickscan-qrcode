
// // lib/services/history_service.dart
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class HistoryService {
//   static const String _keyHistory = 'qr_history_list';
//   static const String _keyUserProfile = 'user_profile_data';
  
//   // ৫ নম্বর ফিচারের অটো-অ্যাকশন সেটিংস কীসমূহ
//   static const String _keyAutoCopy = 'settings_auto_copy';
//   static const String _keyAutoOpen = 'settings_auto_open';

//   // --- স্মার্ট অটো-অ্যাকশন সেটিংস সেভ ও রিড করার মেথড ---
//   static Future<void> setAutoSettings(bool autoCopy, bool autoOpen) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyAutoCopy, autoCopy);
//     await prefs.setBool(_keyAutoOpen, autoOpen);
//   }

//   static Future<Map<String, bool>> getAutoSettings() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return {
//       'autoCopy': prefs.getBool(_keyAutoCopy) ?? false,
//       'autoOpen': prefs.getBool(_keyAutoOpen) ?? false,
//     };
//   }

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
//         if (lastItem['title'] == title && lastItem['type'] == type) {
//           int lastTimestamp = int.tryParse(lastItem['id'] ?? '') ?? 0;
//           int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
//           if (lastTimestamp != 0 && (currentTimestamp - lastTimestamp).abs() < 2000) {
//             print("Duplicate entry prevented for title: $title");
//             return; 
//           }
//         }
//       } catch (e) {
//         // parsing error
//       }
//     }

//     final DateTime now = DateTime.now();
//     final String formattedDate = 
//         "${now.month}/${now.day}/${now.year % 100} "
//         "${now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour)}:"
//         "${now.minute.toString().padLeft(2, '0')} "
//         "${now.hour >= 12 ? 'PM' : 'AM'}";

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

//   // CSV Export (Excel & Import Both Friendly)
//   static Future<String> exportHistoryToCSV() async {
//     final List<Map<String, String>> historyList = await getList(false);
//     StringBuffer csvBuilder = StringBuffer();
//     csvBuilder.writeln("ID,Category,Content,Date,Is Barcode,Is Favorite");

//     for (var item in historyList) {
//       String id = item['id'] ?? '';
//       String excelId = '="$id"'; 
//       String type = item['type'] ?? 'text';
//       String title = item['title'] ?? '';
//       title = '"${title.replaceAll('"', '""')}"'; 
//       String subtitle = item['subtitle'] ?? '';
//       String isBarcode = item['isBarcode'] ?? 'false';
//       String isFavorite = item['isFavorite'] ?? 'false';

//       csvBuilder.writeln("$excelId,$type,$title,$subtitle,$isBarcode,$isFavorite");
//     }
//     return csvBuilder.toString();
//   }

//   // --- CSV ফাইল থেকে ব্যাকআপ অ্যাপের ভেতর IMPORT করার ১০০% ওয়ার্কিং ফাংশন (FIXED) ---
//   static Future<bool> importHistoryFromCSV(String csvRawString) async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final List<String> currentList = prefs.getStringList(_keyHistory) ?? [];
      
//       // LineSplitter ব্যবহারে \r\n এবং \n উভয় প্রবলেম সলভ হয়
//       List<String> lines = const LineSplitter().convert(csvRawString);
//       if (lines.length <= 1) return false;

//       bool dataImported = false;

//       for (int i = 1; i < lines.length; i++) {
//         String line = lines[i].trim();
//         if (line.isEmpty) continue;

//         // CSV লাইন ভাঙার নিরাপদ লজিক
//         List<String> columns = [];
//         bool inQuotes = false;
//         StringBuffer sb = StringBuffer();

//         for (int ch = 0; ch < line.length; ch++) {
//           String char = line[ch];
//           if (char == '"') {
//             inQuotes = !inQuotes;
//           } else if (char == ',' && !inQuotes) {
//             columns.add(sb.toString());
//             sb.clear();
//           } else {
//             sb.write(char);
//           }
//         }
//         columns.add(sb.toString());

//         if (columns.length >= 6) {
//           String rawId = columns[0].trim();
//           String type = columns[1].trim();
//           String title = columns[2].trim();
//           String subtitle = columns[3].trim();
//           String isBarcode = columns[4].trim();
//           String isFavorite = columns[5].trim();

//           // Excel Formatting Clean up
//           if (rawId.startsWith('="') && rawId.endsWith('"')) {
//             rawId = rawId.substring(2, rawId.length - 1);
//           }
//           if (title.startsWith('"') && title.endsWith('"')) {
//             title = title.substring(1, title.length - 1);
//           }
//           title = title.replaceAll('""', '"');

//           // আইডি দিয়ে ডুপ্লিকেট চেক
//           bool isAlreadyExist = currentList.any((itemStr) {
//             try {
//               final Map<String, dynamic> item = jsonDecode(itemStr);
//               return item['id'] == rawId;
//             } catch (e) {
//               return false;
//             }
//           });

//           if (!isAlreadyExist && title.isNotEmpty) {
//             final Map<String, dynamic> importedItem = {
//               'id': rawId.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : rawId,
//               'type': type.isEmpty ? 'text' : type,
//               'title': title,
//               'subtitle': subtitle,
//               'isBarcode': isBarcode,
//               'barcodeTypeTag': type == 'barcode' ? 'code128' : '',
//               'isFavorite': isFavorite,
//             };
//             currentList.add(jsonEncode(importedItem));
//             dataImported = true;
//           }
//         }
//       }

//       if (dataImported) {
//         // টাইমস্ট্যাম্প বা আইডি অনুযায়ী সাজিয়ে সেভ
//         currentList.sort((a, b) {
//           try {
//             final idA = jsonDecode(a)['id'] ?? '';
//             final idB = jsonDecode(b)['id'] ?? '';
//             return idB.compareTo(idA);
//           } catch (e) {
//             return 0;
//           }
//         });
//         await prefs.setStringList(_keyHistory, currentList);
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print("Import Error Details: $e");
//       return false;
//     }
//   }

//   // ৪. ইউজার প্রোফাইল সেভ করার ফাংশন
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

//   static Future<void> deleteUserProfile() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyUserProfile);
//   }

//   static Future<bool> isFavorite(String id) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<String> historyList = prefs.getStringList(_keyHistory) ?? [];
//     for (var itemStr in historyList) {
//       try {
//         final Map<String, dynamic> item = jsonDecode(itemStr);
//         if (item['id'] == id && item['isFavorite'] == "true") return true;
//       } catch (e) {
//         continue; 
//       }
//     }
//     return false;
//   }

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

//   static Future<void> deleteSingleItem({required String id, required bool isMyQR}) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<String> existingList = prefs.getStringList(_keyHistory) ?? [];
//     existingList.removeWhere((itemStr) => jsonDecode(itemStr)['id'] == id);
//     await prefs.setStringList(_keyHistory, existingList);
//   }

//   static Future<void> clearStorage(bool isMyQR) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keyHistory);
//   } 
// }








// lib/services/history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // Platform এবং File-এর জন্য
import 'package:flutter/foundation.dart'; // kIsWeb-এর জন্য
import 'package:path_provider/path_provider.dart'; // getExternalStorageDirectory & getApplicationDocumentsDirectory-এর জন্য
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



// history_service.dart এ এই মেথডটি যোগ বা আপডেট করুন
  static Future<String?> saveCSVToFile() async {
    try {
      String csvContent = await exportHistoryToCSV();
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        return null;
      }

      final String filePath = "${directory.path}/quickscan_history_${DateTime.now().millisecondsSinceEpoch}.csv";
      final File file = File(filePath);
      await file.writeAsString(csvContent);

      return filePath;
    } catch (e) {
      print("Error saving CSV: $e");
      return null;
    }
  }
  
  
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

  // --- CSV ফাইল থেকে ব্যাকআপ অ্যাপের ভেতর IMPORT করার ১০০% ওয়ার্কিং ফাংশন (FIXED) ---
  static Future<bool> importHistoryFromCSV(String csvRawString) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> currentList = prefs.getStringList(_keyHistory) ?? [];
      
      // LineSplitter ব্যবহারে \r\n এবং \n উভয় প্রবলেম সলভ হয়
      List<String> lines = const LineSplitter().convert(csvRawString);
      if (lines.length <= 1) return false;

      bool dataImported = false;

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        // CSV লাইন ভাঙার নিরাপদ লজিক
        List<String> columns = [];
        bool inQuotes = false;
        StringBuffer sb = StringBuffer();

        for (int ch = 0; ch < line.length; ch++) {
          String char = line[ch];
          if (char == '"') {
            inQuotes = !inQuotes;
          } else if (char == ',' && !inQuotes) {
            columns.add(sb.toString());
            sb.clear();
          } else {
            sb.write(char);
          }
        }
        columns.add(sb.toString());

        if (columns.length >= 6) {
          String rawId = columns[0].trim();
          String type = columns[1].trim();
          String title = columns[2].trim();
          String subtitle = columns[3].trim();
          String isBarcode = columns[4].trim();
          String isFavorite = columns[5].trim();

          // Excel Formatting Clean up
          if (rawId.startsWith('="') && rawId.endsWith('"')) {
            rawId = rawId.substring(2, rawId.length - 1);
          }
          if (title.startsWith('"') && title.endsWith('"')) {
            title = title.substring(1, title.length - 1);
          }
          title = title.replaceAll('""', '"');

          // আইডি দিয়ে ডুপ্লিকেট চেক
          bool isAlreadyExist = currentList.any((itemStr) {
            try {
              final Map<String, dynamic> item = jsonDecode(itemStr);
              return item['id'] == rawId;
            } catch (e) {
              return false;
            }
          });

          if (!isAlreadyExist && title.isNotEmpty) {
            final Map<String, dynamic> importedItem = {
              'id': rawId.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : rawId,
              'type': type.isEmpty ? 'text' : type,
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
        // টাইমস্ট্যাম্প বা আইডি অনুযায়ী সাজিয়ে সেভ
        currentList.sort((a, b) {
          try {
            final idA = jsonDecode(a)['id'] ?? '';
            final idB = jsonDecode(b)['id'] ?? '';
            return idB.compareTo(idA);
          } catch (e) {
            return 0;
          }
        });
        await prefs.setStringList(_keyHistory, currentList);
        return true;
      }
      return false;
    } catch (e) {
      print("Import Error Details: $e");
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