import 'dart:convert';

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';

/// 성장 임계값(초). 플레이 테스트로 조정한다.
const int kTeenSeconds = 5 * 3600;
const int kAdultSeconds = 20 * 3600;

/// 고양이 성장 단계.
enum CatStage { baby, teen, adult }

/// 집중 세션 한 건의 기록.
class FocusSession {
  FocusSession({
    required this.startedAt,
    required this.durationSeconds,
    required this.success,
  });

  final DateTime startedAt;
  final int durationSeconds;
  final bool success;

  Map<String, dynamic> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'success': success,
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    startedAt: DateTime.parse(json['startedAt'] as String),
    durationSeconds: json['durationSeconds'] as int,
    success: json['success'] as bool,
  );
}

/// 앱 전체 상태. 세션 기록을 갖고, 거기서 성장 단계를 끌어낸다.
///
/// ponytail: 저장은 shared_preferences 에 JSON 한 덩어리.
/// 세션이 수천 건을 넘어 느려지면 Hive/Isar 로 옮긴다.
class AppState extends ChangeNotifier {
  static const _key = 'focus_sessions';
  static const _minutesKey = 'last_minutes';

  /// 마지막으로 고른 집중 시간(분). 앱을 껐다 켜도, 위젯에서 시작해도 이 값을 쓴다.
  int lastMinutes = 25;

  final List<FocusSession> _sessions = [];
  List<FocusSession> get sessions => List.unmodifiable(_sessions);

  /// 성공한 세션의 집중 시간 합계(초).
  int get totalSuccessSeconds => _sessions
      .where((s) => s.success)
      .fold(0, (sum, s) => sum + s.durationSeconds);

  CatStage get stage {
    final total = totalSuccessSeconds;
    if (total >= kAdultSeconds) return CatStage.adult;
    if (total >= kTeenSeconds) return CatStage.teen;
    return CatStage.baby;
  }

  /// 오늘 성공한 세션 수. 홈 화면 한 줄 표시에 쓴다.
  int get todaySuccessCount {
    final now = DateTime.now();
    return _sessions
        .where(
          (s) =>
              s.success &&
              s.startedAt.year == now.year &&
              s.startedAt.month == now.month &&
              s.startedAt.day == now.day,
        )
        .length;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    lastMinutes = prefs.getInt(_minutesKey) ?? 25;
    final raw = prefs.getString(_key);
    _sessions.clear();
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        // ponytail: 저장값이 깨져 있으면(포맷 변경, 손상 등) 빈 목록으로 시작한다.
        // 로깅 인프라가 없어 조용히 무시 — 앱이 시작 시 죽는 것보다 낫다.
        _sessions.addAll(
          decoded.map((e) => FocusSession.fromJson(e as Map<String, dynamic>)),
        );
      } catch (_) {
        _sessions.clear();
      }
    }
    notifyListeners();
    await _publishToWidget();
  }

  Future<void> setLastMinutes(int minutes) async {
    if (minutes == lastMinutes) return;
    lastMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_minutesKey, minutes);
  }

  /// 위젯에 보여줄 문구를 기기 언어로 만든다.
  ///
  /// 위젯(Swift·Kotlin)은 번역 파일을 따로 갖지 않고 여기서 만든 문장을 그대로
  /// 표시한다. 그래야 앱에 언어가 하나 늘 때 위젯이 저절로 따라온다.
  /// 대신 언어를 바꾼 뒤 앱을 한 번도 안 열면 위젯은 옛 언어로 남는다.
  Future<AppLocalizations> _localizations() {
    for (final device in PlatformDispatcher.instance.locales) {
      for (final supported in AppLocalizations.supportedLocales) {
        if (supported.languageCode == device.languageCode) {
          return AppLocalizations.delegate.load(supported);
        }
      }
    }
    return AppLocalizations.delegate.load(const Locale('en'));
  }

  /// 홈 화면 위젯이 읽어갈 값을 App Group에 써 둔다.
  /// 위젯이 없거나(안드로이드·테스트 환경) 실패해도 앱은 그대로 돌아가야 한다.
  Future<void> _publishToWidget() async {
    try {
      final t = await _localizations();
      final done = todaySuccessCount;
      await HomeWidget.setAppGroupId('group.com.rogbook.focuscat');
      await HomeWidget.saveWidgetData<String>(
        'message',
        done > 0 ? t.todayCount(done) : t.todayWaiting,
      );
      await HomeWidget.saveWidgetData<String>(
        'total',
        t.totalFocus(totalSuccessSeconds ~/ 60),
      );
      await HomeWidget.updateWidget(
        iOSName: 'FocusCatWidget',
        androidName: 'FocusCatWidgetProvider',
      );
    } catch (_) {}
  }

  Future<void> recordSession(FocusSession session) async {
    _sessions.add(session);
    await _save();
    notifyListeners();
  }

  Future<void> reset() async {
    _sessions.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    await _publishToWidget();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_sessions.map((s) => s.toJson()).toList()),
    );
  }
}

/// 앱 전역에서 쓰는 단 하나의 상태.
final appState = AppState();
