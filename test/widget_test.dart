import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvyax/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArvyaXApp()));
    await tester.pump();
    expect(find.text('Ambiences'), findsOneWidget);
  });
}
