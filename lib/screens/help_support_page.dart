import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening external links

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 5)],
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              question: 'How do I upload study materials?',
              answer: 'Navigate to the "Study Material" page from the "More" section. Tap the "Upload Document" button and select your file.',
            ),
            _buildFaqItem(
              question: 'Can I create notes directly in the app?',
              answer: 'Yes, on the "Study Material" page, tap the "Create Note" button to start a new text-based note.',
            ),
            _buildFaqItem(
              question: 'How does the clipboard sync work?',
              answer: 'The "Flow" feature (accessible from the home page) allows you to sync your device\'s clipboard with a simulated computer clipboard. (Note: Real-time sync requires a companion app on your computer, which is not implemented in this demo).',
            ),
            const SizedBox(height: 32),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 5)],
              ),
            ),
            const SizedBox(height: 16),
            _buildContactInfo(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@smartbro.com',
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'support@smartbro.com',
                  queryParameters: {'subject': 'Smart-Bro App Support'},
                );
                if (!await launchUrl(emailLaunchUri)) {
                  debugPrint('Could not launch email');
                }
              },
            ),
            _buildContactInfo(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+1 (800) 123-4567',
              onTap: () async {
                final Uri phoneLaunchUri = Uri(
                  scheme: 'tel',
                  path: '+18001234567',
                );
                if (!await launchUrl(phoneLaunchUri)) {
                  debugPrint('Could not launch phone dialer');
                }
              },
            ),
            _buildContactInfo(
              icon: Icons.public_outlined,
              title: 'Visit our Website',
              subtitle: 'www.smartbro.com/support',
              onTap: () async {
                final Uri url = Uri.parse('https://www.smartbro.com/support'); // Mock URL
                if (!await launchUrl(url)) {
                  debugPrint('Could not launch website');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: neonCyan.withOpacity(0.3), width: 1),
      ),
      elevation: 3,
      shadowColor: neonCyan.withOpacity(0.2),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Text(
              answer,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: neonCyan),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        tileColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: neonCyan.withOpacity(0.2), width: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}