import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // New import
// Import SyllabusEntry
// For JSON encoding/decoding

// Theme constants
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);

// Mock data structure for subjects
class Subject {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  Subject({required this.title, required this.description, required this.icon, required this.color});
}

// List of mock subjects for engineering students
final List<Subject> subjects = [
  Subject(
    title: 'EDW (Engineering Data Warehousing)',
    description: 'Principles and practices of designing and managing data warehouses for engineering applications.',
    icon: Icons.warehouse_outlined,
    color: const Color(0xFF28D7A3), // Greenish neon
  ),
  Subject(
    title: 'SEP (Software Engineering Principles)',
    description: 'Fundamental concepts, methodologies, and best practices for developing high-quality software systems.',
    icon: Icons.engineering_outlined,
    color: neonCyan, // Default cyan
  ),
  Subject(
    title: 'ML (Machine Learning)',
    description: 'Algorithms and models that enable systems to learn from data and make predictions or decisions.',
    icon: Icons.psychology_outlined,
    color: const Color(0xFFE91E63), // Pink neon
  ),
  Subject(
    title: 'BDA (Big Data Analytics)',
    description: 'Techniques and tools for processing, analyzing, and extracting insights from large and complex datasets.',
    icon: Icons.analytics_outlined,
    color: const Color(0xFFFF5722), // Orange/Red neon
  ),
  Subject(
    title: 'CDE (Cloud Data Engineering)',
    description: 'Designing, building, and managing data pipelines and infrastructure on cloud platforms.',
    icon: Icons.cloud_outlined,
    color: const Color(0xFF00BCD4), // Turquoise neon
  ),
  Subject(
    title: 'SEC (Power BI)',
    description: 'Business intelligence tool for data visualization, analysis, and interactive dashboards.',
    icon: Icons.bar_chart_outlined,
    color: const Color(0xFFFDD835), // Yellow neon
  ),
  Subject(
    title: 'PE-1 (NoSQL and Mining of Massive Data Sets)',
    description: 'Exploring non-relational databases and techniques for extracting patterns from very large datasets.',
    icon: Icons.data_usage_outlined,
    color: const Color(0xFF9C27B0), // Purple neon
  ),
];

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Subject> _allSubjects = []; // Combined list of static and user-defined subjects
  List<Subject> _filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadAllSubjects();
    _searchController.addListener(_filterSubjects);
  }

  Future<void> _loadAllSubjects() async {
    setState(() {
      _allSubjects = [...subjects]; // Start with predefined subjects
      _filteredSubjects = _allSubjects;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSubjects);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSubjects = _allSubjects.where((subject) {
        final titleLower = subject.title.toLowerCase();
        final descriptionLower = subject.description.toLowerCase();
        return titleLower.contains(query) || descriptionLower.contains(query);
      }).toList();
    });
  }

  // Function to save the last viewed subject
  Future<void> _saveLastViewedSubject(String subjectTitle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_viewed_subject', subjectTitle);
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
                  'The Learning Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: neonCyan, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a subject below to dive into your curriculum and materials.',
                  style: TextStyle(color: neonCyan.withAlpha((255 * 0.7).round()), fontSize: 16), // Fixed withOpacity
                ),
              ],
            ),
          ),
          
          // Search Bar (Essential for content discovery)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: _buildSearchBar(),
          ),

          // Subject Categories Grid
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Important for SingleChildScrollView
            itemCount: _filteredSubjects.length,
            itemBuilder: (context, index) {
              return _buildSubjectCard(context, _filteredSubjects[index]);
            },
          ),
          const SizedBox(height: 80), // Padding for bottom navigation
        ],
      ),
    );
  }

  // Neon-themed search bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: darkBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 1.5), // Fixed withOpacity
        boxShadow: [
          BoxShadow(
            color: neonCyan.withAlpha((255 * 0.2).round()), // Fixed withOpacity
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search for courses or topics...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: neonCyan),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // Custom Subject Card widget
  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    return GestureDetector(
      onTap: () {
        _saveLastViewedSubject(subject.title); // Save last viewed subject
        // TODO: Navigate to the detailed subject view
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tapped on ${subject.title}!', style: const TextStyle(color: darkBackground)),
            backgroundColor: subject.color,
          ),
        );
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((255 * 0.05).round()), // Fixed withOpacity
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: subject.color.withAlpha((255 * 0.6).round()), width: 2), // Fixed withOpacity
          boxShadow: [
            BoxShadow(
              color: subject.color.withAlpha((255 * 0.4).round()), // Fixed withOpacity
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Area
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: subject.color.withAlpha((255 * 0.15).round()), // Fixed withOpacity
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              ),
              child: Icon(
                subject.icon,
                size: 50,
                color: subject.color,
                shadows: [
                  Shadow(color: subject.color, blurRadius: 10),
                ],
              ),
            ),
            
            // Text Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subject.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.description,
                      style: TextStyle(
                        color: Colors.white70.withAlpha((255 * 0.8).round()), // Fixed withOpacity
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Trailing Arrow
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.arrow_forward_ios, color: subject.color, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}