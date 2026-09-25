import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_lms/features/progress/data/progress_store.dart';
import 'package:thaheen_lms/features/progress/presentation/cubit/progress_cubit.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  const duration = Duration(seconds: 100);

  Future<ProgressCubit> freshCubit() async => ProgressCubit(
    ProgressStore(await SharedPreferences.getInstance()),
    clock: () => baseTime,
  );

  test('progress survives an app restart', () async {
    SharedPreferences.setMockInitialValues({});
    final before = await freshCubit();
    await before.recordPosition(
      courseId: 'c1',
      lessonId: 'l1',
      position: const Duration(seconds: 42),
      duration: duration,
    );
    await before.recordPosition(
      courseId: 'c1',
      lessonId: 'l2',
      position: const Duration(seconds: 95),
      duration: duration,
    );
    await before.close();

    // A new cubit reading the same storage is what the app sees after a restart.
    final after = await freshCubit();
    expect(after.state.of('c1', 'l1')?.position, const Duration(seconds: 42));
    expect(after.state.of('c1', 'l1')?.completed, isFalse);
    expect(after.state.of('c1', 'l2')?.completed, isTrue);
  });
}
