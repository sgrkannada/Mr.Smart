import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({super.key});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  List<dynamic> _articles = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    // Using a placeholder API for demonstration. In a real app, you'd use a specific news API.
    // For example, NewsAPI.org (requires an API key) or a custom backend.
    // This example uses a mock API response for now.
    const String mockApiResponse = '''
    {
      "articles": [
        {
          "title": "Breakthrough in Sustainable Engineering Materials",
          "description": "Researchers have developed a new class of eco-friendly materials with superior strength.",
          "url": "https://example.com/sustainable-materials",
          "imageUrl": "https://via.placeholder.com/150/0000FF/FFFFFF?text=Sustainable"
        },
        {
          "title": "AI Revolutionizes Civil Engineering Design",
          "description": "Artificial intelligence is being used to optimize structural designs and reduce costs.",
          "url": "https://example.com/ai-civil-engineering",
          "imageUrl": "https://via.placeholder.com/150/FF0000/FFFFFF?text=AI+Civil"
        },
        {
          "title": "New Advancements in Quantum Computing for Engineers",
          "description": "Quantum algorithms are showing promise in solving complex engineering problems.",
          "url": "https://example.com/quantum-engineering",
          "imageUrl": "https://via.placeholder.com/150/00FF00/FFFFFF?text=Quantum"
        }
      ]
    }
    ''';

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final Map<String, dynamic> data = json.decode(mockApiResponse);
      setState(() {
        _articles = data['articles'] ?? [];
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load news: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
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
        title: const Text('Engineering News'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchNews,
                  child: ListView.builder(
                    itemCount: _articles.length,
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: article['imageUrl'] != null
                              ? Image.network(
                                  article['imageUrl'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.article, size: 80),
                          title: Text(article['title'] ?? 'No Title'),
                          subtitle: Text(article['description'] ?? 'No Description'),
                          onTap: () => _launchUrl(article['url'] ?? ''),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
