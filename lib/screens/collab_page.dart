import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

// Data Model for a Collab User (Simulated)
class CollabUser {
  final String id;
  final String name;
  final String usn; // University Serial Number

  CollabUser({required this.id, required this.name, required this.usn});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'usn': usn,
      };

  factory CollabUser.fromJson(Map<String, dynamic> json) => CollabUser(
        id: json['id'],
        name: json['name'],
        usn: json['usn'],
      );
}

// Data Model for a Collab Group
class CollabGroup {
  String id;
  String name;
  List<String> memberIds; // Store member IDs

  CollabGroup({required this.id, required this.name, required this.memberIds});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'memberIds': memberIds,
      };

  factory CollabGroup.fromJson(Map<String, dynamic> json) => CollabGroup(
        id: json['id'],
        name: json['name'],
        memberIds: List<String>.from(json['memberIds']),
      );
}

// Data Model for a Chat Message
class ChatMessage {
  final String senderUsn;
  final String receiverUsn;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.senderUsn,
    required this.receiverUsn,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'senderUsn': senderUsn,
        'receiverUsn': receiverUsn,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        senderUsn: json['senderUsn'],
        receiverUsn: json['receiverUsn'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class CollabPage extends StatefulWidget {
  const CollabPage({super.key});

  @override
  State<CollabPage> createState() => _CollabPageState();
}

class _CollabPageState extends State<CollabPage> {
  List<CollabGroup> _groups = [];
  CollabGroup? _selectedGroup;
  CollabUser? _selectedChatUser; // For individual chat

  // Simulated list of available users
  final List<CollabUser> _allUsers = [
    CollabUser(id: 'user1', name: 'Alice', usn: 'USN001'),
    CollabUser(id: 'user2', name: 'Bob', usn: 'USN002'),
    CollabUser(id: 'user3', name: 'Charlie', usn: 'USN003'),
    CollabUser(id: 'user4', name: 'David', usn: 'USN004'),
    CollabUser(id: 'user5', name: 'Eve', usn: 'USN005'),
  ];

  // Current user (for sending messages)
  late CollabUser _currentUser;

  // Chat messages for individual chats
  Map<String, List<ChatMessage>> _individualChatMessages = {};
  final TextEditingController _individualMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = _allUsers.first; // Assume the first user is the current user
    _loadGroups();
    _loadIndividualChatMessages();
  }

  @override
  void dispose() {
    _individualMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? groupsString = prefs.getString('collab_groups');
    if (groupsString != null) {
      final List<dynamic> jsonList = json.decode(groupsString);
      setState(() {
        _groups = jsonList.map((json) => CollabGroup.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final String groupsString = json.encode(_groups.map((group) => group.toJson()).toList());
    await prefs.setString('collab_groups', groupsString);
  }

  // Helper to get chat key for two USNs
  String _getChatKey(String usn1, String usn2) {
    final sortedUsns = [usn1, usn2]..sort();
    return sortedUsns.join('_');
  }

  Future<void> _loadIndividualChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? chatMessagesString = prefs.getString('individual_chat_messages');
    if (chatMessagesString != null) {
      final Map<String, dynamic> jsonMap = json.decode(chatMessagesString);
      setState(() {
        _individualChatMessages = jsonMap.map((key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((msgJson) => ChatMessage.fromJson(msgJson)).toList(),
            ));
      });
    }
  }

  Future<void> _saveIndividualChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonMap = _individualChatMessages.map((key, value) => MapEntry(
          key,
          value.map((msg) => msg.toJson()).toList(),
        ));
    final String chatMessagesString = json.encode(jsonMap);
    await prefs.setString('individual_chat_messages', chatMessagesString);
  }

  void _sendIndividualMessage(CollabUser receiver, String message) {
    if (message.trim().isEmpty) return;

    final String chatKey = _getChatKey(_currentUser.usn, receiver.usn);
    final ChatMessage newMessage = ChatMessage(
      senderUsn: _currentUser.usn,
      receiverUsn: receiver.usn,
      message: message.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _individualChatMessages.putIfAbsent(chatKey, () => []).add(newMessage);
      _individualMessageController.clear();
    });
    _saveIndividualChatMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message sent to ${receiver.name} (Simulated)')),
    );
  }

  void _createGroup(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _groups.add(CollabGroup(id: DateTime.now().toIso8601String(), name: name, memberIds: []));
    });
    _saveGroups();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group "$name" created!')),
    );
  }

  void _deleteGroup(CollabGroup group) {
    setState(() {
      _groups.removeWhere((g) => g.id == group.id);
      if (_selectedGroup?.id == group.id) {
        _selectedGroup = null;
      }
    });
    _saveGroups();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group "${group.name}" deleted!')),
    );
  }

  void _addMemberToGroup(CollabGroup group, CollabUser user) {
    setState(() {
      if (!group.memberIds.contains(user.id)) {
        group.memberIds.add(user.id);
      }
    });
    _saveGroups();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.name} added to ${group.name}!')),
    );
  }

  void _removeMemberFromGroup(CollabGroup group, String userId) {
    setState(() {
      group.memberIds.remove(userId);
    });
    _saveGroups();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Member removed from ${group.name}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedGroup == null
              ? (_selectedChatUser == null ? 'Collab Hub' : _selectedChatUser!.name)
              : _selectedGroup!.name,
        ),
        backgroundColor: darkBackground,
        elevation: 0,
        leading: _selectedGroup != null || _selectedChatUser != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: neonCyan),
                onPressed: () {
                  setState(() {
                    _selectedGroup = null;
                    _selectedChatUser = null;
                  });
                },
              )
            : null,
        actions: [
          if (_selectedGroup == null && _selectedChatUser == null) // Only show on main screen
            IconButton(
              icon: const Icon(Icons.chat, color: neonCyan),
              onPressed: () => _showUserListForChat(),
              tooltip: 'Start New Chat',
            ),
          if (_selectedGroup != null)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () => _confirmDeleteGroup(_selectedGroup!),
              tooltip: 'Delete Group',
            ),
        ],
      ),
      backgroundColor: darkBackground,
      body: _selectedGroup == null
          ? (_selectedChatUser == null ? _buildGroupList() : _buildIndividualChat(_selectedChatUser!))
          : _buildGroupDetails(_selectedGroup!),
      floatingActionButton: _selectedGroup == null && _selectedChatUser == null
          ? FloatingActionButton(
              onPressed: _showCreateGroupDialog,
              backgroundColor: neonCyan,
              child: const Icon(Icons.add, color: darkBackground),
            )
          : null,
    );
  }

  Widget _buildGroupList() {
    return _groups.isEmpty
        ? Center(
            child: Text(
              'No groups yet. Tap + to create one!',
              style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              final group = _groups[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.group, color: neonCyan),
                  title: Text(group.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  subtitle: Text('${group.memberIds.length} members', style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _selectedGroup = group;
                    });
                  },
                ),
              );
            },
          );
  }

  Widget _buildGroupDetails(CollabGroup group) {
    final List<CollabUser> groupMembers = _allUsers.where((user) => group.memberIds.contains(user.id)).toList();
    // Filter out the current user from available users for adding to group
    final List<CollabUser> availableUsers = _allUsers.where((user) => !group.memberIds.contains(user.id) && user.id != _currentUser.id).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Members',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: neonCyan, blurRadius: 3)],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: groupMembers.isEmpty
                ? Center(
                    child: Text(
                      'No members in this group.',
                      style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: groupMembers.length,
                    itemBuilder: (context, index) {
                      final member = groupMembers[index];
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: Icon(Icons.person, color: neonCyan),
                          title: Text(member.name, style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis,),
                          subtitle: Text(member.usn, style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis,),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => _removeMemberFromGroup(group, member.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: availableUsers.isNotEmpty ? () => _showAddMemberDialog(group, availableUsers) : null,
              icon: const Icon(Icons.person_add, color: darkBackground),
              label: const Text('Add Member', style: TextStyle(color: darkBackground)),
              style: ElevatedButton.styleFrom(
                backgroundColor: neonCyan,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualChat(CollabUser chatUser) {
    final String chatKey = _getChatKey(_currentUser.usn, chatUser.usn);
    final List<ChatMessage> messages = _individualChatMessages[chatKey] ?? [];

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    'Say hi to ${chatUser.name}!',
                    style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderUsn == _currentUser.usn;
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
                              isMe ? 'You' : chatUser.name,
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
                  controller: _individualMessageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
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
                onPressed: () => _sendIndividualMessage(chatUser, _individualMessageController.text),
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

  Future<void> _showCreateGroupDialog() async {
    final TextEditingController groupNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Create New Group', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: groupNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Group Name',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: neonCyan)),
            ),
            TextButton(
              onPressed: () {
                _createGroup(groupNameController.text);
                Navigator.pop(context);
              },
              child: const Text('Create', style: TextStyle(color: neonCyan)),
            ),
          ],
        );
      },
    );
    groupNameController.dispose();
  }

  Future<void> _confirmDeleteGroup(CollabGroup group) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Delete Group', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete "${group.name}"?', style: const TextStyle(color: Colors.white70)),
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
      _deleteGroup(group);
    }
  }

  Future<void> _showAddMemberDialog(CollabGroup group, List<CollabUser> availableUsers) async {
    CollabUser? selectedUser;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Add Member', style: TextStyle(color: Colors.white)),
          content: DropdownButtonFormField<CollabUser>(
            dropdownColor: cardColor,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Select User',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
            ),
            initialValue: selectedUser,
            onChanged: (CollabUser? newValue) {
              selectedUser = newValue;
            },
            items: availableUsers.map<DropdownMenuItem<CollabUser>>((CollabUser user) {
              return DropdownMenuItem<CollabUser>(
                value: user,
                child: Text(user.name),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: neonCyan)),
            ),
            TextButton(
              onPressed: () {
                if (selectedUser != null) {
                  _addMemberToGroup(group, selectedUser!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a user')),
                  );
                }
              },
              child: const Text('Add', style: TextStyle(color: neonCyan)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUserListForChat() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Start New Chat', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allUsers.length,
              itemBuilder: (context, index) {
                final user = _allUsers[index];
                if (user.usn == _currentUser.usn) return const SizedBox.shrink(); // Don't show current user
                return ListTile(
                  leading: Icon(Icons.person, color: neonCyan),
                  title: Text(user.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(user.usn, style: const TextStyle(color: Colors.white70)),
                  onTap: () {
                    setState(() {
                      _selectedChatUser = user;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: neonCyan)),
            ),
          ],
        );
      },
    );
  }
}