import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'done_screen.dart';

class DietaryScreen extends StatefulWidget {
  final String selectedBudget;
  final String selectedCuisinesLabel;
  final String selectedSpiceLabel;

  const DietaryScreen({
    super.key,
    required this.selectedBudget,
    this.selectedCuisinesLabel = "All cuisines",
    this.selectedSpiceLabel = "Medium",
  });

  @override
  State<DietaryScreen> createState() => _DietaryScreenState();
}

class _DietaryScreenState extends State<DietaryScreen> {
  //currently using dietary-prefs railway deploy link replace with actual
  static const String _baseUrl = 'https://dietary-service-production-48d4.up.railway.app/dietary';

  static const String _prefsDietTypeKey = 'prefs.dietType';
  static const String _prefsAllergensKey = 'prefs.allergens';

  late Future<_DietaryOptions> _future;
  String? _selectedDietType;
  final Set<String> _selectedAllergens = {};

  @override
  void initState() {
    super.initState();
    _future = _fetchOptions();
  }

  Future<_DietaryOptions> _fetchOptions() async {
    final uri = Uri.parse('$_baseUrl/options');
    final headers = _buildAuthHeaders();
    final res = await http.get(uri, headers: headers).timeout(
      const Duration(seconds: 2),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load options (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return _DietaryOptions.fromJson(data);
  }

  /// Builds HTTP headers with AWS Cognito authentication.
  /// TODO: When Cognito is implemented:
  /// 1. Get the ID token from Cognito (via Amazon Cognito Identity SDK)
  /// 2. Add it to the Authorization header: "Authorization": "Bearer $idToken"
  /// 3. Replace the placeholder below with actual token retrieval
  Map<String, String> _buildAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      // TODO: Add Cognito ID token when auth is implemented
      // 'Authorization': 'Bearer $cognitoIdToken',
    };
  }

  void _toggleAllergen(String allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedDietType != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dietary preferences",
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
              const _ProgressPills(currentStep: 5, totalSteps: 6),
              const SizedBox(height: 22),

              const Text(
                "Any dietary preferences?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose your diet type and any allergens",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: FutureBuilder<_DietaryOptions>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // Use fallback data if API fails, or use fetched data
                    final options = snapshot.data ?? _DietaryOptions.fallback;
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Diet type (pick one)",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: options.dietType.map((opt) {
                              final selected = _selectedDietType == opt;
                              return ChoiceChip(
                                label: Text(opt),
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedDietType = opt),
                                selectedColor: const Color(0xFFFFF2E7),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? const Color(0xFFFF6B4A)
                                      : const Color(0xFF111827),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Allergens (optional)",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: options.allergens.map((opt) {
                              final selected = _selectedAllergens.contains(opt);
                              return FilterChip(
                                label: Text(opt),
                                selected: selected,
                                onSelected: (_) => _toggleAllergen(opt),
                                selectedColor: const Color(0xFFFFF2E7),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? const Color(0xFFFF6B4A)
                                      : const Color(0xFF111827),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
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
                      onTap: canContinue
                          ? () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString(
                                _prefsDietTypeKey,
                                _selectedDietType!,
                              );
                              final allergens = _selectedAllergens.toList()..sort();
                              await prefs.setStringList(
                                _prefsAllergensKey,
                                allergens,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoneScreen(
                                    selectedBudget: widget.selectedBudget,
                                    selectedCuisinesLabel: widget.selectedCuisinesLabel,
                                    selectedSpiceLabel: widget.selectedSpiceLabel,
                                    selectedDietType: _selectedDietType!,
                                    selectedAllergensLabel: _selectedAllergens.isEmpty
                                        ? "None"
                                        : _selectedAllergens.join(", "),
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

class _DietaryOptions {
  final List<String> dietType;
  final List<String> allergens;

  const _DietaryOptions({
    required this.dietType,
    required this.allergens,
  });

  factory _DietaryOptions.fromJson(Map<String, dynamic> json) {
    return _DietaryOptions(
      dietType: List<String>.from(json['dietType'] ?? const []),
      allergens: List<String>.from(json['allergens'] ?? const []),
    );
  }

  // Fallback data when API is unavailable
  static const _DietaryOptions fallback = _DietaryOptions(
    dietType: [
      'Omnivore',
      'Vegetarian',
      'Vegan',
      'Halal',
      'Kosher',
    ],
    allergens: [
      'Peanut',
      'Dairy',
      'Gluten',
      'Shellfish',
      'Soy',
      'Sesame',
      'Tree Nuts',
    ],
  );
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
              color: isActive ? const Color(0xFFFF6B4A) : const Color(0xFFE5E7EB),
            ),
          ),
        );
      }),
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
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.text,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A3D), Color(0xFFFF4D4D)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
