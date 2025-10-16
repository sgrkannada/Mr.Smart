import 'package:flutter/material.dart';

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(
              title: 'Overall Learning Progress',
              progress: 0.75, // 75% complete (mock data)
              description: 'You are making great progress across all subjects!',
              color: neonCyan,
            ),
            const SizedBox(height: 24),
            Text(
              'Subject-wise Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            _buildSubjectProgress(
              subject: 'Data Structures & Algorithms',
              progress: 0.85,
              color: const Color(0xFF39FF14), // Neon Green
            ),
            _buildSubjectProgress(
              subject: 'Software Engineering',
              progress: 0.60,
              color: const Color(0xFFFF073A), // Neon Red/Pink
            ),
            _buildSubjectProgress(
              subject: 'Artificial Intelligence',
              progress: 0.40,
              color: const Color(0xFFFEF44C), // Neon Yellow
            ),
            const SizedBox(height: 24),
            Text(
              'Achievements & Milestones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: neonCyan, blurRadius: 3)],
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievementCard(
              title: 'DSA Master',
              description: 'Completed Data Structures & Algorithms course.',
              icon: Icons.star,
              color: neonCyan,
            ),
            _buildAchievementCard(
              title: 'First Project',
              description: 'Successfully completed your first project!',
              icon: Icons.emoji_events,
              color: const Color(0xFF00FFFF), // Neon Aqua
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required double progress,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
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
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withAlpha((255 * 0.3).round()),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round())),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress({
    required String subject,
    required double progress,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              subject,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withAlpha((255 * 0.3).round()),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(progress * 100).toInt()}% ',
            style: TextStyle(color: color, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha((255 * 0.4).round()), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((255 * 0.2).round()),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}