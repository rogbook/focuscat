/// 앱을 벗어난 뒤 실패로 판정하기까지의 유예 시간(초).
/// 0이면 즉시 실패. 오너 요청 시 이 값만 바꾸면 된다.
const int kGraceSeconds = 0;

/// 집중 세션이 끝난 이유.
enum FocusOutcome { success, abandoned, leftApp }

/// 집중 타이머의 규칙. Flutter를 모른다.
class FocusTimer {
  FocusTimer(this.durationSeconds) : assert(durationSeconds > 0);

  final int durationSeconds;
  int elapsedSeconds = 0;
  FocusOutcome? outcome;

  bool get isFinished => outcome != null;
  bool get isRunning => !isFinished;
  bool get succeeded => outcome == FocusOutcome.success;
  int get remainingSeconds => durationSeconds - elapsedSeconds;
  double get progress => elapsedSeconds / durationSeconds;

  void tick() {
    if (isFinished) return;
    elapsedSeconds++;
    if (elapsedSeconds >= durationSeconds) {
      elapsedSeconds = durationSeconds;
      outcome = FocusOutcome.success;
    }
  }

  void abandon() => _finish(FocusOutcome.abandoned);

  void leaveApp() => _finish(FocusOutcome.leftApp);

  void _finish(FocusOutcome reason) {
    if (isFinished) return;
    outcome = reason;
  }
}
