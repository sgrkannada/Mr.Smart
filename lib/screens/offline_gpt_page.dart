import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'dart:async';

class OfflineGPTPage extends StatefulWidget {
  const OfflineGPTPage({super.key});
  @override
  State<OfflineGPTPage> createState() => _OfflineGPTPageState();
}

class _OfflineGPTPageState extends State<OfflineGPTPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  LlamaParent? _llama;
  bool _modelLoaded = false;
  String? _modelPath;
  String? _error;
  bool _isLoadingModel = false;
  StreamSubscription? _llamaStreamSubscription;
  String _status = '';
  final String _systemPrompt = "You are an expert engineering assistant. Your role is to provide clear, concise, and accurate answers to engineering-related questions. You can assist with formulas, concepts, and problem-solving across various engineering disciplines like mechanical, electrical, civil, and chemical engineering.";

    @override
  void initState() {
    super.initState();
    _restoreModelPath();
  }

  @override
  void dispose() {
    _controller.dispose();
    _llama?.dispose();
    _llamaStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _restoreModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('tinyllama_model_path');
    if (savedPath != null) {
      setState(() => _modelPath = savedPath);
      await _loadModel();
    }
  }

  Future<void> _pickModelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gguf'],
    );
    if (result != null && result.files.single.path != null) {
            setState(() {
        _modelPath = result.files.single.path!;
        _modelLoaded = false;
        _isLoadingModel = true;
        _status = 'Loading model...';
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tinyllama_model_path', _modelPath!);
      await _loadModel();
    }
  }

    Future<void> _loadModel() async {
    if (_isLoadingModel) return; // Prevent multiple simultaneous loads

    // Dispose of previous model and subscription if they exist
    _llamaStreamSubscription?.cancel();
    _llama?.dispose();
    _llama = null;

    if (_modelPath == null) {
      setState(() {
        _isLoadingModel = false;
        _status = '';
        _modelLoaded = false;
      });
      return;
    }

    setState(() {
      _isLoadingModel = true;
      _status = 'Loading model...';
      _modelLoaded = false;
      _error = null; // Clear previous errors
      _messages.clear(); // Clear messages from previous model
    });

    try {
      final loadCommand = LlamaLoad(
        path: _modelPath!,
        modelParams: ModelParams(),
        contextParams: ContextParams(),
        samplingParams: SamplerParams(),
        format: ChatMLFormat(),
      );
      final llamaParent = LlamaParent(loadCommand);
      await llamaParent.init();

      setState(() {
        _llama = llamaParent;
        _modelLoaded = true;
        _status = 'Model loaded';
        _isLoadingModel = false;
      });
      _listenToModelResponse();
    } catch (e) {
      setState(() {
        _isLoadingModel = false;
        _status = 'Model could not be loaded: $e';
        _error = 'Model could not be loaded: $e';
        _modelLoaded = false;
        _modelPath = null; // Clear model path on error
      });
      _showErrorSnackbar('Model could not be loaded: $e');
    }
  }

    void _sendPrompt() {
    final text = _controller.text.trim();
    if (!_modelLoaded || text.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "content": text});
      _controller.clear();
    });
    final promptWithSystemMessage = "$_systemPrompt\n\nUser: $text\nAssistant:";
    _llama!.sendPrompt(promptWithSystemMessage);
  }

  void _listenToModelResponse() {
    _llamaStreamSubscription = _llama!.stream.listen(
      (response) {
        if (_messages.isEmpty || _messages.last['role'] != 'assistant') {
          setState(() {
            _messages.add({'role': 'assistant', 'content': response});
          });
        } else {
          setState(() {
            _messages.last['content'] = _messages.last['content']! + response;
          });
        }
      },
      onError: (e) {
        _showErrorSnackbar('Model response error: $e');
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _cancelLoading() {
    setState(() {
      _isLoadingModel = false;
      _status = '';
      _modelLoaded = false;
      _modelPath = null;
      _error = null;
      _messages.clear();
    });
    _llamaStreamSubscription?.cancel();
    _llama?.dispose();
    _llama = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OfflineGPT (TinyLlama)'),
        actions: [
          if (_isLoadingModel)
            IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: "Cancel loading",
              onPressed: _cancelLoading,
            ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Choose/Change GGUF model file",
            onPressed: _pickModelFile,
          ),
        ],
      ),
      body: Column(
        children: [
                    if (_isLoadingModel)
            const LinearProgressIndicator(),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_status),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isUser = msg["role"] == "user";
                return Container(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Card(
                    color: isUser ? Colors.teal[100] : Colors.grey[300],
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        msg["content"] ?? "-",
                        style: TextStyle(
                          color: isUser ? Colors.black87 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                );
                            },
            ),
          ),
          if (_error != null && !_modelLoaded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Error: $_error",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          if (_modelLoaded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendPrompt,
                  ),
                ],
              ),
            ),
          if (!_modelLoaded && !_isLoadingModel)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Tap + in the top right to choose a TinyLlama GGUF model file from your device storage.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
        ],
      ),
    );
  }
}


