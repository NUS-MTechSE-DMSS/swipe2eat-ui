import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/food_item.dart';
import '../../core/state/favorites_store.dart';
import '../../core/services/preferences_service.dart';
import '../favorites/food_detail_screen.dart';
import '../auth/services/token_storage.dart';
import 'services/food_service.dart';

class DiscoverScreen extends StatefulWidget {
  final bool showBottomNav;
const DiscoverScreen({super.key, this.showBottomNav = true});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<FoodItem> _items = [];
  bool _loading = true;
  bool _isSubmittingSwipe = false;
  String? _error;
  int _lastDroppedInvalidIds = 0;

  int _topIndex = 0;

  // Defaults used when no local preferences are saved yet
  List<String> _selectedCuisines = ['Chinese', 'Thai', 'Western'];
  String _selectedBudget = 'low'; // 'low', 'medium', 'high'
  String _selectedSpice = 'Medium';
  String _selectedDietType = 'None';
  List<String> _selectedAllergens = const [];
  String _locationLabel = 'Your city';

  static const String _prefsCuisinesKey = 'prefs.cuisines';
  static const String _prefsBudgetKey = 'prefs.budget';
  static const String _prefsSpiceKey = 'prefs.spice';
  static const String _prefsDietTypeKey = 'prefs.dietType';
  static const String _prefsAllergensKey = 'prefs.allergens';

  // drag state
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0; // radians

  FoodItem? get _current =>
      _topIndex < _items.length ? _items[_topIndex] : null;

  @override
  void initState() {
    super.initState();
    _initLoad();
    
    // Listen for preferences updates and refresh food list
    PreferencesService.preferencesUpdated.addListener(_onPreferencesUpdated);
  }

  @override
  void dispose() {
    // Clean up the listener when the widget is disposed
    PreferencesService.preferencesUpdated.removeListener(_onPreferencesUpdated);
    super.dispose();
  }

  void _onPreferencesUpdated() {
    // Reload preferences and refresh food list
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _loadUserCityFromToken();
    await _loadPreferences();
    await _fetchFoods();
  }

  Future<void> _loadUserCityFromToken() async {
    try {
      final idToken = await TokenStorage.getIdToken();
      if (idToken == null || idToken.isEmpty) return;
      final parts = idToken.split('.');
      if (parts.length != 3) return;

      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is! Map) return;

      final city = (payload['custom:City'] ?? payload['city'])?.toString().trim();
      if (!mounted || city == null || city.isEmpty) return;

      setState(() {
        _locationLabel = city;
      });
    } catch (_) {
      // Keep fallback location label when city is unavailable.
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cuisines = prefs.getStringList(_prefsCuisinesKey);
    final budget = prefs.getString(_prefsBudgetKey);
    final spice = prefs.getString(_prefsSpiceKey);
    final dietType = prefs.getString(_prefsDietTypeKey);
    final allergens = prefs.getStringList(_prefsAllergensKey);
    if (!mounted) return;
    setState(() {
      if (cuisines != null && cuisines.isNotEmpty) {
        _selectedCuisines = cuisines;
      }
      if (budget != null && budget.trim().isNotEmpty) {
        _selectedBudget = budget.trim();
      }
      if (spice != null && spice.trim().isNotEmpty) {
        _selectedSpice = spice.trim();
      }
      if (dietType != null && dietType.trim().isNotEmpty) {
        _selectedDietType = dietType.trim();
      }
      if (allergens != null && allergens.isNotEmpty) {
        _selectedAllergens = allergens;
      }
    });
  }

