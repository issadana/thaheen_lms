import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/l10n/l10n.dart';
import 'core/router/routes_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/courses/data/course_repository.dart';
import 'features/courses/presentation/cubit/courses_cubit.dart';
import 'features/notes/data/notes_store.dart';
import 'features/notes/presentation/cubit/notes_cubit.dart';
import 'features/progress/data/progress_store.dart';
import 'features/progress/presentation/cubit/progress_cubit.dart';
import 'features/settings/data/settings_store.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

class ThaheenApp extends StatefulWidget {
  const ThaheenApp({
    super.key,
    required this.prefs,
    required this.courseRepository,
  });

  final SharedPreferences prefs;
  final CourseRepository courseRepository;

  @override
  State<ThaheenApp> createState() => _ThaheenAppState();
}

class _ThaheenAppState extends State<ThaheenApp> {
  final _routes = RoutesManager();

  @override
  void dispose() {
    _routes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(SettingsStore(widget.prefs))),
        BlocProvider(create: (_) => ProgressCubit(ProgressStore(widget.prefs))),
        BlocProvider(create: (_) => NotesCubit(NotesStore(widget.prefs))),
        BlocProvider(
          create: (_) => CoursesCubit(widget.courseRepository)..load(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (a, b) => a.locale != b.locale || a.themeMode != b.themeMode,
        builder: (context, settings) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 350),
          themeAnimationCurve: Curves.easeInOut,
          routerConfig: _routes.router,
        ),
      ),
    );
  }
}
