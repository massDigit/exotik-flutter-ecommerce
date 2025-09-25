import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/widgets/web/web_search_bar.dart';
import '../test_utils.dart';

void main() {
  testWidgets('WebSearchBar - submit déclenche onSearchSelected', (tester) async {
    String? received;

    await pumpApp(
      tester,
      WebSearchBar(
        hintText: 'Rechercher des produits…',
        suggestions: const ['iPhone', 'Samsung'],
        onSearchSelected: (s) => received = s,
        onFilterPressed: () {}, // noop
      ),
    );

    final field = find.byType(TextField);
    expect(field, findsOneWidget);

    await tester.tap(field);
    await tester.pump();

    await tester.enterText(field, 'iPhone 15 Pro');

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(received, 'iPhone 15 Pro');
  });
}
