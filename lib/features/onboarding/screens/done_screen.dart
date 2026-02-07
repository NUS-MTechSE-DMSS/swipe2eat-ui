import 'package:flutter/material.dart';
import '../../discover/discover_screen.dart';

class DoneScreen extends StatelessWidget {
  final String selectedCuisinesLabel;
  final String selectedSpiceLabel;
  final String selectedBudget;

  const DoneScreen({
    super.key,
    required this.selectedCuisinesLabel,
    required this.selectedSpiceLabel,
    required this.selectedBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            children: [
              const _ProgressPills(currentStep: 5, totalSteps: 5),
              const SizedBox(height: 26),

              const Text(
                "You're all set!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                "Let's find your next meal",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 26),

              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 28,
                      offset: Offset(0, 10),
                      color: Color(0x22000000),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 62,
                ),
              ),
              const SizedBox(height: 26),

              _InfoCard(
                title: "Your preferences",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      selectedCuisinesLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _MiniCard(
                      title: "Spice Level",
                      value: selectedSpiceLabel,
                      tint: const Color(0xFFFFF2E7),
                      valueColor: const Color(0xFFFF6B4A),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MiniCard(
                      title: "Budget",
                      value: selectedBudget == "Mid Range"
                          ? r"$$"
                          : selectedBudget == "Budget Friendly"
                          ? r"$"
                          : r"$$$",
                      tint: const Color(0xFFEFFDF4),
                      valueColor: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Using your current location",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      text: "Back",
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _GradientButton(
                      text: "Start Swiping",
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                      ),
                      onTap: () {
                        // TODO: Navigate to Discover screen (swipe screen)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DiscoverScreen(),
                          ),
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Go to Discover Screen 🚀"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------- UI PARTS ------------------- */

class _ProgressPills extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressPills({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final step = i + 1;
        final isActive = step <= currentStep;

        return Expanded(
          child: Container(
            height: 8,
            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isActive
                  ? const Color(0xFFFF6B4A)
                  : const Color(0xFFE5E7EB),
            ),
          ),
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final Color tint;
  final Color valueColor;

  const _MiniCard({
    required this.title,
    required this.value,
    required this.tint,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GradientButton({
    required this.text,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: gradient,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
