import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // New import

import 'package:smart_bro/screens/offline_gpt_page.dart';
import 'package:smart_bro/screens/profile_page.dart';
import 'package:smart_bro/screens/progress_page.dart';
import 'package:smart_bro/screens/settings_page.dart';
import 'package:smart_bro/screens/syllabus_map_page.dart';
import 'package:smart_bro/screens/help_support_page.dart';
import 'package:smart_bro/screens/about_page.dart';
import 'package:smart_bro/screens/study_material_page.dart';
import 'package:smart_bro/screens/calculator_page.dart';
import 'package:smart_bro/screens/project_management_page.dart';
import 'package:smart_bro/screens/collab_page.dart';
import 'package:smart_bro/screens/my_certificates_page.dart'; // New import
import 'package:smart_bro/screens/document_search_page.dart';
import 'package:smart_bro/screens/git_integration_page.dart';
import 'package:smart_bro/screens/notes_page.dart';
import 'package:smart_bro/screens/news_feed_page.dart';
import 'package:smart_bro/screens/code_sandbox_page.dart';
import 'package:smart_bro/screens/todo_list_page.dart'; // New import for To-Do List
import 'package:smart_bro/screens/anonymous_doubt_page.dart'; // New import for Anonymous Doubts
import 'package:smart_bro/screens/attendance_page.dart'; // New import for Attendance Page
import 'package:smart_bro/screens/attendance_page.dart'; // New import for Attendance Page


