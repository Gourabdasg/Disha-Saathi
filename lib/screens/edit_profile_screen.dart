import 'dart:convert';
import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  String? _selectedImageBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().profile;
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    if (profile.photoUrl.isNotEmpty) {
      _selectedImageBase64 = profile.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;

        if (bytes == null && file.path != null && file.path!.isNotEmpty) {
          try {
            final ioFile = File(file.path!);
            bytes = await ioFile.readAsBytes();
          } catch (_) {}
        }

        if (bytes != null && bytes.isNotEmpty) {
          final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
          setState(() {
            _selectedImageBase64 = base64Image;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not pick image. Please try again.')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    final state = context.read<AppState>();
    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final profile = state.profile;
    profile.name = newName;
    profile.bio = newBio;
    if (_selectedImageBase64 != null) {
      profile.photoUrl = _selectedImageBase64!;
    }

    state.name = newName;
    final success = await state.updateUserProfile(profile);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! 🎉'),
            backgroundColor: AppColors.teal,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Could not save profile changes. Saved locally.'),
            backgroundColor: AppColors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildAvatarWidget(UserProfile profile) {
    if (_selectedImageBase64 != null && _selectedImageBase64!.startsWith('data:image')) {
      try {
        final base64Str = _selectedImageBase64!.split(',').last;
        final bytes = base64Decode(base64Str);
        return CircleAvatar(
          radius: 54,
          backgroundColor: AppColors.bgLight,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    } else if (profile.photoUrl.isNotEmpty && profile.photoUrl.startsWith('http')) {
      return CircleAvatar(
        radius: 54,
        backgroundColor: AppColors.bgLight,
        backgroundImage: NetworkImage(profile.photoUrl),
      );
    }

    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: 54,
      backgroundColor: AppColors.navy,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Photo Card Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _buildAvatarWidget(profile),
                        InkWell(
                          onTap: _pickProfileImage,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: _pickProfileImage,
                      icon: const Icon(Icons.photo_library_rounded, color: AppColors.navy, size: 18),
                      label: const Text('Upload / Change Photo', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Edit Name & Bio Form Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FULL NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.navy),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.bgLight,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text('BIO / PERSONAL DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a short bio or career summary (e.g. Aspiring Data Analyst passionate about AI & Skilling)...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.bgLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Changes Button
              GradientButton(
                label: _isSaving ? 'Saving Changes...' : 'Save Changes',
                onPressed: _isSaving ? null : _saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