  Future<void> _fetchFoods() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final foods = await FoodService.fetchFoods(
        cuisines: _selectedCuisines,
        budget: _selectedBudget,
        spiceLevel: _selectedSpice,
        dietType: _selectedDietType,
        allergens: _selectedAllergens,
      );
      setState(() {
        _items
          ..clear()
          ..addAll(foods);
        _topIndex = 0;
        _lastDroppedInvalidIds = FoodService.lastInvalidFoodIdDropCount;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _resetDrag() {
    setState(() {
      _dragOffset = Offset.zero;
      _dragRotation = 0;
    });
  }

  void _swipeLeft() {
    _completeSwipe(isRight: false);
  }

  void _swipeRight() {
    _completeSwipe(isRight: true);
  }

  Future<void> _completeSwipe({required bool isRight}) async {
    if (_isSubmittingSwipe) return;

    final item = _current;
    if (item == null) return;

    setState(() {
      _isSubmittingSwipe = true;
      _dragOffset = Offset.zero;
      _dragRotation = 0;
    });

    final synced = await PreferencesService.sendSwipePreference(
      foodId: item.id,
      liked: isRight,
    );

    if (!mounted) return;

    if (!synced) {
      setState(() {
        _isSubmittingSwipe = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save swipe. Please try again.'),
        ),
      );
      return;
    }

    if (isRight) {
      FavoritesStore.instance.add(item);
    }

    setState(() {
      _topIndex++;
      _dragOffset = Offset.zero;
      _dragRotation = 0;
      _isSubmittingSwipe = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _current;

    return Container(
      color: const Color(0xFFFFF8F1),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _TopBar(
            locationLabel: _locationLabel,
            onPlaceholderTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
          const SizedBox(height: 14),

          Expanded(
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : _error != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Couldn't load foods",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _fetchFoods,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: const Text(
                                  "Retry",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        )
                      : item == null
                          ? _items.isEmpty
                              ? _EmptyState(
                                  title: "No dishes available",
                                  subtitle: _lastDroppedInvalidIds > 0
                                      ? "Skipped $_lastDroppedInvalidIds dishes because of invalid data. Please try again shortly."
                                      : "No dishes match your current preferences right now.",
                                  onRetry: _fetchFoods,
                                )
                              : const Text(
                                  "No more dishes 🎉",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final cardWidth = min(
                                  constraints.maxWidth * 0.86,
                                  360.0,
                                );
                                final cardHeight = min(
                                  constraints.maxHeight * 0.82,
                                  560.0,
                                );

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (_topIndex + 1 < _items.length)
                                      Transform.scale(
                                        scale: 0.96,
                                        child: Opacity(
                                          opacity: 0.45,
                                          child: _FoodCard(
                                            item: _items[_topIndex + 1],
                                            width: cardWidth,
                                            height: cardHeight,
                                            showOverlay: false,
                                          ),
                                        ),
                                      ),

                                    GestureDetector(
                                      onTap: () {
                                        if (_isSubmittingSwipe) return;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                FoodDetailScreen(item: item),
                                          ),
                                        );
                                      },
                                      onPanUpdate: (d) {
                                        if (_isSubmittingSwipe) return;
                                        setState(() {
                                          _dragOffset += d.delta;
                                          _dragRotation =
                                              (_dragOffset.dx / 800) * 0.6;
                                        });
                                      },
                                      onPanEnd: (_) {
                                        if (_isSubmittingSwipe) return;
                                        final dx = _dragOffset.dx;
                                        if (dx > 120) {
                                          _swipeRight();
                                        } else if (dx < -120) {
                                          _swipeLeft();
                                        } else {
                                          _resetDrag();
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        curve: Curves.easeOut,
                                        transform: Matrix4.identity()
                                          ..translate(
                                              _dragOffset.dx, _dragOffset.dy)
                                          ..rotateZ(_dragRotation),
                                        child: _FoodCard(
                                          item: item,
                                          width: cardWidth,
                                          height: cardHeight,
                                          showOverlay: true,
                                          overlayDx: _dragOffset.dx,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
            ),
          ),

          const SizedBox(height: 6),
          _ActionRow(
            onNope: _swipeLeft,
            onLike: _swipeRight,
            enabled: !_isSubmittingSwipe && !_loading && item != null,
          ),
          const SizedBox(height: 10),

          if (widget.showBottomNav)
            _BottomNavMock(
              active: _NavItem.discover,
              onTap: (item) {
                // optional: keep old behavior if used standalone
              },
            ),
        ],
      ),
    );
  }
}

/* ------------------- TOP BAR ------------------- */

class _TopBar extends StatelessWidget {
  final String locationLabel;
  final VoidCallback onPlaceholderTap;

  const _TopBar({required this.locationLabel, required this.onPlaceholderTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: const Icon(Icons.restaurant, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Swipe2Eat",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locationLabel,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onPlaceholderTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.construction_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------- CARD ------------------- */

class _FoodCard extends StatelessWidget {
  final FoodItem item;
  final double width;
  final double height;

  final bool showOverlay;
  final double overlayDx;

  const _FoodCard({
    required this.item,
    required this.width,
    required this.height,
    required this.showOverlay,
    this.overlayDx = 0,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = showOverlay
        ? _SwipeOverlay(dx: overlayDx)
        : const SizedBox.shrink();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            blurRadius: 28,
            offset: Offset(0, 16),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Column(
              children: [
                // image
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(item.imageUrl, fit: BoxFit.cover),
                      ),
                      // rating badge
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // title overlay
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 14, color: Colors.black54),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.restaurant,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 14,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    item.distanceLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white70,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 14,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // details
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _SpiceIcons(level: item.spiceLevel),
                            const SizedBox(width: 12),
                            _BudgetIcons(level: item.budgetLevel),
                            const Spacer(),
                            Text(
                              "\$${item.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: item.tags
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF2E7),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    t,
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B4A),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // swipe overlay
            Positioned.fill(child: overlay),
          ],
        ),
      ),
    );
  }
}

class _SwipeOverlay extends StatelessWidget {
  final double dx; // drag x

  const _SwipeOverlay({required this.dx});

  @override
  Widget build(BuildContext context) {
    // right swipe => like
    // left swipe => nope
    final isRight = dx > 0;
    final strength = (dx.abs() / 160).clamp(0.0, 1.0);
    if (strength == 0) return const SizedBox.shrink();

    return IgnorePointer(
      child: Opacity(
        opacity: strength * 0.9,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRight
                  ? [const Color(0x3322C55E), const Color(0x00000000)]
                  : [const Color(0x33FF4D4D), const Color(0x00000000)],
              begin: isRight ? Alignment.centerLeft : Alignment.centerRight,
              end: Alignment.center,
            ),
          ),
          child: Align(
            alignment: isRight ? Alignment.topLeft : Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRight ? Icons.favorite : Icons.close,
                    color: isRight
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFFF4D4D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRight ? "LIKE" : "NOPE",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isRight
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------- ICON ROWS ------------------- */

class _SpiceIcons extends StatelessWidget {
  final int level; // 1..3
  const _SpiceIcons({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final on = i < level;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Icon(
            Icons.local_fire_department_rounded,
            size: 18,
            color: on ? const Color(0xFFFF6B4A) : const Color(0xFFE5E7EB),
          ),
        );
      }),
    );
  }
}

class _BudgetIcons extends StatelessWidget {
  final int level; // 1..3
  const _BudgetIcons({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final on = i < level;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            r"$",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: on ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
            ),
          ),
        );
      }),
    );
  }
}

