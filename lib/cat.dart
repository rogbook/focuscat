import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'app_state.dart';

/// 고양이 표정.
enum CatMood { idle, focused, happy, sad }

/// 성장 단계와 기분에 따라 달라지는 고양이.
///
/// Rive 아트(assets/cat.riv)로 그린다. 이 파일엔 기분(mood) 상태가 없어
/// [mood]는 받기만 하고 아직 화면엔 반영하지 않는다 — 아래 주석 참고.
class CatView extends StatelessWidget {
  const CatView({
    super.key,
    required this.stage,
    required this.mood,
    this.size = 200,
  });

  final CatStage stage;
  final CatMood mood;
  final double size;

  /// 성장할수록 몸집이 커진다. 옛 CustomPainter와 같은 비율.
  double get _scale => switch (stage) {
        CatStage.baby => 0.7,
        CatStage.teen => 0.85,
        CatStage.adult => 1.0,
      };

  @override
  Widget build(BuildContext context) {
    // ponytail: mood는 받아서 유지만 한다. 공급받은 cat.riv에는
    // happy/sad/focused 같은 기분 상태가 없어(Idle, Blink 애니메이션뿐)
    // 지금은 표정을 그릴 수 없다. 색 필터나 회전으로 흉내내면 어색해 보이므로
    // 하지 않는다 — 기분을 담은 .riv가 새로 오면 여기서 상태를 골라 재생한다.
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: size * _scale,
          height: size * _scale,
          child: const RiveAnimation.asset(
            'assets/cat.riv',
            artboard: 'Cat',
            // 상태 머신 대신 애니메이션을 직접 재생한다: 상태 머신은 포인터
            // 좌표로 눈동자를 조준하는데, 폰엔 마우스가 없어 좌표를 안 주면
            // 구석을 응시한 채 멈춰 보인다. Idle을 기본으로 깔고 Blink를
            // 얹어 자연스럽게 깜빡이게 한다.
            animations: ['Idle', 'Blink'],
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
