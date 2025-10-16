import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

// Data Model for a Teacher
class Teacher {
  final String id;
  final String name;
  final String subject;

  Teacher({required this.id, required this.name, required this.subject});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subject': subject,
      };

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'],
        name: json['name'],
        subject: json['subject'],
      );
}

// Data Model for an Anonymous Message
class AnonymousMessage {
  final String senderId; // Student's anonymous ID
  final String receiverId; // Teacher's ID
  final String message;
  final DateTime timestamp;

  AnonymousMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AnonymousMessage.fromJson(Map<String, dynamic> json) => AnonymousMessage(
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class AnonymousDoubtPage extends StatefulWidget {
  const AnonymousDoubtPage({super.key});

  @override
  State<AnonymousDoubtPage> createState() => _AnonymousDoubtPageState();
}

class _AnonymousDoubtPageState extends State<AnonymousDoubtPage> {
  Teacher? _selectedTeacher;
  late String _anonymousStudentId; // Unique ID for the anonymous student

  // Simulated list of available teachers
  final List<Teacher> _allTeachers = [
    Teacher(id: 'teacher1', name: 'Prof. Smith', subject: 'Mathematics'),
    Teacher(id: 'teacher2', name: 'Dr. Jones', subject: 'Physics'),
    Teacher(id: 'teacher3', name: 'Ms. Davis', subject: 'Computer Science'),
    Teacher(id: 'teacher4', name: 'Mr. Brown', subject: 'Engineering Drawing'),
  ];

  // Chat messages for anonymous doubts
  Map<String, List<AnonymousMessage>> _anonymousChatMessages = {};
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateAnonymousId();
    _loadAnonymousChatMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _generateAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('anonymous_student_id');
    if (storedId == null) {
      storedId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('anonymous_student_id', storedId);
    }
    setState(() {
      _anonymousStudentId = storedId!;
    });
  }

  // Helper to get chat key for anonymous student and teacher
  String _getChatKey(String studentId, String teacherId) {
    return 'anon_${studentId}_$teacherId';
  }

  Future<void> _loadAnonymousChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? chatMessagesString = prefs.getString('anonymous_chat_messages');
    if (chatMessagesString != null) {
      final Map<String, dynamic> jsonMap = json.decode(chatMessagesString);
      setState(() {
        _anonymousChatMessages = jsonMap.map((key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((msgJson) => AnonymousMessage.fromJson(msgJson)).toList(),
            ));
      });
    }
  }

  Future<void> _saveAnonymousChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonMap = _anonymousChatMessages.map((key, value) => MapEntry(
          key,
          value.map((msg) => msg.toJson()).toList(),
        ));
    final String chatMessagesString = json.encode(jsonMap);
    await prefs.setString('anonymous_chat_messages', chatMessagesString);
  }

  void _sendAnonymousMessage(Teacher teacher, String message) {
    if (message.trim().isEmpty) return;

    final String chatKey = _getChatKey(_anonymousStudentId, teacher.id);
    final AnonymousMessage newMessage = AnonymousMessage(
      senderId: _anonymousStudentId,
      receiverId: teacher.id,
      message: message.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _anonymousChatMessages.putIfAbsent(chatKey, () => []).add(newMessage);
      _messageController.clear();
    });
    _saveAnonymousChatMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message sent to ${teacher.name} (Anonymously)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTeacher == null ? 'Anonymous Doubts' : _selectedTeacher!.name),
        backgroundColor: darkBackground,
        elevation: 0,
        leading: _selectedTeacher != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: neonCyan),
                onPressed: () {
                  setState(() {
                    _selectedTeacher = null;
                  });
                },
              )
            : null,
      ),
      backgroundColor: darkBackground,
      body: _selectedTeacher == null ? _buildTeacherList() : _buildAnonymousChat(_selectedTeacher!),
    );
  }

  Widget _buildTeacherList() {
    return _allTeachers.isEmpty
        ? Center(
            child: Text(
              'No teachers available.',
              style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _allTeachers.length,
            itemBuilder: (context, index) {
              final teacher = _allTeachers[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.person_outline, color: neonCyan),
                  title: Text(teacher.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  subtitle: Text(teacher.subject, style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _selectedTeacher = teacher;
                    });
                  },
                ),
              );
            },
          );
  }

  Widget _buildAnonymousChat(Teacher teacher) {
    final String chatKey = _getChatKey(_anonymousStudentId, teacher.id);
    final List<AnonymousMessage> messages = _anonymousChatMessages[chatKey] ?? [];

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    'Ask your first doubt to ${teacher.name}!',
                    style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // For anonymity, sender is always 'You (Anonymous)'
                    final bool isMe = message.senderId == _anonymousStudentId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe ? neonCyan.withAlpha((255 * 0.8).round()) : cardColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isMe ? neonCyan : Colors.grey).withAlpha((255 * 0.2).round()),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? 'You (Anonymous)' : teacher.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMe ? darkBackground : neonCyan,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isMe ? darkBackground : Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${message.timestamp.hour}:${message.timestamp.minute}',
                              style: TextStyle(
                                color: isMe ? darkBackground.withOpacity(0.7) : Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask your doubt anonymously...',
                    hintStyle: TextStyle(color: Colors.grey.withAlpha((255 * 0.7).round())),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(color: neonCyan, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () => _sendAnonymousMessage(_selectedTeacher!, _messageController.text),
                backgroundColor: neonCyan,
                mini: true,
                child: Icon(Icons.send, color: darkBackground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}