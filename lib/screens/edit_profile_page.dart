import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    _yearController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('profile_name') ?? 'John Doe';
      _emailController.text = prefs.getString('profile_email') ?? 'john.doe@example.com';
      _majorController.text = prefs.getString('profile_major') ?? 'Computer Engineering';
      _yearController.text = prefs.getString('profile_year') ?? '3rd Year';
      _studentIdController.text = prefs.getString('profile_student_id') ?? '123456789';
      _phoneController.text = prefs.getString('profile_phone') ?? '+1 (555) 123-4567';
      _addressController.text = prefs.getString('profile_address') ?? '123 Engineering Lane, Tech City';
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameController.text);
    await prefs.setString('profile_email', _emailController.text);
    await prefs.setString('profile_major', _majorController.text);
    await prefs.setString('profile_year', _yearController.text);
    await prefs.setString('profile_student_id', _studentIdController.text);
    await prefs.setString('profile_phone', _phoneController.text);
    await prefs.setString('profile_address', _addressController.text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
    Navigator.of(context).pop(); // Go back to profile page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfileData,
            tooltip: 'Save Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Name', Icons.person),
            _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
            _buildTextField(_majorController, 'Major', Icons.school),
            _buildTextField(_yearController, 'Year', Icons.calendar_today),
            _buildTextField(_studentIdController, 'Student ID', Icons.badge),
            _buildTextField(_phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
            _buildTextField(_addressController, 'Address', Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