/* ------------------- ACTIONS ------------------- */

class _ActionRow extends StatelessWidget {
  final VoidCallback onNope;
  final VoidCallback onLike;
  final bool enabled;

  const _ActionRow({
    required this.onNope,
    required this.onLike,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleAction(
            icon: Icons.close_rounded,
            iconColor: const Color(0xFFEF4444),
            onTap: enabled ? onNope : null,
          ),
          const SizedBox(width: 28),
          _CircleAction(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFFF6B4A),
            size: 74,
            onTap: enabled ? onLike : null,
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback? onTap;

  const _CircleAction({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.42),
      ),
      ),
    );
  }
}

/* ------------------- BOTTOM NAV (TEMP) ------------------- */

enum _NavItem { discover, favorites, profile }

class _BottomNavMock extends StatelessWidget {
  final _NavItem active;
  final void Function(_NavItem item) onTap;

  const _BottomNavMock({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.restaurant_menu,
            label: "Discover",
            active: active == _NavItem.discover,
            onTap: () => onTap(_NavItem.discover),
          ),
          _NavButton(
            icon: Icons.favorite_border,
            label: "Favorites",
            active: active == _NavItem.favorites,
            onTap: () => onTap(_NavItem.favorites),
          ),
          _NavButton(
            icon: Icons.person_outline,
            label: "Profile",
            active: active == _NavItem.profile,
            onTap: () => onTap(_NavItem.profile),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              "Retry",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w700,
              ),
            ),
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
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF6B4A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
