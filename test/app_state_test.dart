import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focuscat/app_state.dart';

FocusSession _session({required int seconds, required bool success}) =>
    FocusSession(
      startedAt: DateTime(2026, 7, 20, 10),
      durationSeconds: seconds,
      success: success,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('성공한 세션만 누적 집중 시간에 들어간다', () async {
    final state = AppState();
    await state.load();
    await state.recordSession(_session(seconds: 600, success: true));
    await state.recordSession(_session(seconds: 900, success: false));
    expect(state.totalSuccessSeconds, 600);
    expect(state.sessions.length, 2);
  });

  test('누적 시간에 따라 성장 단계가 바뀐다', () async {
    final state = AppState();
    await state.load();
    expect(state.stage, CatStage.baby);

    await state.recordSession(_session(seconds: kTeenSeconds, success: true));
    expect(state.stage, CatStage.teen);

    await state.recordSession(
      _session(seconds: kAdultSeconds - kTeenSeconds, success: true),
    );
    expect(state.stage, CatStage.adult);
  });

  test('앱을 껐다 켜도 기록이 남아 있다', () async {
    final first = AppState();
    await first.load();
    await first.recordSession(_session(seconds: 1500, success: true));

    final second = AppState();
    await second.load();
    expect(second.sessions.length, 1);
    expect(second.totalSuccessSeconds, 1500);
    expect(second.sessions.first.durationSeconds, 1500);
    expect(second.sessions.first.success, isTrue);
  });

  test('세션을 기록하면 리스너에게 알린다', () async {
    final state = AppState();
    await state.load();
    var notified = 0;
    state.addListener(() => notified++);
    await state.recordSession(_session(seconds: 60, success: true));
    expect(notified, 1);
  });

  test('reset 하면 기록이 비워지고 저장에도 반영된다', () async {
    final state = AppState();
    await state.load();
    await state.recordSession(_session(seconds: 60, success: true));
    await state.reset();
    expect(state.sessions, isEmpty);

    final reloaded = AppState();
    await reloaded.load();
    expect(reloaded.sessions, isEmpty);
  });

  test('저장값이 JSON도 아니면 load()가 죽지 않고 빈 목록으로 시작한다', () async {
    SharedPreferences.setMockInitialValues({'focus_sessions': '이건 JSON이 아님'});
    final state = AppState();
    await state.load();
    expect(state.sessions, isEmpty);
  });

  test('저장값이 JSON이어도 항목 모양이 틀리면 빈 목록으로 시작한다', () async {
    SharedPreferences.setMockInitialValues({
      'focus_sessions':
          '[{"startedAt":"2026-07-20T10:00:00.000","success":true}]',
    });
    final state = AppState();
    await state.load();
    expect(state.sessions, isEmpty);
  });

  test('광고는 세 번째 집중마다 한 번만 뜬다', () async {
    final state = AppState();
    await state.load();
    final results = [
      for (var i = 0; i < 7; i++) await state.shouldShowAdOnThisFinish(),
    ];
    expect(results, [false, false, true, false, false, true, false]);
  });

  test('광고 카운트는 앱을 껐다 켜도 이어진다', () async {
    final a = AppState();
    await a.load();
    await a.shouldShowAdOnThisFinish(); // 1
    await a.shouldShowAdOnThisFinish(); // 2
    // 재시작 — 저장된 카운트를 이어받아 다음이 3번째가 되어야 한다.
    final b = AppState();
    await b.load();
    expect(await b.shouldShowAdOnThisFinish(), isTrue);
  });
}
