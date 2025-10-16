import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

class FlowPage extends StatefulWidget {
  const FlowPage({super.key});

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  bool _isClipboardSyncEnabled = false;
  String _deviceClipboardContent = 'No content';
  final String _computerClipboardContent = 'Simulated computer clipboard content'; // Simulated
  String? _selectedFileName;
  bool _isInternetSyncMode = true; // true for Internet, false for Local WiFi

  // Whiteboard simulation
  final List<String> _whiteboardElements = [];
  final TextEditingController _whiteboardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClipboardSyncState();
    _readDeviceClipboard();
  }

  @override
  void dispose() {
    _whiteboardController.dispose();
    super.dispose();
  }

  Future<void> _loadClipboardSyncState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isClipboardSyncEnabled = prefs.getBool('isClipboardSyncEnabled') ?? false;
    });
  }

  Future<void> _saveClipboardSyncState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isClipboardSyncEnabled', value);
  }

  Future<void> _readDeviceClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _deviceClipboardContent = clipboardData.text!;
      });
    } else {
      setState(() {
        _deviceClipboardContent = 'No content';
      });
    }
  }

  Future<void> _syncClipboard() async {
    if (!_isClipboardSyncEnabled) return;

    // Simulate syncing: device to computer, then computer to device
    // In a real scenario, this would involve network communication

    // Device to Computer
    await Clipboard.setData(ClipboardData(text: _computerClipboardContent));
    await _readDeviceClipboard(); // Update device clipboard content display

    // Computer to Device (simulated)
    // For now, let's just update the device clipboard with the simulated computer content
    // A real implementation would involve receiving content from the computer
    setState(() {
      _deviceClipboardContent = _computerClipboardContent;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clipboard synced! (Simulated)')),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File selected: $_selectedFileName (Ready to share)')),
      );
    } else {
      // User canceled the picker
      debugPrint('File picking cancelled');
    }
  }

  void _addWhiteboardElement() {
    if (_whiteboardController.text.isNotEmpty) {
      setState(() {
        _whiteboardElements.add(_whiteboardController.text);
        _whiteboardController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Element added (simulated real-time sync)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow (Collaboration & Sync)'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collaborative Whiteboard Section
            Text(
              'Collaborative Whiteboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    'Add ideas, diagrams, or notes in real-time (simulated).',
                    style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round())),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _whiteboardController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Add element (text/shape idea)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: neonCyan),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: neonCyan, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addWhiteboardElement,
                      icon: const Icon(Icons.add_chart, color: darkBackground),
                      label: const Text('Add Element', style: TextStyle(color: darkBackground)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonCyan,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Elements:',
                    style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round())),
                  ),
                  ..._whiteboardElements.map((element) => Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                    child: Text('- $element', style: const TextStyle(color: Colors.white)),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // File Sharing Section
            Text(
              'File Sharing & Sync',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sync Mode:',
                        style: TextStyle(color: Colors.white.withAlpha((255 * 0.8).round()), fontSize: 16),
                      ),
                      Switch(
                        value: _isInternetSyncMode,
                        onChanged: (bool value) {
                          setState(() {
                            _isInternetSyncMode = value;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(value ? 'Internet Sync Mode' : 'Local WiFi Sync Mode')),
                          );
                        },
                        activeThumbColor: neonCyan,
                      ),
                      Text(
                        _isInternetSyncMode ? 'Internet' : 'Local WiFi',
                        style: TextStyle(color: neonCyan, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Share files between your device and computer.',
                    style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round())),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file, color: darkBackground),
                    label: const Text('Select File to Share', style: TextStyle(color: darkBackground)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonCyan,
                    ),
                  ),
                  if (_selectedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Selected: $_selectedFileName (Simulated transfer)',
                        style: TextStyle(color: Colors.white.withAlpha((255 * 0.8).round())),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sending file via ${_isInternetSyncMode ? 'Internet' : 'Local WiFi'} (Simulated)')),
                            );
                          },
                          icon: const Icon(Icons.send, color: darkBackground),
                          label: const Text('Send File', style: TextStyle(color: darkBackground)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonCyan,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Receiving file via ${_isInternetSyncMode ? 'Internet' : 'Local WiFi'} (Simulated)')),
                            );
                          },
                          icon: const Icon(Icons.download, color: darkBackground),
                          label: const Text('Receive File', style: TextStyle(color: darkBackground)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Clipboard Sync Section
            Text(
              'Clipboard Sync',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enable Clipboard Sync',
                        style: TextStyle(color: Colors.white.withAlpha((255 * 0.8).round()), fontSize: 16),
                      ),
                      Switch(
                        value: _isClipboardSyncEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _isClipboardSyncEnabled = value;
                          });
                          _saveClipboardSyncState(value);
                          if (value) {
                            _syncClipboard(); // Initial sync when enabled
                          }
                        },
                        activeThumbColor: neonCyan,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Device Clipboard:',
                    style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round())),
                  ),
                  Text(
                    _deviceClipboardContent,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Simulated Computer Clipboard:',
                    style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round())),
                  ),
                  Text(
                    _computerClipboardContent,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded( // Added Expanded
                        child: ElevatedButton.icon(
                          onPressed: _isClipboardSyncEnabled ? _readDeviceClipboard : null,
                          icon: const Icon(Icons.copy, color: darkBackground),
                          label: const Text('Read Device Clipboard', style: TextStyle(color: darkBackground)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonCyan,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Added SizedBox for spacing
                      Expanded( // Added Expanded
                        child: ElevatedButton.icon(
                          onPressed: _isClipboardSyncEnabled ? _syncClipboard : null,
                          icon: const Icon(Icons.sync, color: darkBackground),
                          label: const Text('Sync Now', style: TextStyle(color: darkBackground)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}