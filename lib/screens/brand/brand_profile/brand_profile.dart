import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mawqif/screens/brand/brand_profile/return_policy.dart';
import '../../../constants/app_colors.dart';
import '../../user/profile/privacy_policy.dart';
import 'package:country_picker/country_picker.dart';

class BrandProfileScreen extends StatefulWidget {
  const BrandProfileScreen({super.key});

  @override
  State<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends State<BrandProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shippingController = TextEditingController();

  Timer? _nameDebounce;
  Timer? _descDebounce;
  Timer? _shipDebounce;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _brandStream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _brandSub;

  String _logoUrl = '';
  bool _loading = true;
  bool _uploadingImage = false;
  int _returnDays = 7;

  @override
  void initState() {
    super.initState();
    _initBrandListener();
    _attachTextListeners();

    _nameController.addListener(() {
      setState(() {});
    });

    // Attach listener for shipping updates
    _shippingController.addListener(() {
      _shipDebounce?.cancel();
      _shipDebounce = Timer(const Duration(seconds: 1), () {
        final ships =
            _shippingController.text
                .split(",")
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
        _updateField('shippingInfo', ships);
      });
    });
  }

  void _initBrandListener() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      Get.offAllNamed('/login');
      return;
    }

    _brandStream = _firestore.collection('brands').doc(uid).snapshots();
    _brandSub = _brandStream!.listen(
      (snapshot) {
        if (!snapshot.exists) {
          setState(() {
            _loading = false;
          });
          return;
        }
        final data = snapshot.data()!;
        if (!_nameFocus.hasFocus) {
          final remoteName = (data['name'] ?? '') as String;
          if (_nameController.text != remoteName) {
            _nameController.text = remoteName;
          }
        }
        if (!_descFocus.hasFocus) {
          final remoteDesc = (data['description'] ?? '') as String;
          if (_descriptionController.text != remoteDesc) {
            _descriptionController.text = remoteDesc;
          }
        }
        if (!_shipFocus.hasFocus) {
          final remoteShipRaw = data['shippingInfo'];
          List<String> remoteShip = [];

          if (remoteShipRaw is String) {
            remoteShip =
                remoteShipRaw
                    .split(",")
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
          } else if (remoteShipRaw is List) {
            remoteShip = remoteShipRaw.map((e) => e.toString()).toList();
          }
          final remoteDays = data['returnDays'];
          if (remoteDays != null &&
              remoteDays is int &&
              remoteDays != _returnDays) {
            setState(() => _returnDays = remoteDays);
          }
        }

        setState(() {
          _logoUrl = (data['logoUrl'] ?? '') as String;
          _loading = false;
        });
      },
      onError: (e) {
        setState(() {
          _loading = false;
        });
        Get.snackbar('Error', 'Failed to load brand data: $e');
      },
    );
  }

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();
  final FocusNode _shipFocus = FocusNode();

  void _attachTextListeners() {
    _nameController.addListener(() {
      _nameDebounce?.cancel();
      _nameDebounce = Timer(const Duration(seconds: 1), () {
        _updateField('name', _nameController.text.trim());
      });
    });

    _descriptionController.addListener(() {
      _descDebounce?.cancel();
      _descDebounce = Timer(const Duration(seconds: 1), () {
        _updateField('description', _descriptionController.text.trim());
      });
    });

    _shippingController.addListener(() {
      _shipDebounce?.cancel();
      _shipDebounce = Timer(const Duration(seconds: 1), () {
        _updateField('shippingInfo', _shippingController.text.trim());
      });
    });
  }

  Future<void> _updateField(String key, dynamic value) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore.collection('brands').doc(uid).update({key: value});
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        e.toString(),
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Select Image Source'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, ImageSource.camera),
                child: const Text('Camera'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, ImageSource.gallery),
                child: const Text('Gallery'),
              ),
            ],
          ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploadingImage = true);

    final file = File(picked.path);
    final ref = _storage
        .ref()
        .child('brand_logos')
        .child(uid)
        .child('logo.jpg');

    try {
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('brands').doc(uid).update({
        'logoUrl': downloadUrl,
      });

      setState(() {
        _logoUrl = downloadUrl;
      });

      Get.snackbar(
        'Success',
        'Logo updated',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Upload failed',
        e.toString(),
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  void dispose() {
    _brandSub?.cancel();
    _nameDebounce?.cancel();
    _descDebounce?.cancel();
    _shipDebounce?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    _shippingController.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    _shipFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final email = _auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Profile',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.brown,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      _logoUrl.isNotEmpty
                          ? NetworkImage(_logoUrl) as ImageProvider
                          : null,
                  child:
                      _logoUrl.isEmpty
                          ? Icon(
                            Icons.store,
                            size: 48,
                            color: Colors.brown.shade400,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _uploadingImage ? null : _pickAndUploadLogo,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBrown,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child:
                          _uploadingImage
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(email, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 18),

            // Editable Name
            _buildLabel('Brand Name'),
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: InputDecoration(
                hintText: 'Brand Name',
                filled: true,
                fillColor: brown20,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Editable Description
            _buildLabel('About (Description)'),
            TextFormField(
              controller: _descriptionController,
              focusNode: _descFocus,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Short description about brand',
                filled: true,
                fillColor: brown20,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Editable Shipping
            _buildLabel('Shipping Info'),
            TextFormField(
              controller: _shippingController,
              focusNode: _shipFocus,
              decoration: InputDecoration(
                hintText: 'Shipping details (e.g. Worldwide)',
                filled: true,
                fillColor: brown20,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLabel('Select Countries (if not Worldwide)'),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    onSelect: (country) {
                      final current =
                          _shippingController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                      if (!current.contains(country.name)) {
                        current.add(country.name);
                        _shippingController.text = current.join(', ');
                      }
                    },
                  );
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text("Add Country"),
              ),
            ),

            const SizedBox(height: 12),
            _buildLabel('Return Policy - Days'),
            DropdownButtonFormField<int>(
              value: _returnDays,
              decoration: InputDecoration(
                filled: true,
                fillColor: brown20,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items:
                  [7, 14, 30, 60, 90]
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e, child: Text('$e days')),
                      )
                      .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() => _returnDays = val);
                final brandName =
                    _nameController.text.trim().isEmpty
                        ? "Your Brand"
                        : _nameController.text.trim();
                final policyText =
                    "All products from $brandName can be returned within $val days of delivery. Please ensure items are unused and in original packaging. Refunds will be processed after inspection.";
                _updateField('returnDays', val);
                _updateField('returnPolicy', policyText);
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReturnPolicyScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.policy, size: 20, color: Colors.white),
                label: const Text(
                  'Return Policy',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.privacy_tip,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Confirm Logout"),
                              content: const Text(
                                "Are you sure you want to log out?",
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColor,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _logout();
                                  },
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Small hint text
                Text(
                  'Changes are saved automatically.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    ),
  );
}
