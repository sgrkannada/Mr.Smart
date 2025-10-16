import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Import Screens ---
import 'package:smart_bro/screens/home_page.dart';
import 'package:smart_bro/screens/learn_page.dart';
import 'package:smart_bro/screens/test_page.dart';
import 'package:smart_bro/screens/reels_page.dart';
import 'package:smart_bro/screens/more_page.dart';
import 'package:smart_bro/screens/settings_page.dart';
import 'package:smart_bro/screens/ai_assistant_page.dart';
import 'package:smart_bro/screens/login_page.dart';
import 'package:smart_bro/screens/flow_page.dart'; 

// --- Neon Theme Colors ---
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

void main() {

  runApp(const SmartBroApp());
}

class SmartBroApp extends StatefulWidget {
  const SmartBroApp({super.key});

  @override
  State<SmartBroApp> createState() => _SmartBroAppState();
}

class _SmartBroAppState extends State<SmartBroApp> {
  Color _currentAccentColor = neonCyan; // Default color

  @override
  void initState() {
    super.initState();
    _loadAccentColor();
  }

  Future<void> _loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final int? colorValue = prefs.getInt('accent_color');
    if (colorValue != null) {
      setState(() {
        _currentAccentColor = Color(colorValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart-Bro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.dark(
          primary: _currentAccentColor,
          secondary: _currentAccentColor,
          surface: darkBackground,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: _currentAccentColor,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: darkBackground,
          selectedItemColor: _currentAccentColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 5,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),

    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Screens for navigation bar
  final List<Widget> _pages = [
    const HomePage(),
    const LearnPage(),
    const TestPage(),
    const ReelsPage(),
    MorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mr.Smart-Engineer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 24,
            shadows: [
              Shadow(color: neonCyan, blurRadius: 10),
            ],
          ),
        ),
        actions: [
          // AI Assistant Button
          IconButton(
            icon: const Icon(Icons.psychology_outlined, color: neonCyan),
            tooltip: 'AI Assistant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIAssistantPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.computer_outlined, color: neonCyan),
            tooltip: 'Flow',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlowPage()),
              );
            },
          ),

          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings, color: neonCyan),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              // After returning from settings, reload accent color
              if (mounted) {
                (context.findAncestorStateOfType<_SmartBroAppState>())?._loadAccentColor();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_outlined),
            activeIcon: Icon(Icons.local_fire_department),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}


