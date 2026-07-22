import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'ads.dart';
import 'app_state.dart';
import 'cat.dart';
import 'focus_timer.dart';
import 'l10n/app_localizations.dart';

/// 이 화면의 번역 문구. 기기 언어에 맞는 것이 자동으로 잡힌다.
AppLocalizations _t(BuildContext c) => AppLocalizations.of(c)!;

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
  static const _choices = [15, 25, 45, 60];

  /// 지난번에 고른 시간에서 이어서 시작한다.
  late int _minutes = appState.lastMinutes;

  /// 정해둔 시간 밖의 값일 때만 '직접' 칩에 그 값이 달린다.
  late int? _custom = _choices.contains(_minutes) ? null : _minutes;

  static const _minCustom = 1;
  static const _maxCustom = 180;

  Future<void> _pickCustom() async {
    final t = _t(context);
    var picked = _custom ?? _minutes;
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.customTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 180,
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: picked - _minCustom,
                  ),
                  onSelectedItemChanged: (i) => picked = i + _minCustom,
                  children: [
                    for (var m = _minCustom; m <= _maxCustom; m++)
                      Center(child: Text(t.minutes(m))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, picked),
                  child: Text(t.customConfirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      // 이미 있는 칩과 같은 시간을 골랐으면 그 칩을 고른 것으로 친다.
      // 안 그러면 같은 '15분' 칩이 둘 다 선택된 것처럼 보인다.
      _custom = _choices.contains(result) ? null : result;
      _minutes = result;
    });
    await appState.setLastMinutes(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = _t(context);
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
                  title: t.appTitle,
                  subtitle: done > 0 ? t.todayCount(done) : t.todayWaiting,
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
                          runSpacing: 8,
                          children: [
                            for (final m in _choices)
                              ChoiceChip(
                                label: Text(t.minutes(m)),
                                selected: _minutes == m,
                                // 테마에만 맡기면 선택 안 된 칩 글씨까지 흰색이
                                // 되어 흰 카드 위에서 사라진다.
                                labelStyle: TextStyle(
                                  color: _minutes == m
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                onSelected: (_) {
                                  setState(() => _minutes = m);
                                  appState.setLastMinutes(m);
                                },
                              ),
                            // 정해둔 시간 밖을 고르는 칩. 고르고 나면 그 시간을
                            // 그대로 라벨에 달아 다시 누르면 바꿀 수 있게 한다.
                            ChoiceChip(
                              label: Text(
                                _custom == null
                                    ? t.customChip
                                    : t.minutes(_custom!),
                              ),
                              selected: _custom != null && _minutes == _custom,
                              labelStyle: TextStyle(
                                color: _custom != null && _minutes == _custom
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) => _pickCustom(),
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
                            child: Text(t.startFocus),
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
  final _music = AudioPlayer();
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(_timer.tick);
      if (_timer.isFinished) _finish();
    });
    _startMusic();
    // 자동 잠금이 걸리면 앱이 백그라운드로 내려가 집중이 실패한다.
    // 폰을 내려놓고 집중하는 게 정상 사용이므로 이 화면에서만 화면을 켜둔다.
    WakelockPlus.enable();
  }

  /// 집중하는 동안만 lofi를 반복 재생한다. 음원이 없거나 오디오 장치가
  /// 없어도 집중 자체는 계속돼야 하므로 실패는 삼킨다.
  Future<void> _startMusic() async {
    try {
      await _music.setAsset('assets/lofi.mp3');
      await _music.setLoopMode(LoopMode.one);
      _music.play(); // 곡이 끝날 때까지 기다리므로 await 하지 않는다
    } catch (e) {
      debugPrint('MUSIC failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_timer.isFinished) return;
    if (state == AppLifecycleState.resumed) {
      _graceTimer?.cancel();
      _graceTimer = null;
      // 나가 있는 동안 tick이 멈췄으니 시계로 맞춘다. 유예 안에 돌아왔어도
      // 그 시간은 집중한 게 아니지만, 흐른 시간까지 되돌릴 수는 없다.
      setState(() {
        _timer.syncElapsed(DateTime.now().difference(_startedAt).inSeconds);
      });
      if (_timer.isFinished) _finish();
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
    _music.dispose();
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t(context);
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
              const SizedBox(height: 24),
              // 도서관처럼 소리를 낼 수 없는 곳도 있으니 끌 수 있어야 한다.
              IconButton(
                onPressed: () {
                  setState(() => _muted = !_muted);
                  _music.setVolume(_muted ? 0 : 1);
                },
                icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                color: kTeal,
                tooltip: _muted ? t.musicOn : t.musicOff,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _timer.abandon();
                  _finish();
                },
                child: Text(t.giveUp),
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
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.outcome});

  final FocusOutcome outcome;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // 광고는 집중이 끝난 뒤 여기서만 나온다. 집중 중에는 절대 띄우지 않는다.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Ads.instance.showIfReady(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _t(context);
    final outcome = widget.outcome;
    final success = outcome == FocusOutcome.success;
    final message = switch (outcome) {
      FocusOutcome.success => t.resultSuccess,
      FocusOutcome.abandoned => t.resultAbandoned,
      FocusOutcome.leftApp => t.resultLeftApp,
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
                  t.totalFocus((appState.totalSuccessSeconds / 60).floor()),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: Text(t.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
