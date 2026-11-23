// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'डीक्यूएमएस एंटरप्राइज';

  @override
  String get commandCenter => 'कमांड सेंटर';

  @override
  String get counterStation => 'काउंटर स्टेशन';

  @override
  String get waitingRoomTV => 'प्रतीक्षा कक्ष टीवी';

  @override
  String get selfServiceKiosk => 'स्वयं-सेवा कियोस्क';

  @override
  String get mobileTracker => 'मोबाइल ट्रैकर';

  @override
  String get ticketNumber => 'टोकन संख्या';

  @override
  String get serviceName => 'सेवा';

  @override
  String get counter => 'काउंटर';

  @override
  String get status => 'स्थिति';

  @override
  String get priority => 'प्राथमिकता';

  @override
  String get issued => 'जारी किया गया';

  @override
  String get waitTime => 'प्रतीक्षा समय';

  @override
  String get actions => 'कार्रवाई';

  @override
  String get callNext => 'अगला टोकन बुलाएं';

  @override
  String get recall => 'पुनः बुलाएं';

  @override
  String get hold => 'होल्ड करें';

  @override
  String get forward => 'आगे भेजें / रूट करें';

  @override
  String get complete => 'सेवा पूर्ण करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get issueTicket => 'नया टोकन जारी करें';

  @override
  String get printTicket => 'टोकन प्रिंट करें';

  @override
  String get activeTicket => 'वर्तमान सेवारत टोकन';

  @override
  String get waitingQueue => 'प्रतीक्षारत कतार';

  @override
  String get noActiveTicket => 'वर्तमान में कोई टोकन सेवारत नहीं है';

  @override
  String get noWaitingTickets => 'कतार में कोई ग्राहक प्रतीक्षारत नहीं है';

  @override
  String stepProgress(int current, int total, String stepName) {
    return 'चरण $current का $total: $stepName';
  }

  @override
  String callingAnnouncement(String tokenNumber, String counterName) {
    return 'टोकन $tokenNumber, कृपया काउंटर $counterName पर पधारें';
  }

  @override
  String get statusQueued => 'कतार में';

  @override
  String get statusWaiting => 'प्रतीक्षारत';

  @override
  String get statusCalling => 'बुलाया जा रहा है';

  @override
  String get statusActive => 'सक्रिय सेवा';

  @override
  String get statusHold => 'होल्ड पर';

  @override
  String get statusCanceled => 'रद्द किया गया';

  @override
  String get statusCompleted => 'पूर्ण';

  @override
  String get statusForwarded => 'आगे भेजा गया';
}
