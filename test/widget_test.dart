import 'package:flutter_test/flutter_test.dart';

import 'package:vibra/main.dart';

void main() {
  testWidgets('VIBRA arranca y navega a la ruta inicial', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VibraApp());
    await tester.pump();

    expect(find.text('Hola'), findsOneWidget);
  });
}
