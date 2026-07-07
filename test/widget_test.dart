import 'package:flutter_test/flutter_test.dart';
import 'package:sentrif/main.dart';

void main() {
  testWidgets('Login screen renders SentriFi branding', (tester) async {
    await tester.pumpWidget(const SentrifApp());
    await tester.pump();

    expect(find.text('S'), findsOneWidget);
    expect(find.text('Secure. Smart. SentriFi.'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
