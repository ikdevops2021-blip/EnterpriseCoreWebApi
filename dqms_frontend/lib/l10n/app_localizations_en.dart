// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DQMS Enterprise';

  @override
  String get commandCenter => 'Command Center';

  @override
  String get counterStation => 'Counter Station';

  @override
  String get waitingRoomTV => 'Waiting Room TV';

  @override
  String get selfServiceKiosk => 'Self-Service Kiosk';

  @override
  String get mobileTracker => 'Mobile Tracker';

  @override
  String get ticketNumber => 'Ticket Number';

  @override
  String get serviceName => 'Service';

  @override
  String get counter => 'Counter';

  @override
  String get status => 'Status';

  @override
  String get priority => 'Priority';

  @override
  String get issued => 'Issued';

  @override
  String get waitTime => 'Wait Time';

  @override
  String get actions => 'Actions';

  @override
  String get callNext => 'Call Next Ticket';

  @override
  String get recall => 'Recall';

  @override
  String get hold => 'Hold Ticket';

  @override
  String get forward => 'Forward / Route';

  @override
  String get complete => 'Complete Service';

  @override
  String get cancel => 'Cancel Ticket';

  @override
  String get issueTicket => 'Issue Walk-in Ticket';

  @override
  String get printTicket => 'Print Ticket';

  @override
  String get activeTicket => 'Active Serving Ticket';

  @override
  String get waitingQueue => 'Waiting Queue';

  @override
  String get noActiveTicket => 'No Active Ticket Being Served';

  @override
  String get noWaitingTickets => 'No customers waiting in queue';

  @override
  String stepProgress(int current, int total, String stepName) {
    return 'Step $current of $total: $stepName';
  }

  @override
  String callingAnnouncement(String tokenNumber, String counterName) {
    return 'Token $tokenNumber, please proceed to $counterName';
  }

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusCalling => 'Calling';

  @override
  String get statusActive => 'Active';

  @override
  String get statusHold => 'On Hold';

  @override
  String get statusCanceled => 'Canceled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusForwarded => 'Forwarded';
}
