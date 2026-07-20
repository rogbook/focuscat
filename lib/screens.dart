import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'cat.dart';
import 'focus_timer.dart';

String _mmss(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// 홈 — 고양이를 보고 집중 시간을 골라 시작한다. 광고 없음.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _minutes = 25;
  static const _choices = [15, 25, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            final done = appState.todaySuccessCount;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CatView(
                  stage: appState.stage,
                  mood: done > 0 ? CatMood.happy : CatMood.idle,
                  size: 220,
                ),
                const SizedBox(height: 12),
                Text(
                  done > 0 ? '오늘 $done번 집중했어요' : '오늘 첫 집중을 기다리는 중',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in _choices)
                      ChoiceChip(
                        label: Text('$m분'),
                        selected: _minutes == m,
                        onSelected: (_) => setState(() => _minutes = m),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FocusScreen(minutes: _minutes),
                    ),
                  ),
                  child: const Text('집중 시작'),
                ),
                const SizedBox(height: 48),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 집중 중 — 남은 시간과 고양이. 광고 절대 없음. 앱을 벗어나면 실패.
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, required this.minutes});

  final int minutes;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with WidgetsBindingObserver {
  late final FocusTimer _timer = FocusTimer(widget.minutes * 60);
  late final DateTime _startedAt = DateTime.now();
  Timer? _ticker;
  Timer? _graceTimer;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(_timer.tick);
      if (_timer.isFinished) _finish();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_timer.isFinished) return;
    if (state == AppLifecycleState.resumed) {
      _graceTimer?.cancel();
      _graceTimer = null;
      return;
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (kGraceSeconds == 0) {
        _timer.leaveApp();
        _finish();
      } else {
        // hidden → paused 처럼 연속으로 올 수 있어, 이전 유예 타이머를 먼저 끊는다.
        _graceTimer?.cancel();
        _graceTimer = Timer(const Duration(seconds: kGraceSeconds), () {
          if (!_timer.isFinished) {
            _timer.leaveApp();
            _finish();
          }
        });
      }
    }
  }

  Future<void> _finish() async {
    if (_isFinishing) return;
    _isFinishing = true;
    _ticker?.cancel();
    _graceTimer?.cancel();
    await appState.recordSession(
      FocusSession(
        startedAt: _startedAt,
        durationSeconds: _timer.elapsedSeconds,
        success: _timer.succeeded,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(outcome: _timer.outcome!),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _graceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            CatView(stage: appState.stage, mood: CatMood.focused, size: 200),
            const SizedBox(height: 32),
            Text(
              _mmss(_timer.remainingSeconds),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 240,
              child: LinearProgressIndicator(value: _timer.progress),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _timer.abandon();
                _finish();
              },
              child: const Text('포기하기'),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

/// 결과 — 성공하면 뿌듯하게, 실패해도 나무라지 않는다.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.outcome});

  final FocusOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final success = outcome == FocusOutcome.success;
    final message = switch (outcome) {
      FocusOutcome.success => '집중 완료! 고양이가 뿌듯해해요',
      FocusOutcome.abandoned => '괜찮아요. 다음에 또 해봐요',
      FocusOutcome.leftApp => '집중이 끊겼어요. 다시 해볼까요?',
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CatView(
              stage: appState.stage,
              mood: success ? CatMood.happy : CatMood.sad,
              size: 220,
            ),
            const SizedBox(height: 24),
            Text(message, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '누적 집중 ${(appState.totalSuccessSeconds / 60).floor()}분',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
