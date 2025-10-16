import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bro/screens/ai_assistant_page.dart';
import 'package:smart_bro/screens/study_material_page.dart';
import 'package:smart_bro/screens/learn_page.dart';
import 'package:smart_bro/screens/ai_hub_page.dart';
import 'package:smart_bro/utils/update_service.dart';


// Theme constants (copied from main.dart for easy reference and use in this file)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F); // Consistent card color

// Data Model for Daily Learn Item
class DailyLearnItem {
  final String title;
  final String content;
  DailyLearnItem({required this.title, required this.content});
}

// Hardcoded list of daily learn items
final List<DailyLearnItem> _dailyLearnItems = [
  DailyLearnItem(
    title: 'Quantum Computing Basics',
    content: 'Quantum computers use qubits, which can represent 0, 1, or both simultaneously (superposition), enabling them to solve complex problems faster than classical computers.',
  ),
  DailyLearnItem(
    title: 'Blockchain in Engineering',
    content: 'Blockchain\'s decentralized and immutable ledger can enhance supply chain transparency, intellectual property management, and secure data sharing in engineering projects.',
  ),
  DailyLearnItem(
    title: 'Digital Twins',
    content: 'A digital twin is a virtual replica of a physical object or system. It\'s used in engineering for real-time monitoring, simulation, and predictive maintenance.',
  ),
  DailyLearnItem(
    title: 'Generative Design',
    content: 'Generative design uses AI algorithms to rapidly generate numerous design options based on specified parameters, optimizing for performance, materials, and manufacturing constraints.',
  ),
  DailyLearnItem(
    title: 'Additive Manufacturing (3D Printing)',
    content: 'Beyond rapid prototyping, 3D printing is revolutionizing manufacturing by enabling complex geometries, custom parts, and on-demand production with various materials.',
  ),
  DailyLearnItem(
    title: 'Finite Element Analysis (FEA)',
    content: 'FEA is a computational method used to predict how a product reacts to real-world forces, heat, vibration, etc. It\'s crucial for optimizing designs and preventing failures.',
  ),
  DailyLearnItem(
    title: 'Sustainable Engineering',
    content: 'Focuses on designing solutions that meet current needs without compromising the ability of future generations to meet their own needs, integrating environmental, social, and economic considerations.',
  ),
  DailyLearnItem(
    title: 'Cyber-Physical Systems (CPS)',
    content: 'CPS are integrations of computation, networking, and physical processes. They are the foundation of IoT and Industry 4.0, enabling smart factories and infrastructure.',
  ),
  DailyLearnItem(
    title: 'Augmented Reality (AR) in Maintenance',
    content: 'AR overlays digital information onto the real world, allowing engineers to visualize repair instructions, schematics, or performance data directly on equipment during maintenance.',
  ),
  DailyLearnItem(
    title: 'Biomimicry in Design',
    content: 'Biomimicry is an approach to innovation that seeks sustainable solutions to human challenges by emulating nature\'s time-tested patterns and strategies. E.g., Velcro inspired by burrs.',
  ),
];

