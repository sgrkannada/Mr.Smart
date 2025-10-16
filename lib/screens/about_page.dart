import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening external links

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Smart-Bro'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.school_outlined, size: 80, color: neonCyan),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart-Bro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: neonCyan, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _buildSectionTitle('Our Mission'),
            _buildInfoText(
              'Smart-Bro is designed to be your ultimate companion in your engineering academic journey. We aim to provide tools and resources that simplify learning, enhance productivity, and foster collaboration among students.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Key Features'),
            _buildFeatureList([
              'Personalized Learning Hub',
              'AI Assistant for quick answers',
              'Study Material management (notes & files)',
              'Project & Task tracking',
              'Integrated Calculator & Unit Converter',
              'Collaborative learning spaces',
              'Progress tracking & Certificates',
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Technologies Used'),
            _buildInfoText(
              'Built with Flutter for cross-platform compatibility, powered by Google Gemini for AI capabilities, and utilizing various open-source libraries to deliver a seamless experience.',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Legal & Privacy'),
            _buildLinkItem(
              title: 'Privacy Policy',
              url: 'https://www.smartbro.com/privacy', // Mock URL
            ),
            _buildLinkItem(
              title: 'Terms of Service',
              url: 'https://www.smartbro.com/terms', // Mock URL
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '© 2023 Smart-Bro Team',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: neonCyan, blurRadius: 3)],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: neonCyan, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildLinkItem({required String title, required String url}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.link, color: neonCyan),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (!await launchUrl(uri)) {
            debugPrint('Could not launch $url');
          }
        },
        tileColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: neonCyan.withOpacity(0.2), width: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}