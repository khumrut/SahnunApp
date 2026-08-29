import 'package:flutter_test/flutter_test.dart';
import 'package:sahnun_app/main.dart';

void main() {
  testWidgets('Sahnun App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const SahnunApp());

    expect(find.text('S'), findsOneWidget);
  });
}
