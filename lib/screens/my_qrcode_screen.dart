// lib/screens/my_qrcode_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc; 
import '../widgets/custom_drawer.dart';
import '../services/history_service.dart';

class MyQRCodeScreen extends StatefulWidget {
  final Function(Color) onChangeColor;
  const MyQRCodeScreen({super.key, required this.onChangeColor});

  @override
  State<MyQRCodeScreen> createState() => _MyQRCodeScreenState();
}

class _MyQRCodeScreenState extends State<MyQRCodeScreen> {
  bool _isLoading = true;
  bool _hasProfile = false;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _webController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  Map<String, String> _profileData = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _webController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final data = await HistoryService.getUserProfile();
    if (data != null) {
      _profileData = data;
      _nameController.text = data['name'] ?? '';
      _orgController.text = data['org'] ?? '';
      _addressController.text = data['address'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _webController.text = data['web'] ?? '';
      _bioController.text = data['bio'] ?? '';
      _hasProfile = true;
    } else {
      _hasProfile = false;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty &&
        _orgController.text.isEmpty &&
        _addressController.text.isEmpty &&
        _phoneController.text.isEmpty &&
        _emailController.text.isEmpty &&
        _webController.text.isEmpty &&
        _bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in at least one field to generate your QR Code!')),
      );
      return;
    }

    final data = {
      'name': _nameController.text.trim(),
      'org': _orgController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'web': _webController.text.trim(),
      'bio': _bioController.text.trim(),
    };

