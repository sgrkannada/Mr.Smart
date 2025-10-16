import 'package:flutter/material.dart';
import 'package:smart_bro/screens/learn_page.dart'; // Import Subject class
import 'package:flutter_gemini/flutter_gemini.dart'; // Import Gemini package
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences
import 'package:smart_bro/utils/points_manager.dart'; // Import PointsManager

// Theme constants
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F); // Consistent card color

enum TestType { quickQuiz, subjectDeepDive, previousYearQuestions, custom }
enum Difficulty { beginner, intermediate, advanced }

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Subject? _selectedSubject;
  final List<String> _selectedTopics = [];
  TestType _selectedTestType = TestType.quickQuiz;
  Difficulty _selectedDifficulty = Difficulty.beginner;
  bool _isGeneratingTest = false;
  String? _message;
  final List<Subject> _customSubjects = []; // To hold temporarily added subjects
  String? _geminiApiKey;
  String? _lastTestResult; // To store the last generated test content

  final TextEditingController _customSubjectTitleController = TextEditingController();
  final TextEditingController _customSubjectTopicsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGeminiApiKey();
    _loadLastTestResult();
  }

  Future<void> _loadGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _geminiApiKey = prefs.getString('gemini_api_key');
    });
  }

  Future<void> _loadLastTestResult() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastTestResult = prefs.getString('last_test_result');
    });
  }

  Future<void> _saveLastTestResult(String result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_test_result', result);
  }

  @override
  void dispose() {
    _customSubjectTitleController.dispose();
    _customSubjectTopicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Bench',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: neonCyan, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select test parameters to create a custom test.',
                  style: TextStyle(color: neonCyan.withAlpha((255 * 0.7).round()), fontSize: 16),
                ),
              ],
            ),
          ),

          // Test Type Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: _buildTestTypeSelection(),
          ),

          // Difficulty Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: _buildDifficultySelection(),
          ),

          // Subject Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: _buildSubjectSelection(),
          ),

          // Topic Selection
          if (_selectedSubject != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: _buildTopicSelection(),
            ),

          // Generate Test Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: _isGeneratingTest
                  ? const CircularProgressIndicator(color: neonCyan)
                  : ElevatedButton.icon(
                      onPressed: _generateTest,
                      icon: const Icon(Icons.play_arrow, color: darkBackground),
                      label: const Text('Generate Test', style: TextStyle(color: darkBackground)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonCyan,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ),
          ),

          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(
                child: Text(
                  _message!,
                  style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Display Previous Test Result
          if (_lastTestResult != null && _lastTestResult!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Attempted Test:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: neonCyan, blurRadius: 5)],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _lastTestResult = null;
                        });
                        _saveLastTestResult(''); // Clear from SharedPreferences
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Previous test result cleared!')),
                        );
                      },
                      icon: const Icon(Icons.clear, color: Colors.redAccent),
                      label: const Text('Clear Previous Result', style: TextStyle(color: Colors.redAccent)),
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
                      _lastTestResult!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 10, // Limit to 10 lines for preview
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 80), // Padding for bottom navigation
        ],
      ),
    );
  }

  Widget _buildTestTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Test Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha((255 * 0.8).round()),
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<TestType>(
          segments: const [
            ButtonSegment<TestType>(
              value: TestType.quickQuiz,
              label: Text('Quick Quiz'),
              icon: Icon(Icons.lightbulb_outline),
            ),
            ButtonSegment<TestType>(
              value: TestType.subjectDeepDive,
              label: Text('Deep Dive'),
              icon: Icon(Icons.school_outlined),
            ),
            ButtonSegment<TestType>(
              value: TestType.previousYearQuestions,
              label: Text('PYQs'),
              icon: Icon(Icons.history_edu_outlined),
            ),
            ButtonSegment<TestType>(
              value: TestType.custom,
              label: Text('Custom'),
              icon: Icon(Icons.build_outlined),
            ),
          ],
          selected: <TestType>{_selectedTestType},
          onSelectionChanged: (Set<TestType> newSelection) {
            setState(() {
              _selectedTestType = newSelection.first;
            });
          },
          style: SegmentedButton.styleFrom(
            foregroundColor: neonCyan,
            selectedForegroundColor: darkBackground,
            selectedBackgroundColor: neonCyan,
            side: const BorderSide(color: neonCyan),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Difficulty',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha((255 * 0.8).round()),
          ),
        ),
        const SizedBox(height: 10),
        SegmentedButton<Difficulty>(
          segments: const [
            ButtonSegment<Difficulty>(
              value: Difficulty.beginner,
              label: Text('Beginner'),
            ),
            ButtonSegment<Difficulty>(
              value: Difficulty.intermediate,
              label: Text('Intermediate'),
            ),
            ButtonSegment<Difficulty>(
              value: Difficulty.advanced,
              label: Text('Advanced'),
            ),
          ],
          selected: <Difficulty>{_selectedDifficulty},
          onSelectionChanged: (Set<Difficulty> newSelection) {
            setState(() {
              _selectedDifficulty = newSelection.first;
            });
          },
          style: SegmentedButton.styleFrom(
            foregroundColor: neonCyan,
            selectedForegroundColor: darkBackground,
            selectedBackgroundColor: neonCyan,
            side: const BorderSide(color: neonCyan),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelection() {
    final List<Subject> allAvailableSubjects = [...subjects, ..._customSubjects];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Subject',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha((255 * 0.8).round()),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: darkBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: neonCyan.withAlpha((255 * 0.2).round()),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Subject>(
                    isExpanded: true,
                    value: _selectedSubject,
                    hint: const Text('Select a Subject', style: TextStyle(color: Colors.white70)),
                    icon: const Icon(Icons.arrow_drop_down, color: neonCyan),
                    dropdownColor: cardColor, // Use cardColor for dropdown background
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (Subject? newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                        _selectedTopics.clear(); // Clear topics when subject changes
                      });
                    },
                    items: allAvailableSubjects.map<DropdownMenuItem<Subject>>((Subject subject) {
                      return DropdownMenuItem<Subject>(
                        value: subject,
                        child: Text(subject.title),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: neonCyan, size: 30),
              tooltip: 'Add Custom Subject/Topic',
              onPressed: _showAddCustomSubjectDialog,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicSelection() {
    final List<String> allTopics = _selectedSubject!.description.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Topics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha((255 * 0.8).round()),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          children: allTopics.map((topic) {
            return ChoiceChip(
              label: Text(topic),
              selected: _selectedTopics.contains(topic),
              selectedColor: neonCyan.withAlpha((255 * 0.7).round()),
              backgroundColor: cardColor,
              labelStyle: TextStyle(
                color: _selectedTopics.contains(topic) ? darkBackground : Colors.white70,
              ),
              side: BorderSide(color: neonCyan.withAlpha((255 * 0.5).round())),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedTopics.add(topic);
                  } else {
                    _selectedTopics.removeWhere((String name) => name == topic);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _generateTest() async {
    if (_selectedSubject == null || _selectedTopics.isEmpty) {
      setState(() {
        _message = 'Please select a subject and at least one topic.';
      });
      return;
    }

    if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
      setState(() {
        _message = 'Gemini API Key is not set. Please go to Settings to set it.';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API Key is not set. Please go to Settings to set it.')),
      );
      return;
    }

    setState(() {
      _isGeneratingTest = true;
      _message = null;
    });

    // Initialize Gemini with the retrieved API key
    Gemini.init(apiKey: _geminiApiKey!);
    final gemini = Gemini.instance;

    final String prompt = "Create a ${_selectedDifficulty.name} level ${_selectedTestType.name} test for the subject '${_selectedSubject!.title}' covering the topics: ${_selectedTopics.join(', ')}. Provide 5 multiple-choice questions with 4 options each, and clearly indicate the correct answer for each question. Format the output clearly with question number, options (A, B, C, D), and 'Correct Answer: X'.";

    try {
      final response = await gemini.text(prompt, modelName: 'gemini-pro');

      if (!mounted) return;

      setState(() {
        _isGeneratingTest = false;
        _message = response?.output ?? 'No test generated.';
        _lastTestResult = _message; // Save the generated test content
      });
      await _saveLastTestResult(_message!); // Persist the last test result
      await PointsManager.awardPoints(10); // Award points for generating a test

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test generated successfully! +10 points!', style: const TextStyle(color: darkBackground)),
          backgroundColor: neonCyan,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGeneratingTest = false;
        _message = 'Error generating test: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating test: $e', style: const TextStyle(color: darkBackground)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _showAddCustomSubjectDialog() async {
    _customSubjectTitleController.clear();
    _customSubjectTopicsController.clear();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Add Custom Subject', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customSubjectTitleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Subject Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customSubjectTopicsController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Topics (comma-separated)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonCyan, width: 2)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: neonCyan)),
            ),
            TextButton(
              onPressed: () {
                final String title = _customSubjectTitleController.text.trim();
                final String topics = _customSubjectTopicsController.text.trim();

                if (title.isNotEmpty && topics.isNotEmpty) {
                  setState(() {
                    final newSubject = Subject(
                      title: title,
                      description: topics,
                      icon: Icons.bookmark_add_outlined, // Generic icon for custom subjects
                      color: neonCyan, // Generic color
                    );
                    _customSubjects.add(newSubject);
                    _selectedSubject = newSubject; // Automatically select the new subject
                    _selectedTopics.clear(); // Clear topics for new subject
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter both title and topics')),
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
}