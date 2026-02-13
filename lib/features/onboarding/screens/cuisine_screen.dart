import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'spice_screen.dart';

class CuisineScreen extends StatefulWidget {
  const CuisineScreen({super.key});

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  static const String _baseUrl =
      'https://foods-service-production.up.railway.app';

  final Set<String> _selected = {};
  late Future<List<String>> _futureCuisines;

  @override
  void initState() {
    super.initState();
    _futureCuisines = _fetchCuisines();
  }

  Future<List<String>> _fetchCuisines() async {
    final uri = Uri.parse('$_baseUrl/api/cuisines');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load cuisines (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    if (data is List) {
      final cuisines = <String>[];
      for (final e in data) {
        final name = _extractCuisineName(e);
        if (name != null && name.trim().isNotEmpty) {
          cuisines.add(name.trim());
        }
      }
      return cuisines;
    }
    return const <String>[];
  }

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Choose cuisines",
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
              const _ProgressPills(currentStep: 2, totalSteps: 6),
              const SizedBox(height: 22),

              const Text(
                "What cuisines do you love?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                "Select all that apply",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _futureCuisines,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Couldn't load cuisines",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SecondaryButton(
                              text: "Retry",
                              onTap: () =>
                                  setState(() => _futureCuisines = _fetchCuisines()),
                            ),
                          ],
                        ),
                      );
                    }

                    final cuisines = snapshot.data ?? const <String>[];
                    if (cuisines.isEmpty) {
                      return const Center(
                        child: Text(
                          "No cuisines available.",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: cuisines.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 2.4,
                      ),
                      itemBuilder: (context, i) {
                        final name = cuisines[i];
                        final selected = _selected.contains(name);

                        return _CuisineTile(
                          name: name,
                          emoji: _emojiForCuisine(name),
                          isSelected: selected,
                          onTap: () => _toggle(name),
                        );
                      },
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
                          ? () {
                              final cuisinesLabel = _selected.join(", ");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SpiceScreen(
                                    selectedCuisinesLabel: cuisinesLabel,
                                  ),
                                ),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Selected: ${_selected.join(", ")}",
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

String _emojiForCuisine(String name) {
  switch (name.toLowerCase()) {
    case "japanese":
      return "🍣";
    case "indian":
      return "🍛";
    case "italian":
      return "🍕";
    case "thai":
      return "🍜";
    case "korean":
      return "🍱";
    case "mexican":
      return "🌮";
    case "vietnamese":
      return "🍲";
    case "chinese":
      return "🥡";
    case "mediterranean":
      return "🥙";
    case "western":
      return "🍔";
    default:
      return "🍽️";
  }
}

String? _extractCuisineName(dynamic raw) {
  if (raw is String) return raw;
  if (raw is Map) {
    final name = raw['name'] ??
        raw['label'] ??
        raw['cuisine'] ??
        raw['title'];
    if (name is String) return name;
  }
  return null;
}

/* ------------------- UI PARTS ------------------- */

class _ProgressPills extends StatelessWidget {
  final int currentStep; // 1-based
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

class _CuisineTile extends StatelessWidget {
  final String name;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _CuisineTile({
    required this.name,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              width: 2,
              color: isSelected ? const Color(0xFFFF6B4A) : const Color(0xFFE5E7EB),
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 6),
                color: Color(0x11000000),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFFFF6B4A), size: 22),
              ],
            ),
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

  const _GradientButton({
    required this.text,
    required this.onTap,
    required this.enabled,
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
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A3D), Color(0xFFFF4D4D)],
            ),
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

/* ------------------- MODEL ------------------- */

class _CuisineOption {
  final String name;
  final String emoji;

  const _CuisineOption(this.name, this.emoji);
}
