import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe2eat_ui/core/widgets/loading_placeholder.dart';

void main() {
  group('SkeletonBox', () {
    testWidgets('renders with the configured dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonBox(width: 120, height: 48)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints, isNotNull);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });
  });

  group('AppNetworkImage', () {
    testWidgets('default loadingBuilder returns the built-in placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              imageUrl: 'https://images.example.com/dish.png',
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final context = tester.element(find.byType(Image));
      final loadingWidget = image.loadingBuilder!(
        context,
        const SizedBox.shrink(),
        const ImageChunkEvent(cumulativeBytesLoaded: 1, expectedTotalBytes: 10),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: loadingWidget)));

      expect(find.byIcon(Icons.restaurant_menu_rounded), findsOneWidget);
      expect(find.byType(SkeletonBox), findsOneWidget);
    });

    testWidgets('default errorBuilder returns the built-in error placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppNetworkImage(
              imageUrl: 'https://images.example.com/broken.png',
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final context = tester.element(find.byType(Image));
      final errorWidget = image.errorBuilder!(
        context,
        Exception('broken'),
        StackTrace.empty,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: errorWidget)));

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    testWidgets(
      'uses custom placeholder and custom error widgets when provided',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppNetworkImage(
                imageUrl: 'https://images.example.com/slow.png',
                placeholder: Text('Custom placeholder'),
                errorPlaceholder: Text('Custom error'),
              ),
            ),
          ),
        );

        final image = tester.widget<Image>(find.byType(Image));
        final context = tester.element(find.byType(Image));

        final loadingWidget = image.loadingBuilder!(
          context,
          const SizedBox.shrink(),
          const ImageChunkEvent(
            cumulativeBytesLoaded: 1,
            expectedTotalBytes: 10,
          ),
        );
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: loadingWidget)),
        );
        expect(find.text('Custom placeholder'), findsOneWidget);

        final errorWidget = image.errorBuilder!(
          context,
          Exception('broken'),
          StackTrace.empty,
        );
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: errorWidget)));
        expect(find.text('Custom error'), findsOneWidget);
      },
    );
  });
}
