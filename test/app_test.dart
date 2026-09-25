import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_lms/app.dart';
import 'package:thaheen_lms/features/courses/data/course_repository.dart';

import 'helpers/fixtures.dart';

void main() {
  const path = 'assets/data/courses.json';

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final bundle = FakeAssetBundle({path: catalogJson});
    await tester.pumpWidget(
      ThaheenApp(
        prefs: prefs,
        courseRepository: CourseRepository(bundle: bundle, assetPath: path),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('starts in Arabic with a right-to-left layout', (tester) async {
    await pumpApp(tester);

    expect(find.text('دوراتي'), findsOneWidget);
    expect(find.text('مقدمة في التشريح'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('دوراتي'))),
      TextDirection.rtl,
    );
  });

  testWidgets('tapping a locked lesson shows a friendly message', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('مقدمة في التشريح'));
    await tester.pumpAndSettle();
    expect(
      find.text('لم يبدأ'),
      findsOneWidget,
      reason: 'the first lesson is open and not started',
    );
    expect(
      find.text('مقفل'),
      findsOneWidget,
      reason: 'the second lesson is locked',
    );

    await tester.tap(find.text('المفاصل'));
    await tester.pump();

    expect(find.text('أكمل درس «العظام» أولاً لفتح هذا الدرس'), findsOneWidget);
  });
}
