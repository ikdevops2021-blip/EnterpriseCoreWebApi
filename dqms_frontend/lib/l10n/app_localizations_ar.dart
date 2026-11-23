// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام إدارة قوائم الانتظار دي كيو إم إس';

  @override
  String get commandCenter => 'مركز القيادة والتحكم';

  @override
  String get counterStation => 'محطة الشباك';

  @override
  String get waitingRoomTV => 'شاشة صالة الانتظار';

  @override
  String get selfServiceKiosk => 'كشك الخدمة الذاتية';

  @override
  String get mobileTracker => 'تتبع التذكرة عبر الهاتف';

  @override
  String get ticketNumber => 'رقم التذكرة';

  @override
  String get serviceName => 'الخدمة';

  @override
  String get counter => 'الشباك';

  @override
  String get status => 'الحالة';

  @override
  String get priority => 'الأولوية';

  @override
  String get issued => 'وقت الإصدار';

  @override
  String get waitTime => 'مدة الانتظار';

  @override
  String get actions => 'الإجراءات';

  @override
  String get callNext => 'نداء التذكرة التالية';

  @override
  String get recall => 'إعادة النداء';

  @override
  String get hold => 'تعليق التذكرة';

  @override
  String get forward => 'تحويل التذكرة';

  @override
  String get complete => 'إكمال الخدمة';

  @override
  String get cancel => 'إلغاء التذكرة';

  @override
  String get issueTicket => 'إصدار تذكرة جديدة';

  @override
  String get printTicket => 'طباعة التذكرة';

  @override
  String get activeTicket => 'التذكرة قيد الخدمة الحالية';

  @override
  String get waitingQueue => 'قائمة الانتظار';

  @override
  String get noActiveTicket => 'لا توجد تذكرة قيد الخدمة الآن';

  @override
  String get noWaitingTickets => 'لا يوجد مراجعون في قائمة الانتظار';

  @override
  String stepProgress(int current, int total, String stepName) {
    return 'المرحلة $current من $total: $stepName';
  }

  @override
  String callingAnnouncement(String tokenNumber, String counterName) {
    return 'تذكرة رقم $tokenNumber، يرجى التوجه إلى شباك $counterName';
  }

  @override
  String get statusQueued => 'في الانتظار';

  @override
  String get statusWaiting => 'بانتظار النداء';

  @override
  String get statusCalling => 'يتم النداء';

  @override
  String get statusActive => 'قيد الخدمة';

  @override
  String get statusHold => 'معلقة';

  @override
  String get statusCanceled => 'ملغاة';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusForwarded => 'محولة';
}
