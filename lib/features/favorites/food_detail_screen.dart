import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../core/state/favorites_store.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem item;

  const FoodDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isFav = FavoritesStore.instance.contains(item.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            // Top image with back
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  _IconButtonBox(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _IconButtonBox(
                    icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    onTap: () {
                      if (isFav) {
                        FavoritesStore.instance.removeById(item.id);
                      } else {
                        FavoritesStore.instance.add(item);
                      }
                      // force rebuild by popping + pushing? (stateless)
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(blurRadius: 24, offset: Offset(0, 14), color: Color(0x22000000)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(item.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.restaurant,
                      style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _InfoChip(icon: Icons.star_rounded, text: item.rating.toStringAsFixed(1)),
                        const SizedBox(width: 10),
                        _InfoChip(icon: Icons.location_on_outlined, text: item.distanceLabel),
                        const Spacer(),
                        Text(
                          "\$${item.price.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: item.tags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2E7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B4A),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Description",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "A delicious pick based on your preferences. "
                      "Later we’ll plug in real descriptions from your data source/API.",
                      style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButtonBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonBox({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
