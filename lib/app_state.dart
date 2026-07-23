import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  static const _minutesKey = 'last_minutes';
  static const _adCounterKey = 'ad_counter';

  /// 몇 번마다 광고를 한 번 띄울지. 집중 앱에서 매번 광고는 거슬리므로
  /// 세션 3회마다 한 번만 보여준다.
  static const _adEvery = 3;

  /// 집중이 끝난 횟수(광고 주기용). 앱을 껐다 켜도 이어진다.
  int _adCounter = 0;

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
    _adCounter = prefs.getInt(_adCounterKey) ?? 0;
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
  }

  /// 집중이 한 번 끝났음을 세고, 이번에 광고를 띄울 차례면 true.
  /// 세 번째마다 참이 된다. 카운트는 영속화해 앱을 껐다 켜도 이어진다.
  Future<bool> shouldShowAdOnThisFinish() async {
    _adCounter++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_adCounterKey, _adCounter);
    return _adCounter % _adEvery == 0;
  }

  Future<void> setLastMinutes(int minutes) async {
    if (minutes == lastMinutes) return;
    lastMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_minutesKey, minutes);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_sessions.map((s) => s.toJson()).toList()),
    );
  }
}

/// 앱 전역에서 쓰는 단 하나의 상태.
final appState = AppState();
