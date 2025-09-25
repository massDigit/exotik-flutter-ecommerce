// test/widgets/web_search_bar_filter_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/widgets/web/web_search_bar.dart';
import '../test_utils.dart';

void main() {
  testWidgets('WebSearchBar - tap sur le bouton filtre appelle le callback', (tester) async {
    var pressed = false;

    await pumpApp(
      tester,
      WebSearchBar(
        hintText: 'Rechercher des produits…',
        suggestions: const ['iPhone', 'Samsung'],
        onSearchSelected: (_) {},
        onFilterPressed: () => pressed = true,
      ),
    );

    // Le suffixIcon est un IconButton avec l’icône "tune"
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
