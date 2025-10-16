import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _notesController = TextEditingController();
  static const String _notesKey = 'user_notes';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notesController.text = prefs.getString(_notesKey) ?? '';
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesKey, _notesController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNotes,
            tooltip: 'Save Notes',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _notesController,
          maxLines: null, // Allows for multiline input
          expands: true, // Allows the TextField to expand vertically
          decoration: const InputDecoration(
            hintText: 'Start writing your notes here...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }
}
