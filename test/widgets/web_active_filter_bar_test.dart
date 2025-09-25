// test/widgets/web_active_filter_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/widgets/web/web_active_filter_bar.dart';
import '../test_utils.dart';

void main() {
  testWidgets('WebActiveFilterBar - rend le label et les icônes', (tester) async {
    await pumpApp(
      tester,
      WebActiveFilterBar(
        label: 'Résultats pour "iPhone"',
        onClear: () {},
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Résultats pour "iPhone"'), findsOneWidget);
  });

  testWidgets('WebActiveFilterBar - tap sur close appelle onClear', (tester) async {
    var cleared = false;

    await pumpApp(
      tester,
      WebActiveFilterBar(
        label: 'Filtres actifs',
        onClear: () => cleared = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(cleared, isTrue);
  });

  testWidgets('WebActiveFilterBar - long label est ellipsé', (tester) async {
    const longLabel =
        'Un très très long libellé de filtre actif qui devrait être tronqué avec des points de suspension';

    await pumpApp(
      tester,
      Center(
        child: SizedBox(
          width: 220,
          child: WebActiveFilterBar(
            label: longLabel,
            onClear: () {},
          ),
        ),
      ),
    );

    final textFinder = find.text(longLabel);
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.overflow, TextOverflow.ellipsis);
  });

  testWidgets('WebActiveFilterBar - couleur de fond appliquée', (tester) async {
    await pumpApp(
      tester,
      WebActiveFilterBar(
        label: 'Test couleur',
        onClear: () {},
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    expect(container.color, isNotNull);
  });
}
