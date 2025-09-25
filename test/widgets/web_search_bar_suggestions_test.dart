import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/widgets/web/web_search_bar.dart';
import '../test_utils.dart';

void main() {
  testWidgets('WebSearchBar - affiche les suggestions et sélection au tap',
          (tester) async {
        String? received;

        await pumpApp(
          tester,
          WebSearchBar(
            hintText: 'Rechercher des produits…',
            suggestions: const ['iPhone', 'Samsung', 'AirPods'],
            onSearchSelected: (s) => received = s,
            onFilterPressed: () {},
          ),
        );

        final field = find.byType(TextField);
        await tester.tap(field);
        await tester.pumpAndSettle();

        await tester.enterText(field, 'iPh');
        await tester.pumpAndSettle();

        expect(find.text('iPhone'), findsOneWidget);

        await tester.tap(find.text('iPhone'));
        await tester.pumpAndSettle();

        expect(received, 'iPhone');

        expect(find.text('Samsung'), findsNothing);
        expect(find.text('AirPods'), findsNothing);
      });
}
