import 'dart:js_interop';

@JS('dqmsPlayChimeAndSpeak')
external void _dqmsPlayChimeAndSpeak(JSString text, JSString tokenNumber, JSString counterName, JSString nextTokenNumber);

@JS('dqmsUnlockAudio')
external void _dqmsUnlockAudio();

void playWebChimeAndSpeak(String text, String tokenNumber, String counterName, [String nextTokenNumber = '']) {
  try {
    _dqmsPlayChimeAndSpeak(text.toJS, tokenNumber.toJS, counterName.toJS, nextTokenNumber.toJS);
  } catch (_) {}
}

void unlockWebAudio() {
  try {
    _dqmsUnlockAudio();
  } catch (_) {}
}
