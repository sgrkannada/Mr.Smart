import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GitIntegrationPage extends StatefulWidget {
  const GitIntegrationPage({super.key});

  @override
  State<GitIntegrationPage> createState() => _GitIntegrationPageState();
}

class _GitIntegrationPageState extends State<GitIntegrationPage> {
  final TextEditingController _urlController = TextEditingController();

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(_urlController.text);
    if (!await launchUrl(url)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Git Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Git Repository URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _launchUrl,
              child: const Text('Open Repository'),
            ),
          ],
        ),
      ),
    );
  }
}
