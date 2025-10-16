import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class CodeSandboxPage extends StatefulWidget {
  const CodeSandboxPage({super.key});

  @override
  State<CodeSandboxPage> createState() => _CodeSandboxPageState();
}

class _CodeSandboxPageState extends State<CodeSandboxPage> {
  final TextEditingController _codeController = TextEditingController();
  String _currentLanguage = 'dart'; // Default language

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Sandbox'),
        actions: [
          DropdownButton<String>(
            value: _currentLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentLanguage = newValue;
                });
              }
            },
            items: <String>['dart', 'python', 'java', 'cpp', 'javascript', 'html', 'css']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // TODO: Integrate with AI Assistant
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Send to AI Assistant (Not yet implemented)')),
              );
            },
            tooltip: 'Send to AI Assistant',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: monokaiSublimeTheme['root']?.backgroundColor, // Background from theme
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: HighlightView(
                  _codeController.text.isEmpty ? '// Start coding here...' : _codeController.text,
                  language: _currentLanguage,
                  theme: monokaiSublimeTheme,
                  padding: const EdgeInsets.all(8),
                  textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).cardColor, // Use card color for input area
            child: TextField(
              controller: _codeController,
              maxLines: null, // Allows for multiline input
              decoration: const InputDecoration(
                hintText: 'Enter your code here...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild to update HighlightView
                });
              },
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