    await HistoryService.saveUserProfile(data);
    setState(() {
      _profileData = data;
      _hasProfile = true;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('My QR Code generated successfully!')),
    );
  }

  String _generateVCardData() {
    return "BEGIN:VCARD\n"
        "VERSION:3.0\n"
        "FN:${_profileData['name']}\n"
        "ORG:${_profileData['org']}\n"
        "ADR;TYPE=WORK:;;${_profileData['address']};;;;\n"
        "TEL;TYPE=CELL:${_profileData['phone']}\n"
        "EMAIL;TYPE=INTERNET:${_profileData['email']}\n"
        "URL:${_profileData['web']}\n"
        "NOTE:${_profileData['bio']}\n"
        "END:VCARD";
  }

  Future<void> _addContact() async {
    if (_profileData['name'] == null || _profileData['name']!.isEmpty) return;

    final status = await fc.FlutterContacts.permissions.request(fc.PermissionType.readWrite);
    if (status == fc.PermissionStatus.granted) {
      try {
        final newContact = fc.Contact(
          name: fc.Name(first: _profileData['name'] ?? ''),
          phones: _profileData['phone'] != null && _profileData['phone']!.isNotEmpty
              ? [fc.Phone(number: _profileData['phone']!, label: fc.Label(fc.PhoneLabel.mobile))]
              : [],
          emails: _profileData['email'] != null && _profileData['email']!.isNotEmpty
              ? [fc.Email(address: _profileData['email']!, label: fc.Label(fc.EmailLabel.home))]
              : [],
          addresses: _profileData['address'] != null && _profileData['address']!.isNotEmpty
              ? [fc.Address(street: _profileData['address']!, label: fc.Label(fc.AddressLabel.work))]
              : [],
          // v2 কনস্ট্রাক্টরের সঠিক প্যারামিটার 'name' সেট করা হলো
          organizations: _profileData['org'] != null && _profileData['org']!.isNotEmpty
              ? [fc.Organization(name: _profileData['org']!)] 
              : [],
          notes: _profileData['bio'] != null && _profileData['bio']!.isNotEmpty
              ? [fc.Note(note: _profileData['bio']!)]
              : [],
        );
        
        await fc.FlutterContacts.create(newContact);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Contact added successfully to your phone! 🎉'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Failed to add contact: $e'),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access contacts.')),
      );
    }
  }

  Future<void> _openMap() async {
    final String address = _profileData['address'] ?? '';
    if (address.isEmpty) return;
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Google Maps.')),
      );
    }
  }

  Future<void> _makeCall() async {
    final String phone = _profileData['phone'] ?? '';
    if (phone.isEmpty) return;
    final Uri uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail() async {
    final String email = _profileData['email'] ?? '';
    if (email.isEmpty) return;
    final Uri uri = Uri.parse("mailto:$email");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyProfile() {
    final String profileText = "My Profile Details:\n"
        "Name: ${_profileData['name']}\n"
        "Company: ${_profileData['org']}\n"
        "Address: ${_profileData['address']}\n"
        "Phone: ${_profileData['phone']}\n"
        "Email: ${_profileData['email']}\n"
        "Website: ${_profileData['web']}\n"
        "Bio: ${_profileData['bio']}";
    Clipboard.setData(ClipboardData(text: profileText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile details copied to clipboard!')),
    );
  }

  void _saveProfileData() {
    final String rawData = _generateVCardData();
    Clipboard.setData(ClipboardData(text: rawData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile QR raw data (vCard) saved/copied successfully!')),
    );
  }

  void _shareProfile() {
    final String shareText = "My Digital Profile:\n"
        "Name: ${_profileData['name']}\n"
        "Company: ${_profileData['org']}\n"
        "Phone: ${_profileData['phone']}\n"
        "Email: ${_profileData['email']}\n"
        "Website: ${_profileData['web']}\n"
        "Bio: ${_profileData['bio']}";
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_hasProfile && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_hasProfile && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Reset Profile?', style: TextStyle(color: Colors.white)),
                    content: const Text('Are you sure you want to clear your Business Card QR?', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await HistoryService.deleteUserProfile();
                  _nameController.clear();
                  _orgController.clear();
                  _addressController.clear();
                  _phoneController.clear();
                  _emailController.clear();
                  _webController.clear();
                  _bioController.clear();
                  _loadProfile();
                }
              },
            ),
        ],
      ),
      drawer: CustomDrawer(onChangeColor: widget.onChangeColor),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : (!_hasProfile || _isEditing)
              ? _buildProfileForm()
              : _buildDigitalCard(),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge, color: Colors.blue, size: 28),
              SizedBox(width: 10),
              Text('Create Digital Business Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Fill in your details below to generate a smart vCard QR Code. Users can directly scan it to save your info!',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 25),
          _customTextField(_nameController, 'Full Name'),
          _customTextField(_orgController, 'Organization / Job Title'),
          _customTextField(_addressController, 'Address / Location'),
          _customTextField(_phoneController, 'Mobile / Phone', keyboardType: TextInputType.phone),
          _customTextField(_emailController, 'Email Address', keyboardType: TextInputType.emailAddress),
          _customTextField(_webController, 'Website URL', keyboardType: TextInputType.url),
          _customTextField(_bioController, 'About Yourself / Bio', maxLines: 4),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.qr_code_2, color: Colors.white),
              label: const Text('Generate & Save My QR', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel Edit', style: TextStyle(color: Colors.white)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDigitalCard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact', style: TextStyle(color: Colors.white30, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(
            _profileData['name'] ?? '',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (_profileData['org']!.isNotEmpty)
            Text(_profileData['org']!, style: const TextStyle(fontSize: 18, color: Colors.white70)),
          if (_profileData['address']!.isNotEmpty)
            Text(_profileData['address']!, style: const TextStyle(fontSize: 16, color: Colors.white54)),
          if (_profileData['phone']!.isNotEmpty)
            Text(_profileData['phone']!, style: const TextStyle(fontSize: 16, color: Colors.white54)),
          if (_profileData['email']!.isNotEmpty)
            Text(_profileData['email']!, style: const TextStyle(fontSize: 16, color: Colors.white54)),
          if (_profileData['bio']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(_profileData['bio']!, style: const TextStyle(fontSize: 15, color: Colors.white38, fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cardActionItem(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Add contact',
                onTap: _profileData['name']!.isNotEmpty ? _addContact : null,
              ),
              _cardActionItem(
                icon: Icons.location_on_rounded,
                label: 'Show map',
                onTap: _profileData['address']!.isNotEmpty ? _openMap : null,
              ),
              _cardActionItem(
                icon: Icons.phone_in_talk_rounded,
                label: 'Call',
                onTap: _profileData['phone']!.isNotEmpty ? _makeCall : null,
              ),
              _cardActionItem(
                icon: Icons.mail_rounded,
                label: 'Send email',
                onTap: _profileData['email']!.isNotEmpty ? _sendEmail : null,
              ),
            ],
          ),
          const SizedBox(height: 25),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cardActionItem(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: _shareProfile,
              ),
              _cardActionItem(
                icon: Icons.copy_rounded,
                label: 'Copy Info',
                onTap: _copyProfile,
              ),
              _cardActionItem(
                icon: Icons.save_alt_rounded,
                label: 'Save/Copy QR',
                onTap: _saveProfileData,
              ),
            ],
          ),
          
          const SizedBox(height: 40),

          Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: QrImageView(
                data: _generateVCardData(),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _cardActionItem({required IconData icon, required String label, required VoidCallback? onTap}) {
    final bool isEnabled = onTap != null;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 75,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.blueAccent, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customTextField(
    TextEditingController controller, 
    String label, {
    int maxLines = 1, 
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        ),
      ),
    );
  }
}