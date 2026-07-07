import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sentrif/main.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Login screen renders SentriFi branding', (tester) async {
    await tester.pumpWidget(const SentrifApp());
    await tester.pump();

    expect(find.text('Sentri'), findsOneWidget);
    expect(find.text('Fi'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
