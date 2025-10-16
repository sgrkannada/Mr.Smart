import 'package:flutter/material.dart';

// Theme constants
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color systemMessageColor = Color(0xFF4DFFFF); // Slightly different cyan for system messages
const Color userMessageColor = Color(0xFF2E8B57); // Dark green/teal for user messages

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello, Smart-Bro! I am The Neuron. I can help you with homework, quiz practice, or explaining tough concepts. How can I assist with your studies today?",
      isUser: false,
    ),
    ChatMessage(
      text: "I am having trouble understanding Newton's Third Law. Can you give me a simple example?",
      isUser: true,
    ),
    ChatMessage(
      text: "Absolutely! Newton's Third Law is: 'For every action, there is an equal and opposite reaction.' Think of a **rocket taking off** [Image of a rocket taking off]. The engine pushes gases *down* (action), and the gas pushes the rocket *up* (equal and opposite reaction)!",
      isUser: false,
    ),
  ];

  void _handleSubmitted(String text) {
    _controller.clear();
    if (text.trim().isEmpty) return;

    // 1. Add user message
    final userMessage = ChatMessage(text: text, isUser: true);
    setState(() {
      _messages.insert(0, userMessage);
    });

    // 2. Simulate AI response (can be replaced with actual API call)
    Future.delayed(const Duration(milliseconds: 1000), () {
      final aiResponse = ChatMessage(
        text: "That's a great question! I'll process that for you in a flash.", 
        isUser: false,
      );
      setState(() {
        _messages.insert(0, aiResponse);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Message List
        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) => _messages[index],
            itemCount: _messages.length,
          ),
        ),
        // Divider before input
        Divider(height: 1.0, color: neonCyan.withOpacity(0.3)),
        // Input Area
        _buildTextComposer(),
      ],
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: darkBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: neonCyan.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration.collapsed(
                  hintText: 'Ask The Neuron anything...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: neonCyan,
              onPressed: () => _handleSubmitted(_controller.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Widget for displaying individual chat messages
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          // Optional: AI Avatar
          if (!isUser) 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.psychology, color: systemMessageColor, size: 28),
            ),
          
          // The message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser 
                    ? userMessageColor.withOpacity(0.7) 
                    : darkBackground,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: isUser ? Colors.transparent : systemMessageColor.withOpacity(0.5),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? userMessageColor : systemMessageColor).withOpacity(0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: SelectableText(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : systemMessageColor,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          
          // Optional: User Avatar
          if (isUser) 
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.person, color: neonCyan, size: 28),
            ),
        ],
      ),
    );
  }
}
