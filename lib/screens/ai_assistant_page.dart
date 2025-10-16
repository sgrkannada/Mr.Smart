import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:smart_bro/screens/settings_page.dart'; // Import SettingsPage
import 'package:smart_bro/utils/points_manager.dart'; // Import PointsManager

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color chatBubbleColor = Color(0xFF1F1F1F); // Consistent chat bubble color

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  String? _geminiApiKey;
  bool _isLoading = false;
  final List<Map<String, String>> _messages = []; // Stores {'role': 'user'/'assistant', 'content': '...'}
  String? _documentSummary;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadGeminiApiKeyAndInit();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _promptController.dispose();
    _documentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGeminiApiKeyAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString('gemini_api_key');
    setState(() {
      _geminiApiKey = apiKey;
    });

    if (_geminiApiKey != null && _geminiApiKey!.isNotEmpty) {
      Gemini.init(apiKey: _geminiApiKey!);
    } else {
      _showErrorSnackbar('Gemini API Key is not set. Please go to Settings to set it.');
    }
  }

  void _getChatResponse() {
    if (_promptController.text.isEmpty) {
      return;
    }
    if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
      _showErrorSnackbar('Gemini API Key is not set. Please go to Settings to set it.');
      return;
    }

    final userMessage = _promptController.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isLoading = true;
      _promptController.clear();
    });

    final gemini = Gemini.instance;
    gemini.text(userMessage, modelName: 'gemini-pro').then((response) async {
      if (!mounted) return;
      setState(() {
        _messages.add({'role': 'assistant', 'content': response?.output ?? 'No response'});
        _isLoading = false;
      });
      await PointsManager.awardPoints(5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat response received! +5 points!')),
      );
    }).catchError((error) {
      String errorMessage = 'An unknown error occurred.';
      if (error is GeminiException) {
        errorMessage = 'Gemini Error: ${error.message}';
      } else {
        errorMessage = 'Error: $error';
      }
      setState(() {
        _messages.add({'role': 'assistant', 'content': errorMessage});
        _isLoading = false;
      });
      _showErrorSnackbar(errorMessage);
    });
  }

  Future<void> _summarizeDocument() async {
    if (_documentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to summarize.')),
      );
      return;
    }
    if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
      _showErrorSnackbar('Gemini API Key is not set. Please go to Settings to set it.');
      return;
    }

    setState(() {
      _isLoading = true;
      _documentSummary = null;
    });

    final gemini = Gemini.instance;
    final String prompt = "Summarize the following document: \n\n${_documentController.text}";

    try {
      final response = await gemini.text(prompt, modelName: 'gemini-pro');
      if (!mounted) return;
      setState(() {
        _documentSummary = response?.output ?? 'Could not summarize document.';
        _isLoading = false;
      });
      await PointsManager.awardPoints(5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document summarized successfully! +5 points!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _documentSummary = 'Error summarizing document: $e';
      });
      _showErrorSnackbar('Error summarizing document: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: darkBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: neonCyan,
          labelColor: neonCyan,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Chat', icon: Icon(Icons.chat_outlined)),
            Tab(text: 'Summarize Document', icon: Icon(Icons.summarize_outlined)),
          ],
        ),
      ),
      backgroundColor: darkBackground,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chat Interface
          _geminiApiKey == null || _geminiApiKey!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Gemini API Key is not set.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please go to Settings to set your API key.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to settings page
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonCyan,
                          foregroundColor: darkBackground,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Go to Settings'),
                      ),
                    ],
                  ),
                )
              : _buildChatInterface(),

          // Summarize Document Interface
          _geminiApiKey == null || _geminiApiKey!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Gemini API Key is not set.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please go to Settings to set your API key.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to settings page
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: neonCyan,
                          foregroundColor: darkBackground,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Go to Settings'),
                      ),
                    ],
                  ),
                )
              : _buildSummarizeInterface(),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? neonCyan.withAlpha((255 * 0.8).round()) : chatBubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isUser ? neonCyan : Colors.grey).withAlpha((255 * 0.2).round()),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? 'You' : 'AI Assistant',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUser ? darkBackground : neonCyan,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['content']!,
                          style: TextStyle(
                            color: isUser ? darkBackground : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your message...',
                    hintStyle: TextStyle(color: Colors.grey.withAlpha((255 * 0.7).round())),
                    filled: true,
                    fillColor: chatBubbleColor,
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
              _isLoading
                  ? const CircularProgressIndicator(color: neonCyan)
                  : FloatingActionButton(
                      onPressed: _getChatResponse,
                      backgroundColor: neonCyan,
                      mini: true,
                      child: Icon(Icons.send, color: darkBackground),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarizeInterface() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _documentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Paste document text here',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'e.g., research paper, article, notes',
                      hintStyle: TextStyle(color: Colors.white54.withAlpha((255 * 0.8).round())),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: neonCyan),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: neonCyan, width: 2),
                      ),
                    ),
                    maxLines: 10,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _summarizeDocument,
                      icon: const Icon(Icons.summarize, color: darkBackground),
                      label: const Text('Summarize Document', style: TextStyle(color: darkBackground)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonCyan,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator(color: neonCyan)),
                    ),
                  if (_documentSummary != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: neonCyan, blurRadius: 3)],
                            ),
                          ),
                          const SizedBox(height: 10),
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
                            child: Text(
                              _documentSummary!,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}