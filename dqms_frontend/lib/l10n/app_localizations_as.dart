// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String get appTitle => 'ডি কিউ এম এছ এণ্টাৰপ্ৰাইজ';

  @override
  String get commandCenter => 'কমাণ্ড চেণ্টাৰ';

  @override
  String get counterStation => 'কাউন্টাৰ ষ্টেচন';

  @override
  String get waitingRoomTV => 'প্ৰতীক্ষালয় টিভি';

  @override
  String get selfServiceKiosk => 'স্বয়ং-সেৱা কিঅ\'স্ক';

  @override
  String get mobileTracker => 'ম\'বাইল ট্ৰেকাৰ';

  @override
  String get ticketNumber => 'টোকেন নম্বৰ';

  @override
  String get serviceName => 'সেৱা';

  @override
  String get counter => 'কাউন্টাৰ';

  @override
  String get status => 'স্থিতি';

  @override
  String get priority => 'প্ৰাথমিকতা';

  @override
  String get issued => 'প্ৰদান কৰা হ\'ল';

  @override
  String get waitTime => 'প্ৰতীক্ষাৰ সময়';

  @override
  String get actions => 'কাৰ্য্য';

  @override
  String get callNext => 'পৰৱৰ্তী টোকেন মাতক';

  @override
  String get recall => 'পুনৰ মাতক';

  @override
  String get hold => 'স্থগিত ৰাখক';

  @override
  String get forward => 'আগবঢ়াওক / পথ নিৰ্দেশনা';

  @override
  String get complete => 'সেৱা সম্পূৰ্ণ কৰক';

  @override
  String get cancel => 'বাতিল কৰক';

  @override
  String get issueTicket => 'নতুন টোকেন প্ৰদান কৰক';

  @override
  String get printTicket => 'টোকেন প্ৰিণ্ট কৰক';

  @override
  String get activeTicket => 'বৰ্তমানৰ সেৱা প্ৰাপ্ত টোকেন';

  @override
  String get waitingQueue => 'প্ৰতীক্ষাত থকা শাৰী';

  @override
  String get noActiveTicket => 'বৰ্তমান কোনো টোকেনৰ সেৱা চলা নাই';

  @override
  String get noWaitingTickets => 'শাৰীত কোনো গ্ৰাহক প্ৰতীক্ষাত নাই';

  @override
  String stepProgress(int current, int total, String stepName) {
    return 'স্তৰ $current ৰ $total: $stepName';
  }

  @override
  String callingAnnouncement(String tokenNumber, String counterName) {
    return 'টোকেন $tokenNumber, অনুগ্ৰহ কৰি কাউন্টাৰ $counterName লৈ যাওক';
  }

  @override
  String get statusQueued => 'শাৰীত অন্তৰ্ভুক্ত';

  @override
  String get statusWaiting => 'প্ৰতীক্ষাত';

  @override
  String get statusCalling => 'মতা হৈছে';

  @override
  String get statusActive => 'সক্ৰিয় সেৱা';

  @override
  String get statusHold => 'স্থগিত';

  @override
  String get statusCanceled => 'বাতিল';

  @override
  String get statusCompleted => 'সম্পূৰ্ণ';

  @override
  String get statusForwarded => 'আগবঢ়োৱা হ\'ল';
}
