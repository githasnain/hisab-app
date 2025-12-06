import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../boxes.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8E1), // Soft pastel yellow/cream background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header / Illustration Placeholder
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            height: 250, // Reduced slightly to fit better
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFCCBC).withValues(
                                  alpha: 0.3), // Soft coral background
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 100,
                                color: Color(0xFFFF7043), // Coral color
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Manage your daily\nlife expenses',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28, // Slightly smaller for better fit
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3142),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Expense Tracker is a simple and efficient personal finance management app that allows you to track your daily expenses and income.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Swipe/Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Mark welcome screen as seen
                            final settingsBox = Boxes.getSettings();
                            await settingsBox.put('hasSeenWelcome', true);

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7043), // Coral
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor:
                                const Color(0xFFFF7043).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
