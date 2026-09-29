import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Sweezen App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SweezenApp());
  });
}
