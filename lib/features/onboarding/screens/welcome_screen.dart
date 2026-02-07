import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_button.dart';
import 'cuisine_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Swipe2Eat",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Discover your next favorite meal",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF8A3D),
                    Color(0xFFFF4D4D),
                  ],
                ),
              ),
              child: const Icon(Icons.restaurant, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 40),
            GradientButton(
              text: "Continue",
              onTap: () {
                // Navigate to cuisine screen
               Navigator.pushNamed(context, '/cuisine');
              },
            ),
          ],
        ),
      ),
    );
  }
}
