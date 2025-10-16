import 'dart:convert';
// For File class
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

// Model for a study document
class StudyDocument {
  final String id;
  String name;
  final String type; // 'file' or 'note'
  final String? filePath; // Nullable for notes
  String? content; // Nullable for files, stores note content
  final DateTime uploadDate;
  bool isRecentlyOpened;
  final Color color; // Neon color for the card

  StudyDocument({
    required this.id,
    required this.name,
    required this.type,
    this.filePath,
    this.content,
    required this.uploadDate,
    this.isRecentlyOpened = false,
    required this.color,
  });

  // Convert a StudyDocument object into a Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'filePath': filePath,
        'content': content,
        'uploadDate': uploadDate.toIso8601String(),
        'isRecentlyOpened': isRecentlyOpened,
        'color': color.value, // Store color as int
      };

  // Create a StudyDocument object from a Map
  factory StudyDocument.fromJson(Map<String, dynamic> json) => StudyDocument(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        filePath: json['filePath'],
        content: json['content'],
        uploadDate: DateTime.parse(json['uploadDate']),
        isRecentlyOpened: json['isRecentlyOpened'],
        color: Color(json['color']), // Recreate Color from int
      );
}

// Note Editor Page (will be created as a separate file later)
class NoteEditorPage extends StatefulWidget {
  final StudyDocument document;
  final Function(String) onSave;

  const NoteEditorPage({
    super.key,
    required this.document,
    required this.onSave,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.document.content);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        backgroundColor: darkBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(_textEditingController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      backgroundColor: darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textEditingController,
          maxLines: null, // Allows unlimited lines
          expands: true, // Fills available vertical space
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Start typing your notes here...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none, // Remove default border
          ),
          cursorColor: neonCyan,
        ),
      ),
    );
  }
}

class StudyMaterialPage extends StatefulWidget {
  const StudyMaterialPage({super.key});

  @override
  State<StudyMaterialPage> createState() => _StudyMaterialPageState();
}

class _StudyMaterialPageState extends State<StudyMaterialPage> with TickerProviderStateMixin {
  List<StudyDocument> _documents = [];
  final Uuid _uuid = const Uuid();
  final List<Color> _neonColors = [
    neonCyan,
    const Color(0xFF39FF14), // Neon Green
    const Color(0xFFFF073A), // Neon Red/Pink
    const Color(0xFFFEF44C), // Neon Yellow
    const Color(0xFF00FFFF), // Neon Aqua
    const Color(0xFFEE82EE), // Violet
    const Color(0xFF00FF00), // Lime
    const Color(0xFFFFD700), // Gold
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? documentsString = prefs.getString('studyDocuments');
    if (documentsString != null) {
      final List<dynamic> jsonList = jsonDecode(documentsString);
      setState(() {
        _documents = jsonList.map((json) => StudyDocument.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final String documentsString = jsonEncode(_documents.map((doc) => doc.toJson()).toList());
    await prefs.setString('studyDocuments', documentsString);
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Allow any file type
    );

    if (result != null && result.files.single.path != null) {
      final String filePath = result.files.single.path!;
      final String fileName = result.files.single.name;

      // Check if a document with the same file path already exists
      if (_documents.any((doc) => doc.filePath == filePath)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This document has already been uploaded!')),
          );
        }
        return;
      }

      final newDocument = StudyDocument(
        id: _uuid.v4(),
        name: fileName,
        type: 'file', // Explicitly set type as file
        filePath: filePath,
        uploadDate: DateTime.now(),
        color: _neonColors[_documents.length % _neonColors.length], // Cycle through neon colors
      );

      setState(() {
        _documents.add(newDocument);
      });
      await _saveDocuments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded: ${newDocument.name}')),
        );
      }
    } else {
      // User canceled the picker
      debugPrint('File picking cancelled');
    }
  }

  Future<void> _createNote() async {
    final newDocument = StudyDocument(
      id: _uuid.v4(),
      name: 'New Note ${DateTime.now().millisecondsSinceEpoch}', // Default name
      type: 'note',
      uploadDate: DateTime.now(),
      content: '', // Empty content initially
      color: _neonColors[_documents.length % _neonColors.length],
    );

    setState(() {
      _documents.add(newDocument);
    });
    await _saveDocuments();
    if (mounted) {
      // Open the new note for editing immediately
      _openDocument(newDocument);
    }
  }

  void _deleteDocument(String id) {
    setState(() {
      _documents.removeWhere((doc) => doc.id == id);
    });
    _saveDocuments();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document deleted.')),
    );
  }

  Future<void> _renameDocument(StudyDocument document) async {
    final TextEditingController renameController = TextEditingController(text: document.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: renameController,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (renameController.text.isNotEmpty) {
                setState(() {
                  document.name = renameController.text;
                });
                _saveDocuments();
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _openDocument(StudyDocument document) async {
    setState(() {
      // Mark all as not recently opened, then mark the current one
      for (var doc in _documents) {
        doc.isRecentlyOpened = false;
      }
      document.isRecentlyOpened = true;
    });
    await _saveDocuments();

    if (document.type == 'note') {
      // Open note editor
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditorPage(
            document: document,
            onSave: (updatedContent) {
              setState(() {
                document.content = updatedContent;
              });
              _saveDocuments();
            },
          ),
        ),
      );
      // After returning from editor, refresh state to reflect changes
      setState(() {});
    } else {
      // TODO: Implement actual file opening logic based on platform
      // For now, just show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening ${document.name} (simulated)')),
        );
      }
      debugPrint('Attempting to open file: ${document.filePath}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Material'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: _documents.isEmpty
          ? const Center(
              child: Text(
                'No study materials yet. Upload some or create a note!',
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                return _buildDocumentCard(document);
              },
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _createNote,
            label: const Text('Create Note'),
            icon: const Icon(Icons.note_add),
            backgroundColor: neonCyan,
            foregroundColor: darkBackground,
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: _pickAndUploadFile,
            label: const Text('Upload Document'),
            icon: const Icon(Icons.upload_file),
            backgroundColor: neonCyan,
            foregroundColor: darkBackground,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDocumentCard(StudyDocument document) {
    return GestureDetector(
      onTap: () => _openDocument(document),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: document.color.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: document.color.withOpacity(0.3),
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
                Expanded(
                  child: Text(
                    document.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: document.color, blurRadius: 5)],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (document.isRecentlyOpened)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.circle, color: Colors.greenAccent, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (document.type == 'note' && document.content != null && document.content!.isNotEmpty)
              Text(
                document.content!,
                style: TextStyle(color: Colors.white70.withOpacity(0.8), fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ) else if (document.type == 'file')
              Text(
                'Uploaded: ${document.uploadDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.white70.withOpacity(0.8), fontSize: 12),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: document.color),
                  onPressed: () => _renameDocument(document),
                  tooltip: 'Rename',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteDocument(document.id),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}