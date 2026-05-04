import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe2eat_ui/core/config/api_config.dart';
import 'package:swipe2eat_ui/features/auth/services/token_storage.dart';
import 'package:swipe2eat_ui/features/chat/screens/chat_screen.dart';

import '../../test_helpers/http_test_overrides.dart';

void main() {
  group('ChatScreen', () {
    late HttpTestOverrides httpOverrides;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      httpOverrides = HttpTestOverrides();
      HttpOverrides.global = httpOverrides;
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    Future<void> saveSession() {
      return TokenStorage.saveTokens(
        idToken: 'id-token',
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userId: 'user-123',
      );
    }

    Future<void> pumpChat(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the empty state before any message is sent', (
      tester,
    ) async {
      await pumpChat(tester);

      expect(find.text('Ask me for food recommendations!'), findsOneWidget);
      expect(
        find.text('e.g. "I want something spicy and cheap"'),
        findsOneWidget,
      );
    });

    testWidgets('ignores blank input without sending a message', (
      tester,
    ) async {
      await pumpChat(tester);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Ask me for food recommendations!'), findsOneWidget);
      expect(httpOverrides.requests, isEmpty);
    });

    testWidgets(
      'sends a message, shows loading state, and renders the AI reply',
      (tester) async {
        await saveSession();
        final blocker = Completer<void>();
        httpOverrides.addHandler(
          matcher: (request) =>
              request.method == 'POST' &&
              request.uri.toString() == ApiConfig.llmChatUrl,
          handler: (_) async {
            await blocker.future;
            return StubHttpResponse.json({
              'reply': 'Try the laksa.',
              'recommendations': [
                {
                  'name': 'Laksa',
                  'price': 8.9,
                  'spice_level': 3,
                  'cuisine': 'Malay',
                  'reasons': ['Spicy', 'Popular'],
                },
              ],
            });
          },
        );

        await pumpChat(tester);

        await tester.enterText(find.byType(TextField), 'Something spicy');
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();

        expect(find.text('Something spicy'), findsOneWidget);
        expect(find.text('Swipe2Eat AI is thinking...'), findsOneWidget);
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isFalse);
        expect(httpOverrides.requests, hasLength(1));

        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();
        expect(httpOverrides.requests, hasLength(1));

        blocker.complete();
        await tester.pumpAndSettle();

        expect(find.text('Try the laksa.'), findsOneWidget);
        expect(find.text('Laksa'), findsOneWidget);
        expect(find.text('Malay'), findsOneWidget);
        expect(find.text('8.90'), findsOneWidget);
        expect(find.text(' 3'), findsOneWidget);
        expect(find.text('Spicy · Popular'), findsOneWidget);
        expect(find.text('Swipe2Eat AI is thinking...'), findsNothing);
      },
    );

    testWidgets(
      'submits via keyboard action and renders non-success bot text',
      (tester) async {
        await pumpChat(tester);

        await tester.tap(find.byType(TextField));
        await tester.enterText(find.byType(TextField), 'Help');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.text('Help'), findsOneWidget);
        expect(
          find.text('Unable to send message: not logged in.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders backend failure text as a normal bot message', (
      tester,
    ) async {
      await saveSession();
      httpOverrides.addResponse(
        method: 'POST',
        url: ApiConfig.llmChatUrl,
        response: const StubHttpResponse(statusCode: 502, body: '{}'),
      );

      await pumpChat(tester);

      await tester.enterText(find.byType(TextField), 'Anything cheap?');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Anything cheap?'), findsOneWidget);
      expect(
        find.text('Something went wrong (502). Please try again.'),
        findsOneWidget,
      );
    });
  });
}
