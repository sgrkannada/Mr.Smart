import 'package:flutter/material.dart';

// Theme constants
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);

// Mock data structure for the Reels feed
class StudyReel {
  final String title;
  final String topic;
  final String creator;
  final Color color;

  StudyReel({required this.title, required this.topic, required this.creator, required this.color});
}

// List of mock study reels
final List<StudyReel> studyReels = [
  StudyReel(
    title: '5-Minute Calculus Hack',
    topic: 'Math: Integrals',
    creator: '@ProfX',
    color: const Color(0xFF28D7A3), // Greenish neon
  ),
  StudyReel(
    title: 'History in 60 Seconds: WW2',
    topic: 'History: Modern Age',
    creator: '@HistoryBro',
    color: const Color(0xFFFF5722), // Orange/Red neon
  ),
  StudyReel(
    title: 'The Secret Life of Mitochondria',
    topic: 'Biology: Cell Structure',
    creator: '@BioGeek',
    color: const Color(0xFFE91E63), // Pink neon
  ),
  StudyReel(
    title: 'Intro to Python Loops',
    topic: 'Code: Programming',
    creator: '@CodeNinja',
    color: neonCyan, // Default cyan
  ),
];

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // PageView.builder simulates the vertical scrolling "reels" experience
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: studyReels.length,
      itemBuilder: (context, index) {
        return _buildReelView(context, studyReels[index]);
      },
    );
  }

  Widget _buildReelView(BuildContext context, StudyReel reel) {
    return Container(
      color: darkBackground,
      child: Stack(
        children: [
          // Simulated Video Content Area (Large, color-coded box)
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: reel.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: reel.color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: reel.color.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.play_arrow_outlined,
                  size: 100,
                  color: Colors.white,
                  shadows: [Shadow(color: neonCyan, blurRadius: 10)],
                ),
              ),
            ),
          ),

          // Information Overlay (Bottom Left)
          Positioned(
            bottom: 120, // Offset from bottom navigation
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reel.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: neonCyan, blurRadius: 8)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, color: reel.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      reel.creator,
                      style: TextStyle(color: reel.color, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.tag, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      reel.topic,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons Overlay (Right side)
          Positioned(
            bottom: 150,
            right: 20,
            child: Column(
              children: [
                _buildActionButton(Icons.favorite_outline, '1.2K', reel.color),
                const SizedBox(height: 20),
                _buildActionButton(Icons.comment_outlined, '205', reel.color),
                const SizedBox(height: 20),
                _buildActionButton(Icons.bookmark_border, 'Save', reel.color),
                const SizedBox(height: 20),
                _buildActionButton(Icons.share_outlined, 'Share', reel.color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
