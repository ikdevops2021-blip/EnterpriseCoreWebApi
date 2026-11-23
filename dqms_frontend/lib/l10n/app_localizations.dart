import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_as.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('ar'),
    Locale('hi'),
    Locale('as'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'DQMS Enterprise'**
  String get appTitle;

  /// No description provided for @commandCenter.
  ///
  /// In en, this message translates to:
  /// **'Command Center'**
  String get commandCenter;

  /// No description provided for @counterStation.
  ///
  /// In en, this message translates to:
  /// **'Counter Station'**
  String get counterStation;

  /// No description provided for @waitingRoomTV.
  ///
  /// In en, this message translates to:
  /// **'Waiting Room TV'**
  String get waitingRoomTV;

  /// No description provided for @selfServiceKiosk.
  ///
  /// In en, this message translates to:
  /// **'Self-Service Kiosk'**
  String get selfServiceKiosk;

  /// No description provided for @mobileTracker.
  ///
  /// In en, this message translates to:
  /// **'Mobile Tracker'**
  String get mobileTracker;

  /// No description provided for @ticketNumber.
  ///
  /// In en, this message translates to:
  /// **'Ticket Number'**
  String get ticketNumber;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceName;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @issued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get issued;

  /// No description provided for @waitTime.
  ///
  /// In en, this message translates to:
  /// **'Wait Time'**
  String get waitTime;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @callNext.
  ///
  /// In en, this message translates to:
  /// **'Call Next Ticket'**
  String get callNext;

  /// No description provided for @recall.
  ///
  /// In en, this message translates to:
  /// **'Recall'**
  String get recall;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold Ticket'**
  String get hold;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward / Route'**
  String get forward;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete Service'**
  String get complete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ticket'**
  String get cancel;

  /// No description provided for @issueTicket.
  ///
  /// In en, this message translates to:
  /// **'Issue Walk-in Ticket'**
  String get issueTicket;

  /// No description provided for @printTicket.
  ///
  /// In en, this message translates to:
  /// **'Print Ticket'**
  String get printTicket;

  /// No description provided for @activeTicket.
  ///
  /// In en, this message translates to:
  /// **'Active Serving Ticket'**
  String get activeTicket;

  /// No description provided for @waitingQueue.
  ///
  /// In en, this message translates to:
  /// **'Waiting Queue'**
  String get waitingQueue;

  /// No description provided for @noActiveTicket.
  ///
  /// In en, this message translates to:
  /// **'No Active Ticket Being Served'**
  String get noActiveTicket;

  /// No description provided for @noWaitingTickets.
  ///
  /// In en, this message translates to:
  /// **'No customers waiting in queue'**
  String get noWaitingTickets;

  /// Pipeline step progress string
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}: {stepName}'**
  String stepProgress(int current, int total, String stepName);

  /// Text to speech calling announcement
  ///
  /// In en, this message translates to:
  /// **'Token {tokenNumber}, please proceed to {counterName}'**
  String callingAnnouncement(String tokenNumber, String counterName);

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @statusCalling.
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get statusCalling;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusHold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get statusHold;

  /// No description provided for @statusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get statusCanceled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusForwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get statusForwarded;
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
      <String>['ar', 'as', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'as':
      return AppLocalizationsAs();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
