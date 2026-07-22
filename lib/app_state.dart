import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// 홈 화면 위젯이 읽어갈 값을 App Group에 써 둔다.
  /// 위젯이 없거나(안드로이드·테스트 환경) 실패해도 앱은 그대로 돌아가야 한다.
  Future<void> _publishToWidget() async {
    try {
      await HomeWidget.setAppGroupId('group.com.rogbook.focuscat');
      await HomeWidget.saveWidgetData<int>('todayCount', todaySuccessCount);
      await HomeWidget.saveWidgetData<int>(
        'totalMinutes',
        totalSuccessSeconds ~/ 60,
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
