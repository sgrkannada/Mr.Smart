import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bro/utils/update_service.dart';

// Theme constants
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F); // Consistent card color

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color _currentAccentColor = neonCyan; // Default color
  String? _geminiApiKey;
  final TextEditingController _geminiApiKeyController = TextEditingController();

  final List<String> _geminiModels = ['gemini-pro', 'gemini-pro-vision']; // Available Gemini models
  String? _selectedGeminiModel; // Currently selected Gemini model

  final List<Color> _neonColors = [
    neonCyan, // Original Neon Cyan
    const Color(0xFFFF073A), // Neon Red/Pink
    const Color(0xFF00FF00), // Neon Green
    const Color(0xFFFEF44C), // Neon Yellow
    const Color(0xFF00FFFF), // Neon Aqua
    const Color(0xFFEE82EE), // Violet
    const Color(0xFF00BFFF), // Deep Sky Blue
    const Color(0xFFFFA500), // Neon Orange
    const Color(0xFF8A2BE2), // Blue Violet
    const Color(0xFF39FF14), // Electric Green
  ];

  @override
  void initState() {
    super.initState();
    _loadAccentColor();
    _loadGeminiApiKey();
    _loadGeminiModel();
  }

  @override
  void dispose() {
    _geminiApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt('accent_color');
    if (colorValue != null) {
      setState(() {
        _currentAccentColor = Color(colorValue);
      });
    }
  }

  Future<void> _saveAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.value);
    setState(() {
      _currentAccentColor = color;
    });
    // Optionally, trigger a rebuild of the entire app to apply the theme change
    // This might require a more complex state management solution or a global key.
  }

  Future<void> _loadGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _geminiApiKey = prefs.getString('gemini_api_key');
      _geminiApiKeyController.text = _geminiApiKey ?? '';
    });
  }

  Future<void> _saveGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final String newKey = _geminiApiKeyController.text.trim();
    if (newKey.isNotEmpty) {
      await prefs.setString('gemini_api_key', newKey);
      setState(() {
        _geminiApiKey = newKey;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API Key saved!')),
      );
    } else {
      await prefs.remove('gemini_api_key');
      setState(() {
        _geminiApiKey = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API Key cleared!')),
      );
    }
  }

  Future<void> _loadGeminiModel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGeminiModel = prefs.getString('gemini_model') ?? _geminiModels.first;
    });
  }

  Future<void> _saveGeminiModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_model', model);
    setState(() {
      _selectedGeminiModel = model;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gemini Model set to $model')),
    );
  }

  Future<void> _resetAISettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gemini_api_key');
    await prefs.remove('gemini_model');
    setState(() {
      _geminiApiKey = null;
      _geminiApiKeyController.clear();
      _selectedGeminiModel = _geminiModels.first;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Settings reset to default!')),
    );
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Accent Color'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _neonColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    _saveAccentColor(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentAccentColor == color ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: neonCyan, blurRadius: 8)],
        )),
        backgroundColor: darkBackground,
        iconTheme: const IconThemeData(color: neonCyan),
      ),
      backgroundColor: darkBackground,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          _buildSettingsSection(
            context,
            title: 'Appearance',
            items: [
              _buildNeonListTile(
                icon: Icons.brightness_6_outlined,
                title: 'Theme Mode',
                subtitle: 'Dark/Neon (Current)',
                onTap: () {
                  // TODO: Implement theme switching logic
                },
              ),
              _buildNeonDivider(),
              _buildNeonListTile(
                icon: Icons.color_lens_outlined,
                title: 'Accent Color',
                subtitle: 'Current: ${(_currentAccentColor.value & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}',
                onTap: () {
                  _showColorPickerDialog();
                },
              ),
            ],
          ),
          
          _buildSectionSpacing(),

          _buildSettingsSection(
            context,
            title: 'AI Settings',
            items: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gemini API Key',
                      style: TextStyle(
                        color: Colors.white.withAlpha((255 * 0.8).round()),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _geminiApiKeyController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Enter Gemini API Key',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: neonCyan),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: neonCyan, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () => _geminiApiKeyController.clear(),
                        ),
                      ),
                      obscureText: true, // Hide API key
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveGeminiApiKey,
                        icon: const Icon(Icons.save, color: darkBackground),
                        label: const Text('Save API Key', style: TextStyle(color: darkBackground)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonCyan,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    if (_geminiApiKey != null && _geminiApiKey!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'API Key is currently set.',
                          style: TextStyle(color: Colors.greenAccent[400], fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'AI Model Selection',
                      style: TextStyle(
                        color: Colors.white.withAlpha((255 * 0.8).round()),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: darkBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: neonCyan.withAlpha((255 * 0.2).round()),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedGeminiModel,
                          hint: const Text('Select AI Model', style: TextStyle(color: Colors.white70)),
                          icon: const Icon(Icons.arrow_drop_down, color: neonCyan),
                          dropdownColor: cardColor, // Use cardColor for dropdown background
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _saveGeminiModel(newValue);
                            }
                          },
                          items: _geminiModels.map<DropdownMenuItem<String>>((String model) {
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _resetAISettings,
                        icon: const Icon(Icons.restore, color: darkBackground),
                        label: const Text('Reset AI Settings', style: TextStyle(color: darkBackground)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          _buildSectionSpacing(),

          _buildSettingsSection(
            context,
            title: 'Account',
            items: [
              _buildNeonListTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: Navigate to profile edit screen
                },
              ),
              _buildNeonDivider(),
              _buildNeonListTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {},
              ),
              _buildNeonDivider(),
              _buildNeonListTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                trailing: Switch(
                  value: true, // Placeholder for state
                  onChanged: (bool value) {
                    // TODO: Update notification settings
                  },
                  activeThumbColor: neonCyan,
                ),
                onTap: () {},
              ),
            ],
          ),

          _buildSectionSpacing(),

          _buildSettingsSection(
            context,
            title: 'App Info',
            items: [
              _buildNeonListTile(
                icon: Icons.info_outline,
                title: 'About Smart-Bro',
                onTap: () {
                  // TODO: Show version info, credits
                },
              ),
              _buildNeonDivider(),
              _buildNeonListTile(
                icon: Icons.gavel_outlined,
                title: 'Terms and Privacy',
                onTap: () {},
              ),
              _buildNeonDivider(),
              _buildNeonListTile(
                icon: Icons.system_update_alt_outlined,
                title: 'Check for Updates',
                onTap: () async {
                  final updateService = UpdateService();
                  await updateService.checkForUpdate(onStatus: (status) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(status)),
                    );
                  });
                },
              ),
            ],
          ),

          _buildSectionSpacing(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 18)),
              onPressed: () {
                // TODO: Implement actual logout and navigate back to LoginPage
                Navigator.of(context).pop(); // Dummy action
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: neonCyan.withAlpha((255 * 0.8).round()), // Fixed withOpacity
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255 * 0.05).round()), // Fixed withOpacity
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: neonCyan.withAlpha((255 * 0.3).round())),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  // Helper widget for consistent ListTile style
  Widget _buildNeonListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: neonCyan),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade400)) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  // Helper widget for consistent section spacing
  Widget _buildSectionSpacing() {
    return const SizedBox(height: 24);
  }

  // Helper widget for consistent divider style
  Widget _buildNeonDivider() {
    return Divider(height: 1, color: neonCyan.withAlpha((255 * 0.1).round())); // Fixed withOpacity
  }
}