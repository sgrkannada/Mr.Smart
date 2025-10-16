import 'package:shared_preferences/shared_preferences.dart';

class PointsManager {
  static const String _pointsKey = 'user_points';

  static Future<int> loadUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  static Future<void> _saveUserPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, points);
  }

  static Future<int> awardPoints(int pointsToAward) async {
    int currentPoints = await loadUserPoints();
    currentPoints += pointsToAward;
    await _saveUserPoints(currentPoints);
    return currentPoints;
  }

  static Future<int> deductPoints(int pointsToDeduct) async {
    int currentPoints = await loadUserPoints();
    currentPoints -= pointsToDeduct;
    if (currentPoints < 0) currentPoints = 0; // Points cannot go below zero
    await _saveUserPoints(currentPoints);
    return currentPoints;
  }

  static Future<void> resetPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pointsKey);
  }
}