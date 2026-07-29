/// ============================================================================
/// DQMS Dart Enums — MANDATORY e_ PREFIX STANDARD
/// Maps to ConfigCategory & ConfigParameters tables in the database.
/// ============================================================================

/// Global Search Active Status: 0 -> Deactive | 1 -> Active | 2 -> All
enum e_ActiveSearchStatus {
  deactive(0),
  active(1),
  all(2);

  const e_ActiveSearchStatus(this.value);
  final int value;
}

/// Global Search Delete Status: 0 -> Not Deleted | 1 -> Deleted | 2 -> All
enum e_DeleteSearchStatus {
  notDeleted(0),
  deleted(1),
  all(2);

  const e_DeleteSearchStatus(this.value);
  final int value;
}

/// Maps to ConfigCategory = 18 (C_TOKEN_STATUS) in ConfigParameters table.
enum e_TokenStatus {
  queued(18001),
  waiting(18002),
  calling(18003),
  active(18004),
  hold(18005),
  canceled(18006),
  completed(18007),
  forwarded(18008);

  const e_TokenStatus(this.value);
  final int value;
}

/// Maps to ConfigCategory = 19 (C_PRIORITY_TIER) in ConfigParameters table.
enum e_PriorityTier {
  standard(19001),
  seniorCitizen(19002),
  disabled(19003),
  emergency(19004),
  vip(19005);

  const e_PriorityTier(this.value);
  final int value;
}

/// Maps to ConfigCategory = 20 (C_COUNTER_STATUS) in ConfigParameters table.
enum e_CounterStatus {
  idle(20001),
  serving(20002),
  breakMode(20003),
  offline(20004);

  const e_CounterStatus(this.value);
  final int value;
}

/// Maps to ConfigCategory = 21 (C_DISPLAY_TEMPLATE_TYPE) in ConfigParameters table.
enum e_DisplayTemplateType {
  gridView(21001),
  splitScreenVideo(21002),
  highDensityList(21003),
  audioVisualBanner(21004);

  const e_DisplayTemplateType(this.value);
  final int value;
}
