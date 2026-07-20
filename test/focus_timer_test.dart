import 'package:flutter_test/flutter_test.dart';
import 'package:focuscat/focus_timer.dart';

void main() {
  test('지정 시간만큼 tick 하면 성공으로 끝난다', () {
    final t = FocusTimer(3);
    expect(t.isRunning, isTrue);
    t.tick();
    t.tick();
    expect(t.outcome, isNull);
    expect(t.remainingSeconds, 1);
    t.tick();
    expect(t.outcome, FocusOutcome.success);
    expect(t.succeeded, isTrue);
    expect(t.isRunning, isFalse);
    expect(t.isFinished, isTrue);
  });

  test('포기하면 abandoned 로 끝나고 성공이 아니다', () {
    final t = FocusTimer(60);
    t.tick();
    t.abandon();
    expect(t.outcome, FocusOutcome.abandoned);
    expect(t.succeeded, isFalse);
    expect(t.isRunning, isFalse);
  });

  test('앱을 벗어나면 leftApp 으로 끝난다', () {
    final t = FocusTimer(60);
    t.leaveApp();
    expect(t.outcome, FocusOutcome.leftApp);
    expect(t.succeeded, isFalse);
  });

  test('끝난 뒤의 tick 과 포기는 결과를 덮어쓰지 않는다', () {
    final t = FocusTimer(1);
    t.tick();
    expect(t.outcome, FocusOutcome.success);
    t.tick();
    t.abandon();
    t.leaveApp();
    expect(t.outcome, FocusOutcome.success);
    expect(t.elapsedSeconds, 1);
  });

  test('progress 는 0.0 에서 1.0 사이로 진행한다', () {
    final t = FocusTimer(4);
    expect(t.progress, 0.0);
    t.tick();
    t.tick();
    expect(t.progress, 0.5);
    t.tick();
    t.tick();
    expect(t.progress, 1.0);
  });

  test('유예 시간 상수는 0초다', () {
    expect(kGraceSeconds, 0);
  });
}
