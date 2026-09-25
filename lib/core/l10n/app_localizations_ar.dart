// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ذهين';

  @override
  String get coursesTitle => 'دوراتي';

  @override
  String get searchHint => 'ابحث عن دورة أو محاضر';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get noSearchResults => 'لا توجد دورات تطابق بحثك';

  @override
  String get continueWatching => 'تابع المشاهدة';

  @override
  String lessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس',
      many: '$count درسًا',
      few: '$count دروس',
      two: 'درسان',
      one: 'درس واحد',
      zero: 'لا توجد دروس',
    );
    return '$_temp0';
  }

  @override
  String percentComplete(int percent) {
    return 'مكتمل $percent٪';
  }

  @override
  String completedOfTotal(int done, int total) {
    return 'أكملت $done من $total';
  }

  @override
  String get statusNotStarted => 'لم يبدأ';

  @override
  String get statusInProgress => 'قيد المشاهدة';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusLocked => 'مقفل';

  @override
  String get lockedLessonMessage =>
      'هذا الدرس مقفل. أكمل الدرس السابق أولاً لفتحه';

  @override
  String get lockedLessonTitle => 'هذا الدرس غير متاح بعد';

  @override
  String lockedLessonFinishFirst(String lesson) {
    return 'أكمل درس «$lesson» أولاً لفتح هذا الدرس';
  }

  @override
  String get emptyCatalog => 'لا توجد دورات متاحة حاليًا';

  @override
  String get emptyCourse => 'لا يحتوي هذا المقرر على دروس بعد';

  @override
  String get emptySection => 'لا توجد دروس في هذا القسم بعد';

  @override
  String get catalogErrorTitle => 'تعذّر تحميل الدورات';

  @override
  String get catalogErrorMessage =>
      'حدث خطأ أثناء قراءة بيانات الدورات. حاول مرة أخرى.';

  @override
  String get courseNotFound => 'لم يتم العثور على هذا المقرر';

  @override
  String get lessonNotFound => 'لم يتم العثور على هذا الدرس';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get goBack => 'رجوع';

  @override
  String get videoErrorTitle => 'تعذّر تشغيل هذا الفيديو';

  @override
  String get videoErrorMessage => 'قد يكون ملف الفيديو مفقودًا أو تالفًا.';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get playbackSpeed => 'سرعة التشغيل';

  @override
  String get enterFullscreen => 'ملء الشاشة';

  @override
  String get exitFullscreen => 'الخروج من ملء الشاشة';

  @override
  String get nextLesson => 'الدرس التالي';

  @override
  String get nextLessonLockedHint => 'شاهد ٩٠٪ من هذا الدرس لفتح الدرس التالي';

  @override
  String get startCourse => 'ابدأ الدورة';

  @override
  String continueLesson(String lesson) {
    return 'تابع: $lesson';
  }

  @override
  String get watchAgain => 'شاهد الدورة من جديد';

  @override
  String get lessonCompleted => 'أحسنت! اكتمل هذا الدرس';

  @override
  String get courseCompleted => 'أحسنت! أكملت جميع دروس هذا المقرر 🎉';

  @override
  String get switchLanguage => 'English';

  @override
  String get toggleTheme => 'تبديل المظهر';

  @override
  String get moreOptions => 'خيارات إضافية';

  @override
  String get resetProgress => 'إعادة ضبط التقدم';

  @override
  String get resetProgressConfirm =>
      'سيتم حذف تقدمك في جميع الدروس. هل تريد المتابعة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get reset => 'إعادة الضبط';

  @override
  String get lessonNotesTitle => 'ملاحظاتي';

  @override
  String get lessonNotesHint => 'اكتب ملاحظاتك عن هذا الدرس…';

  @override
  String get lessonNotesSavedAutomatically => 'تُحفظ تلقائيًا';
}
