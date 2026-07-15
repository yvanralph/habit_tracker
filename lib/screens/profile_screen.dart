import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/tab_app_bar.dart';

/// Profile tab - screen 10 in the design.
/// Shows the user's info and lets them edit their name, phone, and
/// reason for quitting. Email is shown but can't be edited here -
/// changing it needs re-verifying with Firebase, which is a bigger
/// feature for another time.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final snapshot = await _firestore.collection('users').doc(uid).get();
    final data = snapshot.data();

    if (!mounted) return;
    setState(() {
      _nameController.text = data?['fullName'] as String? ?? '';
      _phoneController.text = data?['phone'] as String? ?? '';
      _reasonController.text = data?['reason'] as String? ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();

    await _firestore.collection('users').doc(uid).set({
      'fullName': name,
      'phone': _phoneController.text.trim(),
      'reason': _reasonController.text.trim(),
    }, SetOptions(merge: true));

    await _authService.currentUser?.updateDisplayName(name);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      // No onProfileTap here - you're already on the Profile tab.
      appBar: const TabAppBar(title: 'My Profile'),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: AppColors.fieldFill,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _fieldDecoration(icon: Icons.badge_outlined),
                    ),
                    const SizedBox(height: 18),

                    const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _readOnlyField(value: email, icon: Icons.email_outlined),
                    const SizedBox(height: 18),

                    const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDecoration(icon: Icons.phone_outlined),
                    ),
                    const SizedBox(height: 18),

                    const Text('My Reason', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      decoration: _fieldDecoration(
                        suffixIcon: const Icon(
                          Icons.favorite_outline,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _authService.logout(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warningRed,
                          side: const BorderSide(color: AppColors.warningRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _fieldDecoration({IconData? icon, Widget? suffixIcon}) {
    return InputDecoration(
      prefixIcon: icon == null ? null : Icon(icon, color: AppColors.textGrey),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }

  /// A field that looks like the others but can't be tapped or edited -
  /// used for the email, since changing it needs a bigger re-auth flow.
  Widget _readOnlyField({required String value, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textGrey)),
          ),
        ],
      ),
    );
  }
}
