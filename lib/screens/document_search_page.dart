
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class DocumentSearchPage extends StatefulWidget {
  const DocumentSearchPage({super.key});

  @override
  State<DocumentSearchPage> createState() => _DocumentSearchPageState();
}

class _DocumentSearchPageState extends State<DocumentSearchPage> {
  String? _filePath;
  String _searchQuery = '';
  String _searchResult = '';
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _searchContent() async {
    if (_filePath == null || _searchQuery.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Note: Reading file content and handling different file types (txt, pdf)
      // would require more complex logic. For this example, we'll simulate it.
      // In a real implementation, you would use packages like `pdf_text` to extract text from PDFs.
      final fileContent = await _readFileContent(_filePath!);

      final response = await Gemini.instance.text(
        'Search the following document for information about "$_searchQuery":\n\n$fileContent',
      );

      setState(() {
        _searchResult = response?.output ?? 'No results found.';
      });
    } catch (e) {
      setState(() {
        _searchResult = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _readFileContent(String path) async {
    // This is a simplified file reading logic.
    // For a real app, you would need to handle different file types and encodings.
    // For example, use a PDF parsing library for PDF files.
    if (path.endsWith('.pdf')) {
      // In a real app, use a package like `pdf_text` to extract text.
      return 'This is a simulated PDF content. In a real app, you would extract the text from the PDF file.';
    } else {
      // For .txt and .md files
      final file = File(path);
      return await file.readAsString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Document Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Select Document'),
            ),
            if (_filePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Selected file: $_filePath'),
              ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search Query',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchContent,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Search'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_searchResult),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

