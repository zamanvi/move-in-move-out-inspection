import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class BrandingSettingsScreen extends StatefulWidget {
  const BrandingSettingsScreen({super.key});

  @override
  State<BrandingSettingsScreen> createState() => _BrandingSettingsScreenState();
}

class _BrandingSettingsScreenState extends State<BrandingSettingsScreen> {
  late BrandingSettings _branding;
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _termsController;

  @override
  void initState() {
    super.initState();
    _branding = StorageService.getBranding();
    _nameController = TextEditingController(text: _branding.companyName);
    _contactController = TextEditingController(text: _branding.contactInfo);
    _termsController = TextEditingController(text: _branding.terms);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) setState(() => _branding.logoPath = picked.path);
  }

  Future<void> _save() async {
    _branding.companyName = _nameController.text.trim();
    _branding.contactInfo = _contactController.text.trim();
    _branding.terms = _termsController.text.trim();
    await StorageService.saveBranding(_branding);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Branding'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickLogo,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        _branding.logoPath != null ? FileImage(File(_branding.logoPath!)) : null,
                    child: _branding.logoPath == null ? const Icon(Icons.add_a_photo) : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _branding.logoPath == null ? 'Tap to add your logo' : 'Tap to change logo',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              hintText: 'e.g. Smith Property Inspections',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactController,
            decoration: const InputDecoration(
              labelText: 'Contact Info (phone, email, address)',
              hintText: '(555) 123-4567 · info@company.com',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _termsController,
            decoration: const InputDecoration(
              labelText: 'Report Footer / Terms',
              hintText: 'e.g. This report is valid for 30 days from the inspection date.',
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