// Theme constants (copied for consistency across screens)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F); // Slightly lighter dark background for cards
class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<List<Map<String, dynamic>>> _groupedQuickAccessItems = [];

  // Data for the horizontal 'Quick Access' cards
  final List<Map<String, dynamic>> quickAccessItems = [
    // Productivity & Utilities
    {
      'title': 'Quick Notes',
      'icon': Icons.note_add_outlined,
      'color': const Color(0xFF00FF7F), // Spring Green
    },
    {
      'title': 'To-Do List',
      'icon': Icons.checklist_outlined,
      'color': const Color(0xFF00BFFF), // Deep Sky Blue
    },
    {
      'title': 'Calculator',
      'icon': Icons.calculate_outlined,
      'color': neonCyan, // Changed from Neon Yellow
    },
    {
      'title': 'Document Search',
      'icon': Icons.search_outlined,
      'color': const Color(0xFFFFA500), // Neon Orange
    },
    {
      'title': 'Study Material',
      'icon': Icons.book_outlined,
      'color': const Color(0xFF00FFFF), // Neon Aqua
    },
    // AI & Learning
    {
      'title': 'OfflineGPT',
      'icon': Icons.offline_bolt_outlined,
      'color': const Color(0xFF39FF14), // Neon Green
    },
    {
      'title': 'AI HR', // NEW
      'icon': Icons.support_agent_outlined,
      'color': const Color(0xFFEE82EE), // Violet
    },
    {
      'title': 'Engineering News',
      'icon': Icons.article_outlined,
      'color': const Color(0xFFADD8E6), // Light Blue
    },
    {
      'title': 'Code Sandbox',
      'icon': Icons.code,
      'color': const Color(0xFFDA70D6), // Orchid
    },
    {
      'title': 'Syllabus Map',
      'icon': Icons.assignment_outlined,
      'color': neonCyan, // Changed from Neon Yellow
    },
    {
      'title': 'Anonymous Doubts',
      'icon': Icons.question_answer_outlined,
      'color': const Color(0xFFEE82EE), // Violet
    },
    {
      'title': 'Attendance Manager',
      'icon': Icons.calendar_today_outlined,
      'color': const Color(0xFF00FF00), // Neon Green
    },
    // Personal & Project Management
    {
      'title': 'My Progress',
      'icon': Icons.bar_chart_outlined,
      'color': const Color(0xFFFF073A), // Neon Red/Pink
    },
    {
      'title': 'My Certificates', // NEW
      'icon': Icons.card_membership_outlined,
      'color': const Color(0xFF00FF00), // Neon Green
    },
    {
      'title': 'Project Manager',
      'icon': Icons.assignment_turned_in_outlined,
      'color': const Color(0xFF00FF00), // Neon Green
    },
    {
      'title': 'Collab with Friends',
      'icon': Icons.people_alt_outlined,
      'color': const Color(0xFF00BFFF), // Deep Sky Blue
    },
    {
      'title': 'Git Integration',
      'icon': Icons.code_outlined,
      'color': const Color(0xFF8A2BE2), // Blue Violet
    },
  ];

  @override
  void initState() {
    super.initState();
    _groupItems();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _groupItems() {
    _groupedQuickAccessItems.clear();
    for (int i = 0; i < quickAccessItems.length; i += 4) {
      _groupedQuickAccessItems.add(
        quickAccessItems.sublist(i, i + 4 > quickAccessItems.length ? quickAccessItems.length : i + 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          // Section 1: Horizontal Feature Slides
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              'Essential Modules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
                      ),
                    ),
                  ),
                    SizedBox(
                      height: 350, // Height to accommodate 2x2 grid and indicator
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _groupedQuickAccessItems.length,
                              itemBuilder: (context, pageIndex) {
                                final pageItems = _groupedQuickAccessItems[pageIndex];
                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2, // Two cards per row
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  childAspectRatio: 1.2, // Adjust aspect ratio for card size
                                  children: pageItems.map((item) {
                                    return MoreCard(
                                      title: item['title'],
                                      icon: item['icon'],
                                      neonColor: item['color'],
                                      onTap: () async { // Changed to async for url_launcher
                                        // Implement navigation to the respective page
                                        if (item['title'] == 'My Profile') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const ProfilePage()),
                                          );
                                        } else if (item['title'] == 'OfflineGPT') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const OfflineGPTPage()),
                                          );
                                        } else if (item['title'] == 'My Progress') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const ProgressPage()),
                                          );
                                        } else if (item['title'] == 'My Certificates') { // NEW navigation
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const MyCertificatesPage()),
                                          );
                                        } else if (item['title'] == 'Syllabus Map') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SyllabusMapPage()),
                                          );
                                        } else if (item['title'] == 'Study Material') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const StudyMaterialPage()),
                                          );
                                        } else if (item['title'] == 'Calculator') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const CalculatorPage()),
                                          );
                                        } else if (item['title'] == 'Document Search') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const DocumentSearchPage()),
                                          );
                                        } else if (item['title'] == 'Project Manager') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const ProjectManagementPage()),
                                          );
                                        } else if (item['title'] == 'Collab with Friends') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const CollabPage()),
                                          );
                                        } else if (item['title'] == 'AI HR') { // NEW navigation with url_launcher
                                          final Uri url = Uri.parse('https://agents-playground.livekit.io/');
                                          if (!await launchUrl(url)) {
                                            debugPrint('Could not launch $url');
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Could not open ${item['title']} link.')),
                                            );
                                          }
                                        } else if (item['title'] == 'App Settings') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SettingsPage()),
                                          );
                                        } else if (item['title'] == 'Git Integration') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const GitIntegrationPage()),
                                          );
                                                                      } else if (item['title'] == 'Quick Notes') {
                                                                        Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(builder: (context) => const NotesPage()),
                                                                        );
                                                                      } else if (item['title'] == 'To-Do List') {
                                                                        Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(builder: (context) => const TodoListPage()),
                                                                        );
                                                                      } else if (item['title'] == 'Engineering News') {                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const NewsFeedPage()),
                                          );
                                        } else if (item['title'] == 'Code Sandbox') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const CodeSandboxPage()),
                                          );
                                        } else if (item['title'] == 'Anonymous Doubts') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const AnonymousDoubtPage()),
                                          );
                                        } else if (item['title'] == 'Attendance Manager') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const AttendancePage()),
                                          );
                                        } else {
                                          debugPrint('Tapped on ${item['title']}');
                                        }
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_groupedQuickAccessItems.length, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == index ? neonCyan : Colors.grey.withAlpha((255 * 0.5).round()),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
          const Divider(height: 48, color: Colors.white10),
          // Section 2: Standard Vertical List (for less visual items)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Support & Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
      ),
            ),
          ),
          _buildListItem(context, Icons.person_outline, 'My Profile', neonCyan),
          _buildListItem(
              context, Icons.contact_support_outlined, 'Help & Support', neonCyan),
          _buildListItem(
              context, Icons.info_outline, 'About Smart-Bro', neonCyan),
          _buildListItem(
              context, Icons.settings_outlined, 'App Settings', neonCyan),
          _buildListItem(context, Icons.logout, 'Log Out', Colors.redAccent),
        ],
      ),
    );
  }

  // Helper function to build vertical list tiles
  Widget _buildListItem(
      BuildContext context, IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
            color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () async { // Changed to async for url_launcher
        // Implement navigation for list items
        if (title == 'My Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (title == 'Help & Support') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpSupportPage()),
          );
        } else if (title == 'About Smart-Bro') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutPage()),
          );
        } else if (title == 'App Settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        } else if (title == 'Log Out') {
          // Implement actual logout logic
          debugPrint('Logging out...');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out (simulated)')),
          );
        } else {
          debugPrint('Tapped on $title');
        }
      },
      // Subtle hover/tap effect
      tileColor: darkBackground,
      hoverColor: neonCyan.withAlpha((255 * 0.05).round()), // Fixed withOpacity
    );
}
}

class MoreCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color neonColor;
  final VoidCallback onTap;

  const MoreCard({
    super.key,
    required this.title,
    required this.icon,
    required this.neonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140, // Fixed width for horizontal card
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: neonColor.withAlpha((255 * 0.3).round()), width: 1),
          boxShadow: [
            BoxShadow(
              color: neonColor.withAlpha((255 * 0.5).round()),
              blurRadius: 15,
              spreadRadius: -8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: neonColor,
              shadows: const [
                Shadow(color: Colors.white, blurRadius: 1),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(color: neonColor, blurRadius: 3)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: neonColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}