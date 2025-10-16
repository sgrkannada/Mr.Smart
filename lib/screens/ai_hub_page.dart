import 'package:flutter/material.dart';

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

enum FileType { document, powerpoint, excel }

class AIHubPage extends StatefulWidget {
  const AIHubPage({super.key});

  @override
  State<AIHubPage> createState() => _AIHubPageState();
}

class _AIHubPageState extends State<AIHubPage> {
  final TextEditingController _topicController = TextEditingController();
  FileType? _selectedFileType = FileType.document;
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateFile() async {
    if (_topicController.text.isEmpty || _selectedFileType == null) {
      setState(() {
        _message = 'Please enter a topic and select a file type.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      _isLoading = false;
      _message = 'Successfully generated ${_selectedFileType!.name} for topic: "${_topicController.text}"!';
      _topicController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_message!),
        backgroundColor: neonCyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hub'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Content with AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 5)],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter a topic and let AI create a document, presentation, or spreadsheet for you.',
              style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Topic Input
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter Topic',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'e.g., "Quantum Computing Basics", "Market Analysis for EVs"',
                hintStyle: TextStyle(color: Colors.white54.withAlpha((255 * 0.8).round())),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: neonCyan),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: neonCyan, width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // File Type Selection
            Text(
              'Select Output Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha((255 * 0.8).round()),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<FileType>(
              segments: const [
                ButtonSegment<FileType>(
                  value: FileType.document,
                  label: Text('Document'),
                  icon: Icon(Icons.description_outlined),
                ),
                ButtonSegment<FileType>(
                  value: FileType.powerpoint,
                  label: Text('PowerPoint'),
                  icon: Icon(Icons.slideshow_outlined),
                ),
                ButtonSegment<FileType>(
                  value: FileType.excel,
                  label: Text('Excel'),
                  icon: Icon(Icons.grid_on_outlined),
                ),
              ],
              selected: <FileType>{_selectedFileType!},
              onSelectionChanged: (Set<FileType> newSelection) {
                setState(() {
                  _selectedFileType = newSelection.first;
                });
              },
              style: SegmentedButton.styleFrom(
                foregroundColor: neonCyan,
                selectedForegroundColor: darkBackground,
                selectedBackgroundColor: neonCyan,
                side: const BorderSide(color: neonCyan),
              ),
            ),
            const SizedBox(height: 32),

            // Generate Button
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: neonCyan)
                  : ElevatedButton.icon(
                      onPressed: _generateFile,
                      icon: const Icon(Icons.auto_awesome, color: darkBackground),
                      label: const Text('Generate with AI', style: TextStyle(color: darkBackground)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonCyan,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        _message!,
                        style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
                        textAlign: TextAlign.center,
                        maxLines: 5, // Limit to 5 lines for preview
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Simulating file save/share...')),
                          );
                        },
                        icon: const Icon(Icons.save_alt, color: darkBackground),
                        label: const Text('Save/Share File', style: TextStyle(color: darkBackground)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonCyan,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}