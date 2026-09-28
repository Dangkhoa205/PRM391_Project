import 'package:flutter_test/flutter_test.dart';
import 'package:la_boutique_mobile/main.dart';

void main() {
  testWidgets('LaBoutiqueApp smoke test builds main widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(const LaBoutiqueApp());
    expect(find.byType(LaBoutiqueApp), findsOneWidget);
  });
}
