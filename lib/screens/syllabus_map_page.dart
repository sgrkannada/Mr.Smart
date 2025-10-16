import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

// Data model for a Syllabus Entry
class SyllabusEntry {
  String id;
  String disciplineName;
  String subjectName;
  String topics;

  SyllabusEntry({
    required this.id,
    required this.disciplineName,
    required this.subjectName,
    required this.topics,
  });

  // Convert a SyllabusEntry into a Map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'disciplineName': disciplineName,
        'subjectName': subjectName,
        'topics': topics,
      };

  // Construct a SyllabusEntry from a Map.
  factory SyllabusEntry.fromJson(Map<String, dynamic> json) => SyllabusEntry(
        id: json['id'],
        disciplineName: json['disciplineName'],
        subjectName: json['subjectName'],
        topics: json['topics'],
      );
}

class SyllabusMapPage extends StatefulWidget {
  const SyllabusMapPage({super.key});

  @override
  State<SyllabusMapPage> createState() => _SyllabusMapPageState();
}

class _SyllabusMapPageState extends State<SyllabusMapPage> {
  List<SyllabusEntry> _syllabusEntries = [];
  final TextEditingController _disciplineController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSyllabus();
  }

  @override
  void dispose() {
    _disciplineController.dispose();
    _subjectController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _loadSyllabus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? syllabusString = prefs.getString('syllabus_entries');
    if (syllabusString != null) {
      final List<dynamic> jsonList = json.decode(syllabusString);
      setState(() {
        _syllabusEntries = jsonList.map((json) => SyllabusEntry.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveSyllabus() async {
    final prefs = await SharedPreferences.getInstance();
    final String syllabusString = json.encode(_syllabusEntries.map((entry) => entry.toJson()).toList());
    await prefs.setString('syllabus_entries', syllabusString);
  }

  @override
  Widget build(BuildContext context) {
    // Group syllabus entries by discipline
    final Map<String, List<SyllabusEntry>> groupedByDiscipline = {};
    for (var entry in _syllabusEntries) {
      if (!groupedByDiscipline.containsKey(entry.disciplineName)) {
        groupedByDiscipline[entry.disciplineName] = [];
      }
      groupedByDiscipline[entry.disciplineName]!.add(entry);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus Map'),
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
              'Explore Engineering Disciplines',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 5)],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dive into core subjects and key topics across various engineering branches.',
              style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Display dynamically loaded syllabus entries
            if (groupedByDiscipline.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No syllabus entries yet. Tap + to add one!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ...groupedByDiscipline.keys.map((disciplineName) {
              final subjects = groupedByDiscipline[disciplineName]!;
              // For now, just use a generic icon and color. Later, we can allow users to pick.
              final IconData disciplineIcon = Icons.category_outlined;
              final Color disciplineColor = neonCyan; // Default color

              return _buildDisciplineCard(
                disciplineName,
                disciplineIcon,
                disciplineColor,
                subjects,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSyllabusDialog(),
        backgroundColor: neonCyan,
        child: const Icon(Icons.add, color: darkBackground),
      ),
    );
  }

  Widget _buildDisciplineCard(
    String disciplineName,
    IconData disciplineIcon,
    Color disciplineColor,
    List<SyllabusEntry> subjects,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: disciplineColor.withAlpha((255 * 0.6).round()), width: 1.5),
      ),
      elevation: 5,
      shadowColor: disciplineColor.withAlpha((255 * 0.3).round()),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(disciplineIcon, color: disciplineColor, size: 30),
        title: Text(
          disciplineName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: disciplineColor, blurRadius: 5)],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: subjects.map((subject) => _buildSubjectTile(subject, disciplineColor)).toList(),
      ),
    );
  }

  Widget _buildSubjectTile(SyllabusEntry subject, Color parentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: parentColor.withAlpha((255 * 0.5).round()), blurRadius: 2)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                onPressed: () => _showAddEditSyllabusDialog(entryToEdit: subject),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDeleteSyllabusEntry(subject),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subject.topics,
            style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 14),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(color: Colors.white10, height: 16),
        ],
      ),
    );
  }

  // Dialog for adding/editing syllabus entries
  Future<void> _showAddEditSyllabusDialog({SyllabusEntry? entryToEdit}) async {
    final bool isEditing = entryToEdit != null;
    final formKey = GlobalKey<FormState>();

    if (isEditing) {
      _disciplineController.text = entryToEdit.disciplineName;
      _subjectController.text = entryToEdit.subjectName;
      _topicsController.text = entryToEdit.topics;
    } else {
      _disciplineController.clear();
      _subjectController.clear();
      _topicsController.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text(isEditing ? 'Edit Syllabus Entry' : 'Add New Syllabus Entry', style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _disciplineController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Discipline Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
                      errorStyle: TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a discipline name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _subjectController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Subject Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
                      errorStyle: TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a subject name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _topicsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Topics (comma-separated)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
                      errorStyle: TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter topics';
                      }
                      return null;
                    },
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: neonCyan)),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final String discipline = _disciplineController.text.trim();
                  final String subject = _subjectController.text.trim();
                  final String topics = _topicsController.text.trim();

                  setState(() {
                    if (isEditing) {
                      entryToEdit.disciplineName = discipline;
                      entryToEdit.subjectName = subject;
                      entryToEdit.topics = topics;
                    } else {
                      _syllabusEntries.add(SyllabusEntry(
                        id: DateTime.now().toIso8601String(), // Unique ID
                        disciplineName: discipline,
                        subjectName: subject,
                        topics: topics,
                      ));
                    }
                  });
                  _saveSyllabus();
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Save' : 'Add', style: const TextStyle(color: neonCyan)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteSyllabusEntry(SyllabusEntry entry) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Delete Syllabus Entry', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete "${entry.subjectName}"?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: neonCyan)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteSyllabusEntry(entry);
    }
  }

  void _deleteSyllabusEntry(SyllabusEntry entry) {
    setState(() {
      _syllabusEntries.removeWhere((e) => e.id == entry.id);
    });
    _saveSyllabus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${entry.subjectName}" deleted.', style: const TextStyle(color: darkBackground)),
        backgroundColor: neonCyan,
      ),
    );
  }
}
