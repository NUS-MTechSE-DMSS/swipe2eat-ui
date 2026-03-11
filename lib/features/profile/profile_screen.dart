import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/state/favorites_store.dart';
import '../../core/services/preferences_service.dart';
import '../auth/services/token_storage.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;
  const ProfileScreen({super.key, this.showBottomNav = true});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = "Food Explorer";
  String _cuisinesDisplay = "Loading...";
  String _spiceDisplay = "Loading...";
  String _budgetDisplay = "Loading...";

  static const String _prefsCuisinesKey = 'prefs.cuisines';
  static const String _prefsBudgetKey = 'prefs.budget';
  static const String _prefsBudgetLabelKey = 'prefs.budgetLabel';
  static const String _prefsSpiceKey = 'prefs.spice';

  @override
  void initState() {
    super.initState();
    _loadUserNameFromToken();
    _loadPreferences();
    // Listen for preference updates
    PreferencesService.preferencesUpdated.addListener(_onPreferencesUpdated);
  }

  @override
  void dispose() {
    PreferencesService.preferencesUpdated.removeListener(_onPreferencesUpdated);
    super.dispose();
  }

  void _onPreferencesUpdated() {
    _loadPreferences();
  }

  Future<void> _loadUserNameFromToken() async {
    try {
      final idToken = await TokenStorage.getIdToken();
      if (idToken == null || idToken.isEmpty) return;

      final parts = idToken.split('.');
      if (parts.length != 3) return;

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is! Map) return;

      final name = (payload['name'] ?? payload['given_name'])
          ?.toString()
          .trim();
      if (!mounted || name == null || name.isEmpty) return;

      setState(() {
        _displayName = name;
      });
    } catch (_) {
      // Keep fallback display name when token name is unavailable.
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear all tokens
      await TokenStorage.clearTokens();

      // Clear favorites
      FavoritesStore.instance.clear();

      // Navigate to sign-in screen and remove all previous routes
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/sign-in', (route) => false);
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final cuisines = prefs.getStringList(_prefsCuisinesKey) ?? [];
    final budget =
        prefs.getString(_prefsBudgetLabelKey) ??
        prefs.getString(_prefsBudgetKey) ??
        "Not set";
    final spice = prefs.getString(_prefsSpiceKey) ?? "Not set";

    if (mounted) {
      setState(() {
        _cuisinesDisplay = cuisines.isNotEmpty
            ? cuisines.join(", ")
            : "Not set";
        _budgetDisplay = _getBudgetDisplay(budget);
        _spiceDisplay = spice;
      });
    }
  }

  String _getBudgetDisplay(String budget) {
    switch (budget.toLowerCase()) {
      case 'low':
      case 'budget friendly':
        return "\$";
      case 'medium':
      case 'mid range':
        return "\$\$";
      case 'high':
      case 'premium':
        return "\$\$\$";
      default:
        return budget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8F1),
      child: Column(
        children: [
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A3D), Color(0xFFFF4D4D)],
                    ),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileCard(displayName: _displayName),
                  const SizedBox(height: 18),

                  const Text(
                    "Your Preferences",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),

                  _PrefTile(
                    icon: Icons.restaurant_menu,
                    title: "Cuisines",
                    value: _cuisinesDisplay,
                    onTap: () {
                      // TODO: navigate to edit cuisines
                    },
                  ),
                  _PrefTile(
                    icon: Icons.local_fire_department_rounded,
                    title: "Spice Level",
                    value: _spiceDisplay,
                    onTap: () {
                      // TODO: navigate to spice screen
                    },
                  ),
                  _PrefTile(
                    icon: Icons.attach_money_rounded,
                    title: "Budget",
                    value: _budgetDisplay,
                    onTap: () {
                      // TODO: navigate to budget screen
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),

                  _ActionTile(
                    icon: Icons.edit_rounded,
                    title: "Edit Preferences",
                    onTap: () {
                      _showEditPreferencesDialog(context);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.restart_alt_rounded,
                    title: "Reset everything",
                    danger: true,
                    onTap: () {
                      _confirmReset(context);
                    },
                  ),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    danger: true,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset everything?"),
        content: const Text(
          "This will clear your preferences and favorites.\nYou cannot undo this.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FavoritesStore.instance.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("All data cleared")));
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditPreferencesDialog(BuildContext context) async {
    final prefs = await PreferencesService.getLocalPreferences();
    final currentCuisines = List<String>.from(prefs['cuisines'] ?? []);
    final currentBudget = prefs['budget'] ?? 'low';
    final sharedPrefs = await SharedPreferences.getInstance();
    final currentSpice = sharedPrefs.getString(_prefsSpiceKey);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => _PreferencesDialog(
        initialCuisines: currentCuisines,
        initialBudget: currentBudget,
        onSave: (cuisines, budget) async {
          // First, try to sync with backend
          final synced = await PreferencesService.updatePreferences(
            cuisines: cuisines,
            budget: budget,
            spiceLevel: currentSpice,
          );

          // If sync was successful, fetch latest preferences from backend
          if (synced) {
            await PreferencesService.fetchPreferencesFromBackend();
          } else {
            // Save locally if sync failed
            await PreferencesService.saveLocalPreferences(
              cuisines: cuisines,
              budget: budget,
              spiceLevel: currentSpice,
            );
          }

          if (context.mounted) {
            Navigator.pop(context); // Close dialog

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  synced
                      ? "Preferences updated and discover screen refreshed"
                      : "Preferences saved locally (sync failed)",
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

//for profile card -- supporting UI parts

class _ProfileCard extends StatelessWidget {
  final String displayName;

  const _ProfileCard({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A3D), Color(0xFFFF4D4D)],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder(
                  valueListenable: FavoritesStore.instance.favorites,
                  builder: (_, list, __) {
                    return Text(
                      "${list.length} favorites saved",
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PrefTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF6B4A)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : const Color(0xFF111827);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w900, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferencesDialog extends StatefulWidget {
  final List<String> initialCuisines;
  final String initialBudget;
  final Function(List<String> cuisines, String budget) onSave;

  const _PreferencesDialog({
    required this.initialCuisines,
    required this.initialBudget,
    required this.onSave,
  });

  @override
  State<_PreferencesDialog> createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<_PreferencesDialog> {
  late Set<String> _selectedCuisines;
  late String _selectedBudget;
  bool _saving = false;

  static const List<String> cuisineOptions = [
    'Thai',
    'Chinese',
    'Western',
    'Japanese',
    'Indian',
    'Italian',
    'Korean',
    'Vietnamese',
    'Mediterranean',
    'Malay',
    'Asian',
  ];

  static const List<String> budgetOptions = ['low', 'medium', 'high'];
  static const Map<String, String> budgetLabels = {
    'low': 'Budget Friendly',
    'medium': 'Mid Range',
    'high': 'Premium',
  };

  @override
  void initState() {
    super.initState();
    _selectedCuisines = Set.from(widget.initialCuisines);
    _selectedBudget = widget.initialBudget;
  }

  void _toggleCuisine(String cuisine) {
    setState(() {
      if (_selectedCuisines.contains(cuisine)) {
        _selectedCuisines.remove(cuisine);
      } else {
        _selectedCuisines.add(cuisine);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Preferences'),
      scrollable: true,
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cuisines',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cuisineOptions.map((cuisine) {
                  final selected = _selectedCuisines.contains(cuisine);
                  return FilterChip(
                    label: Text(cuisine),
                    selected: selected,
                    onSelected: (_) => _toggleCuisine(cuisine),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFFFF2E7),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFFFF6B4A)
                          : const Color(0xFF111827),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Budget',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: budgetOptions.map((budget) {
                  final selected = _selectedBudget == budget;
                  return FilterChip(
                    label: Text(budgetLabels[budget]!),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedBudget = budget),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFFFF2E7),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFFFF6B4A)
                          : const Color(0xFF111827),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  await widget.onSave(
                    _selectedCuisines.toList()..sort(),
                    _selectedBudget,
                  );
                },
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
