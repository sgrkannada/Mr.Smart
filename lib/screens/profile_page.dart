import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bro/screens/edit_profile_page.dart';
import 'package:smart_bro/utils/points_manager.dart'; // Import PointsManager

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'John Doe';
  String _email = 'john.doe@example.com';
  String _major = 'Computer Engineering';
  String _year = '3rd Year';
  String _studentId = '123456789';
  String _phone = '+1 (555) 123-4567';
  String _address = '123 Engineering Lane, Tech City';
  int _userPoints = 0; // User points for gamification

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadUserPoints();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('profile_name') ?? 'John Doe';
      _email = prefs.getString('profile_email') ?? 'john.doe@example.com';
      _major = prefs.getString('profile_major') ?? 'Computer Engineering';
      _year = prefs.getString('profile_year') ?? '3rd Year';
      _studentId = prefs.getString('profile_student_id') ?? '123456789';
      _phone = prefs.getString('profile_phone') ?? '+1 (555) 123-4567';
      _address = prefs.getString('profile_address') ?? '123 Engineering Lane, Tech City';
    });
  }

  Future<void> _loadUserPoints() async {
    final points = await PointsManager.loadUserPoints();
    setState(() {
      _userPoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: neonCyan.withAlpha((255 * 0.2).round()),
                    child: Icon(Icons.person, size: 80, color: neonCyan),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name, // User Name from state
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: neonCyan, blurRadius: 5)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _email, // User Email from state
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70.withAlpha((255 * 0.8).round()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfilePage()),
                      );
                      _loadProfileData(); // Reload data after returning from edit page
                    },
                    icon: const Icon(Icons.edit, color: darkBackground),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonCyan,
                      foregroundColor: darkBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              title: 'Academic Information',
              icon: Icons.school_outlined,
              children: [
                _buildInfoRow('Major:', _major),
                _buildInfoRow('Year:', _year),
                _buildInfoRow('Student ID:', _studentId),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Contact Information',
              icon: Icons.contact_mail_outlined,
              children: [
                _buildInfoRow('Phone:', _phone),
                _buildInfoRow('Address:', _address),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Gamification',
              icon: Icons.star_outline,
              children: [
                _buildInfoRow('Total Points:', '_userPoints.toString()'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 1),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withAlpha((255 * 0.3).round()),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: neonCyan, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}