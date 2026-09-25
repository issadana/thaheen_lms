import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'ذهين'**
  String get appTitle;

  /// No description provided for @coursesTitle.
  ///
  /// In ar, this message translates to:
  /// **'دوراتي'**
  String get coursesTitle;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن دورة أو محاضر'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get clearSearch;

  /// No description provided for @noSearchResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دورات تطابق بحثك'**
  String get noSearchResults;

  /// No description provided for @continueWatching.
  ///
  /// In ar, this message translates to:
  /// **'تابع المشاهدة'**
  String get continueWatching;

  /// No description provided for @lessonCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد دروس} =1{درس واحد} =2{درسان} few{{count} دروس} many{{count} درسًا} other{{count} درس}}'**
  String lessonCount(int count);

  /// No description provided for @percentComplete.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل {percent}٪'**
  String percentComplete(int percent);

  /// No description provided for @completedOfTotal.
  ///
  /// In ar, this message translates to:
  /// **'أكملت {done} من {total}'**
  String completedOfTotal(int done, int total);

  /// No description provided for @statusNotStarted.
  ///
  /// In ar, this message translates to:
  /// **'لم يبدأ'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد المشاهدة'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// No description provided for @statusLocked.
  ///
  /// In ar, this message translates to:
  /// **'مقفل'**
  String get statusLocked;

  /// No description provided for @lockedLessonMessage.
  ///
  /// In ar, this message translates to:
  /// **'هذا الدرس مقفل. أكمل الدرس السابق أولاً لفتحه'**
  String get lockedLessonMessage;

  /// No description provided for @lockedLessonTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذا الدرس غير متاح بعد'**
  String get lockedLessonTitle;

  /// No description provided for @lockedLessonFinishFirst.
  ///
  /// In ar, this message translates to:
  /// **'أكمل درس «{lesson}» أولاً لفتح هذا الدرس'**
  String lockedLessonFinishFirst(String lesson);

  /// No description provided for @emptyCatalog.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دورات متاحة حاليًا'**
  String get emptyCatalog;

  /// No description provided for @emptyCourse.
  ///
  /// In ar, this message translates to:
  /// **'لا تحتوي هذه الدورة على دروس بعد'**
  String get emptyCourse;

  /// No description provided for @emptySection.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دروس في هذا القسم بعد'**
  String get emptySection;

  /// No description provided for @catalogErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الدورات'**
  String get catalogErrorTitle;

  /// No description provided for @catalogErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء قراءة بيانات الدورات. حاول مرة أخرى.'**
  String get catalogErrorMessage;

  /// No description provided for @courseNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على هذه الدورة'**
  String get courseNotFound;

  /// No description provided for @lessonNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على هذا الدرس'**
  String get lessonNotFound;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @videoErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل هذا الفيديو'**
  String get videoErrorTitle;

  /// No description provided for @videoErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'قد يكون ملف الفيديو مفقودًا أو تالفًا.'**
  String get videoErrorMessage;

  /// No description provided for @play.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف مؤقت'**
  String get pause;

  /// No description provided for @playbackSpeed.
  ///
  /// In ar, this message translates to:
  /// **'سرعة التشغيل'**
  String get playbackSpeed;

  /// No description provided for @enterFullscreen.
  ///
  /// In ar, this message translates to:
  /// **'ملء الشاشة'**
  String get enterFullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In ar, this message translates to:
  /// **'الخروج من ملء الشاشة'**
  String get exitFullscreen;

  /// No description provided for @nextLesson.
  ///
  /// In ar, this message translates to:
  /// **'الدرس التالي'**
  String get nextLesson;

  /// No description provided for @nextLessonLockedHint.
  ///
  /// In ar, this message translates to:
  /// **'شاهد 90٪ من هذا الدرس لفتح الدرس التالي'**
  String get nextLessonLockedHint;

  /// No description provided for @startCourse.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الدورة'**
  String get startCourse;

  /// No description provided for @continueLesson.
  ///
  /// In ar, this message translates to:
  /// **'تابع: {lesson}'**
  String continueLesson(String lesson);

  /// No description provided for @watchAgain.
  ///
  /// In ar, this message translates to:
  /// **'شاهد الدورة من جديد'**
  String get watchAgain;

  /// No description provided for @lessonCompleted.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! اكتمل هذا الدرس'**
  String get lessonCompleted;

  /// No description provided for @courseCompleted.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت! أكملت جميع دروس هذه الدورة 🎉'**
  String get courseCompleted;

  /// No description provided for @switchLanguage.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get switchLanguage;

  /// No description provided for @toggleTheme.
  ///
  /// In ar, this message translates to:
  /// **'تبديل المظهر'**
  String get toggleTheme;

  /// No description provided for @moreOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات إضافية'**
  String get moreOptions;

  /// No description provided for @resetProgress.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط التقدم'**
  String get resetProgress;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف تقدمك في جميع الدروس. هل تريد المتابعة؟'**
  String get resetProgressConfirm;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الضبط'**
  String get reset;

  /// No description provided for @lessonNotesTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتي'**
  String get lessonNotesTitle;

  /// No description provided for @lessonNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظاتك عن هذا الدرس…'**
  String get lessonNotesHint;

  /// No description provided for @lessonNotesSavedAutomatically.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ تلقائيًا'**
  String get lessonNotesSavedAutomatically;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
