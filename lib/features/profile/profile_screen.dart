import 'package:flutter/material.dart';
import '../../core/state/favorites_store.dart';
import '../discover/discover_screen.dart';
import '../favorites/favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
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
                    _ProfileCard(),
                    const SizedBox(height: 18),

                    const Text(
                      "Your Preferences",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),

                    _PrefTile(
                      icon: Icons.restaurant_menu,
                      title: "Cuisines",
                      value: "Japanese, Indian, Korean",
                      onTap: () {
                        // TODO: navigate to edit cuisines
                      },
                    ),
                    _PrefTile(
                      icon: Icons.local_fire_department_rounded,
                      title: "Spice Level",
                      value: "Medium",
                      onTap: () {
                        // TODO: navigate to spice screen
                      },
                    ),
                    _PrefTile(
                      icon: Icons.attach_money_rounded,
                      title: "Budget",
                      value: "\$\$",
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
                        // later: deep link to onboarding
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
                  ],
                ),
              ),
            ),

            // Bottom Nav
            _BottomNav(
              active: _NavItem.profile,
              onTap: (item) {
                if (item == _NavItem.discover) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                  );
                } else if (item == _NavItem.favorites) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                }
              },
            ),
          ],
        ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All data cleared")),
              );
            },
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}


//for profile card -- supporting UI parts

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(blurRadius: 18, offset: Offset(0, 10), color: Color(0x14000000)),
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
                const Text(
                  "Food Explorer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
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

//bottom naviagtion bar

enum _NavItem { discover, favorites, profile }

class _BottomNav extends StatelessWidget {
  final _NavItem active;
  final void Function(_NavItem) onTap;

  const _BottomNav({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavBtn(Icons.restaurant_menu, "Discover", _NavItem.discover),
          _NavBtn(Icons.favorite_border, "Favorites", _NavItem.favorites),
          _NavBtn(Icons.person_outline, "Profile", _NavItem.profile),
        ],
      ),
    );
  }

  Widget _NavBtn(IconData icon, String label, _NavItem item) {
    final activeBtn = active == item;

    if (!activeBtn) {
      return GestureDetector(
        onTap: () => onTap(item),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFF6B4A)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Color(0xFFFF6B4A), fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
