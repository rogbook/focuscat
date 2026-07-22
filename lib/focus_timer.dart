/// 앱을 벗어난 뒤 실패로 판정하기까지의 유예 시간(초).
///
/// 0이면 즉시 실패. 25초인 이유: 알림을 잘못 눌렀거나 짧은 전화처럼
/// 집중을 그만둔 게 아닌 이탈까지 실패로 치면 억울하다. 그 이상 나가
/// 있으면 다른 일을 하는 것으로 본다.
const int kGraceSeconds = 25;

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

  /// 흘러간 시간을 [seconds]로 맞춘다.
  ///
  /// 백그라운드에서는 tick이 멈추므로, 돌아왔을 때 시계로 잰 실제 경과와
  /// 어긋난다. 되감기지는 않는다 — 시계가 뒤로 갔다고 집중이 늘어날 수는 없다.
  void syncElapsed(int seconds) {
    if (isFinished || seconds <= elapsedSeconds) return;
    elapsedSeconds = seconds;
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
