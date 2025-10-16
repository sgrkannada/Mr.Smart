import 'package:flutter/material.dart';
import '../main.dart'; // Import to navigate to MainScreen

// Theme constants (copied for standalone use in development)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // App Logo/Title
              const Text(
                'Smart-Bro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(color: neonCyan, blurRadius: 20, offset: Offset(0, 0)),
                  ],
                ),
              ),
              const Text(
                'The Ultimate Study Companion',
                style: TextStyle(color: neonCyan, fontSize: 16),
              ),
              const SizedBox(height: 60),

              // Email Field
              _buildNeonTextField(
                hintText: 'Student Email',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildNeonTextField(
                hintText: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 40),

              // Login Button
              _buildNeonButton(
                text: 'START STUDYING',
                onPressed: () {
                  // Dummy login logic: Navigate and replace the login screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Signup/Forgot Password links
              TextButton(
                onPressed: () {
                  // TODO: Implement navigation to Forgot Password
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline, decorationColor: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement navigation to Signup Page
                },
                child: const Text(
                  'New here? Create an Account',
                  style: TextStyle(color: neonCyan, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for custom neon text field styling
  Widget _buildNeonTextField({required String hintText, required IconData icon, bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: neonCyan.withAlpha((255 * 0.5).round()), width: 1.5), // Fixed withOpacity
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withAlpha((255 * 0.3).round()), // Fixed withOpacity
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: neonCyan),
          filled: true,
          fillColor: darkBackground.withAlpha((255 * 0.8).round()), // Fixed withOpacity
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
      ),
    );
  }

  // Helper function for custom neon button styling
  Widget _buildNeonButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [neonCyan, Color(0xFF4DFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withAlpha((255 * 0.6).round()), // Fixed withOpacity
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Make the button background transparent
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: darkBackground, 
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}