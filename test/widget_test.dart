import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verbum/main.dart';

void main() {
  testWidgets('Verbum app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VerbumApp(),
      ),
    );

    // Verify that the title VERBUM is rendered
    expect(find.text('VERBUM'), findsOneWidget);
  });
}
