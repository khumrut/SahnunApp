import 'package:flutter_test/flutter_test.dart';
import 'package:sahnun_app/main.dart';

void main() {
  testWidgets('Sahnun App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SahnunApp());

    expect(find.text('SAHNUN'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
  });
}
