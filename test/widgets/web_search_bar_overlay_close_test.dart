import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/widgets/web/web_search_bar.dart';
import '../test_utils.dart';

void main() {
  testWidgets('WebSearchBar - overlay se ferme au tap extérieur', (tester) async {
    await pumpApp(
      tester,
      Center(
        child: SizedBox(
          width: 400,
          child: WebSearchBar(
            hintText: 'Rechercher…',
            suggestions: const ['iPhone', 'Samsung', 'AirPods'],
            onSearchSelected: (_) {},
            onFilterPressed: () {},
          ),
        ),
      ),
    );

    final field = find.byType(TextField);

    await tester.tap(field);
    await tester.pumpAndSettle();

    await tester.enterText(field, 'iP');
    await tester.pumpAndSettle();

    expect(find.text('iPhone'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('iPhone'), findsNothing);
  });
}
