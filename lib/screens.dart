import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'cat.dart';
import 'focus_timer.dart';

/// Figma의 Todo 대시보드 시안에서 가져온 색.
/// (Mobile_app_design | Todo app, node 1:406)
const kTeal = Color(0xFF50C2C9);
const kBg = Color(0xFFF0F4F3);

String _mmss(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// 시안의 흰 카드 — 둥근 모서리에 옅은 그림자.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 시안 상단의 민트 밴드. 왼쪽 위 반투명 원 두 개까지 흉내낸다.
class _HeaderBand extends StatelessWidget {
  const _HeaderBand({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 220 + MediaQuery.paddingOf(context).top,
        width: double.infinity,
        color: kTeal,
        child: Stack(
          children: [
            Positioned(left: -100, top: -87, child: _circle(200)),
            Positioned(left: 0, top: -60, child: _circle(160)),
            Positioned(
              left: 25,
              right: 25,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Color(0x26FFFFFF),
      shape: BoxShape.circle,
    ),
  );
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
      // 민트 밴드가 상태바 밑까지 차야 해서 SafeArea로 감싸지 않는다.
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final done = appState.todaySuccessCount;
          // 밴드 · 고양이 · 카드를 Stack으로 떼어 놓는다. 한 Column에 Spacer로
          // 나누면 아래 카드 높이만큼 고양이가 위로 밀려 올라간다.
          // expand가 없으면 Stack이 Positioned만 가진 채 최소 크기로 쪼그라든다.
          return SizedBox.expand(
            child: Stack(
              children: [
                _HeaderBand(
                  title: '집중냥이',
                  subtitle: done > 0 ? '오늘 $done번 집중했어요' : '오늘 첫 집중을 기다리는 중',
                ),
                Positioned.fill(
                  child: Center(
                    child: CatView(
                      stage: appState.stage,
                      mood: done > 0 ? CatMood.happy : CatMood.idle,
                      size: 220,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24 + MediaQuery.paddingOf(context).bottom,
                  child: _Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            for (final m in _choices)
                              ChoiceChip(
                                label: Text('$m분'),
                                selected: _minutes == m,
                                // 테마에만 맡기면 선택 안 된 칩 글씨까지 흰색이
                                // 되어 흰 카드 위에서 사라진다.
                                labelStyle: TextStyle(
                                  color: _minutes == m
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) => setState(() => _minutes = m),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FocusScreen(minutes: _minutes),
                              ),
                            ),
                            child: const Text('집중 시작'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
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
      MaterialPageRoute(builder: (_) => ResultScreen(outcome: _timer.outcome!)),
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
        child: SizedBox(
          width: double.infinity,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CatView(
                  stage: appState.stage,
                  mood: success ? CatMood.happy : CatMood.sad,
                  size: 220,
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '누적 집중 ${(appState.totalSuccessSeconds / 60).floor()}분',
                  textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
