import 'package:flutter/material.dart';
import 'dietary_screen.dart';

class BudgetScreen extends StatefulWidget {
  final String selectedCuisinesLabel;
  final String selectedSpiceLabel;

  const BudgetScreen({
    super.key,
    required this.selectedCuisinesLabel,
    required this.selectedSpiceLabel,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String? _selected; // "Budget Friendly" | "Mid Range" | "Premium"

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Budget",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const _ProgressPills(currentStep: 4, totalSteps: 6),
              const SizedBox(height: 22),

              const Text(
                "What's your budget?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                "Set your preferred price range",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 22),

              _BudgetOptionCard(
                title: "Budget Friendly",
                subtitle: "Under \$10",
                leading: r"$",
                selected: _selected == "Budget Friendly",
                onTap: () => setState(() => _selected = "Budget Friendly"),
              ),
              const SizedBox(height: 14),
              _BudgetOptionCard(
                title: "Mid Range",
                subtitle: "\$10 - \$20",
                leading: r"$$",
                selected: _selected == "Mid Range",
                onTap: () => setState(() => _selected = "Mid Range"),
              ),
              const SizedBox(height: 14),
              _BudgetOptionCard(
                title: "Premium",
                subtitle: "\$20+",
                leading: r"$$$",
                selected: _selected == "Premium",
                onTap: () => setState(() => _selected = "Premium"),
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
                      text: "Continue",
                      enabled: canContinue,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A3D), Color(0xFFFF4D4D)], // CTA stays orange/red
                      ),
                      onTap: canContinue
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DietaryScreen(
                                    selectedBudget: _selected!,
                                    selectedCuisinesLabel: widget.selectedCuisinesLabel,
                                    selectedSpiceLabel: widget.selectedSpiceLabel,
                                  ),
                                ),
                              );
                            }
                          : null,
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

  const _ProgressPills({
    required this.currentStep,
    required this.totalSteps,
  });

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
              color: isActive ? const Color(0xFFFF6B4A) : const Color(0xFFE5E7EB),
            ),
          ),
        );
      }),
    );
  }
}

class _BudgetOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leading;
  final bool selected;
  final VoidCallback onTap;

  const _BudgetOptionCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? Colors.transparent : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                )
              : null,
          color: selected ? null : Colors.white,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: const [
            BoxShadow(
              blurRadius: 16,
              offset: Offset(0, 6),
              color: Color(0x11000000),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.15) : const Color(0xFFEFFDF4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    leading,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : const Color(0xFF16A34A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: selected ? Colors.white70 : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: selected ? Colors.white : const Color(0xFFE5E7EB),
                  ),
                ),
                child: selected
                    ? const Center(
                        child: CircleAvatar(radius: 6, backgroundColor: Colors.white),
                      )
                    : null,
              ),
            ],
          ),
        ),
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
  final VoidCallback? onTap;
  final bool enabled;
  final LinearGradient gradient;

  const _GradientButton({
    required this.text,
    required this.onTap,
    required this.enabled,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
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
      ),
    );
  }
}