// --- Home Page with Motivational Panel ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _lastViewedSubject;
  DailyLearnItem? _currentDailyLearnItem;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _loadLastViewedSubject();
    _loadDailyLearnItem();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final updateInfo = await _updateService.checkForUpdate(onStatus: (status) {
      // You might want to show a less intrusive notification for status updates
      // For example, a small toast or just log it.
      print(status);
    });

    if (updateInfo != null && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(Map<String, String> updateInfo) {
    final latestVersion = updateInfo['latestVersion'] ?? 'N/A';
    final changelog = updateInfo['changelog'] ?? 'No release notes available.';
    final release = json.decode(updateInfo['release']!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Available: v$latestVersion'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('A new version of Smart Bro is available. Do you want to update now?', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Text('Changelog:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(changelog),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startDownload(release);
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _startDownload(Map<String, dynamic> release) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    await _updateService.downloadAndInstallUpdate(
      release,
      onStatus: (status) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status)),
        );
        if (status.contains('Failed') || status.contains('Installing')) {
          setState(() {
            _isDownloading = false;
          });
        }
      },
      onProgress: (progress) {
        setState(() {
          _downloadProgress = progress;
        });
      },
    );
  }

  Future<void> _loadLastViewedSubject() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastViewedSubject = prefs.getString('last_viewed_subject');
    });
  }

  void _loadDailyLearnItem() {
    final int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final int index = dayOfYear % _dailyLearnItems.length;
    setState(() {
      _currentDailyLearnItem = _dailyLearnItems[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back, Bro!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Daily Learn One New Thing Section
                if (_currentDailyLearnItem != null)
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: neonCyan, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              'Daily Learn: ${_currentDailyLearnItem!.title}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const Divider(color: neonCyan, height: 20),
                        Text(
                          _currentDailyLearnItem!.content,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // The Motivational Panel
                const _MotivationalPanel(),
                const SizedBox(height: 32),

                // Last Viewed Subject Section
                if (_lastViewedSubject != null) ...[
                  Text(
                    'Continue Learning',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha((255 * 0.8).round()), // Fixed withOpacity
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LearnPage()), // Navigate to LearnPage
                      );
                    },
                    child: Container(
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
                      child: Row(
                        children: [
                          Icon(Icons.history_toggle_off, color: neonCyan, size: 30),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Viewed:',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  _lastViewedSubject!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: neonCyan, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Quick Access Modules Section
                Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha((255 * 0.8).round()),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2, // Two cards per row
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8, // Adjust aspect ratio for card size
                  children: [
                    _buildQuickAccessCard(
                      context,
                      title: 'AI Assistant',
                      icon: Icons.psychology_outlined,
                      color: neonCyan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AIAssistantPage()),
                        );
                      },
                    ),
                    _buildQuickAccessCard(
                      context,
                      title: 'Study Material',
                      icon: Icons.book_outlined,
                      color: const Color(0xFF00FFFF), // Neon Aqua
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudyMaterialPage()),
                        );
                      },
                    ),
                    _buildQuickAccessCard(
                      context,
                      title: 'All Subjects',
                      icon: Icons.school_outlined,
                      color: const Color(0xFF39FF14), // Neon Green
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LearnPage()),
                        );
                      },
                    ),
                    _buildQuickAccessCard(
                      context,
                      title: 'AI Hub',
                      icon: Icons.auto_awesome_outlined,
                      color: const Color(0xFFDA70D6), // Orchid
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AIHubPage()),
                        );
                      },
                    ),
                    // Add more quick access cards as needed
                  ],
                ),
              ],
            ),
          ),
          if (_isDownloading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.black.withOpacity(0.8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Downloading Update...', style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: Colors.grey,
                            valueColor: const AlwaysStoppedAnimation<Color>(neonCyan),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('${(_downloadProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Moved inside _HomePageState and removed const
  Widget _buildQuickAccessCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha((255 * 0.5).round()), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((255 * 0.3).round()),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 30),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(color: color, blurRadius: 3)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationalPanel extends StatefulWidget {
  const _MotivationalPanel();

  @override
  State<_MotivationalPanel> createState() => _MotivationalPanelState();
}

class _MotivationalPanelState extends State<_MotivationalPanel> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Map<String, String>> _quotes = [
    {
      'quote': '“The expert in anything was once a beginner. Embrace the challenge, stay consistent, and watch your future self thank you.”',
      'author': '- Smart-Bro'
    },
    {
      'quote': '“Success is not final, failure is not fatal: it is the courage to continue that counts.”',
      'author': '- Winston Churchill'
    },
    {
      'quote': '“The only way to do great work is to love what you do.”',
      'author': '- Steve Jobs'
    },
    {
      'quote': '“Believe you can and you\'re halfway there.”',
      'author': '- Theodore Roosevelt'
    },
    {
      'quote': '“The future belongs to those who believe in the beauty of their dreams.”',
      'author': '- Eleanor Roosevelt'
    },
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Fixed height for the panel
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 2),
        boxShadow: const [
          BoxShadow(
            color: neonCyan,
            blurRadius: 20,
            spreadRadius: -5,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                final quote = _quotes[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row( // Added missing Row
                      children: [
                        const Icon(Icons.lightbulb_outline, color: neonCyan, size: 30),
                        const SizedBox(width: 10),
                        const Text(
                          'Today\'s Motivation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ), // Closing Row
                    const Divider(color: neonCyan, height: 25),
                    Expanded(
                      child: Text(
                        quote['quote']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        quote['author']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: neonCyan,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_quotes.length, (index) {
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
    );
  }
}