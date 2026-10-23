import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohammed_raqi_app/core/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('affiche le message et l\'icône', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.menu_book_outlined,
              message: 'لا توجد برامج متاحة حاليًا.',
            ),
          ),
        ),
      );

      expect(find.text('لا توجد برامج متاحة حاليًا.'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });

    testWidgets('affiche une autre icône et un autre message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.headphones_rounded,
              message: 'لا توجد رقيات متاحة حاليًا.',
            ),
          ),
        ),
      );

      expect(find.text('لا توجد رقيات متاحة حاليًا.'), findsOneWidget);
      expect(find.byIcon(Icons.headphones_rounded), findsOneWidget);
    });
  });
}