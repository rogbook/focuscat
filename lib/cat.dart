import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// LinearGradient는 flutter/material 쪽과 이름이 겹쳐 접두사가 필요하다.
import 'package:rive/rive.dart' as rive show LinearGradient;

import 'app_state.dart';

/// cat.riv에 박혀 있는 배경 사각형을 지운다.
///
/// 배경은 두 겹이다: 주황 그라디언트 `BG`와 그 위의 빨간 `HitArea`
/// (원래 탭 영역용인데 투명하게 안 만들고 내보낸 듯하다). 아트보드 자체
/// 채우기까지 셋 다 끈다.
///
/// rive 0.13.20엔 컴포넌트를 지우는 API가 없고, Shape.opacity = 0 과
/// Fill.isVisible = false 는 화면에 반영되지 않는다(직접 확인).
///
/// 아래 네 가지를 한꺼번에 건다. 하나씩 빼며 실제 화면으로 확인해 봤는데
/// 어느 하나만으로는 배경이 다 지워지지 않았다 — 채우기 종류마다 먹히는
/// 경로가 다르다. 이건 이 .riv 하나를 위한 임시방편이므로 줄이려 애쓰지 말고,
/// 배경 없는 .riv를 새로 받으면 이 함수째로 지우는 게 맞다.
void _hideBg(Artboard artboard) {
  final fills = [
    ...?artboard.component<Shape>('BG')?.fills,
    ...?artboard.component<Shape>('HitArea')?.fills,
    ...artboard.fills,
  ];
  const transparent = Color(0x00000000);
  for (final fill in fills) {
    fill.paint
      ..blendMode = BlendMode.dst
      ..color = transparent
      ..shader = null;
    final mutator = fill.paintMutator;
    if (mutator is SolidColor) mutator.color = transparent;
    if (mutator is rive.LinearGradient) {
      for (final stop in mutator.gradientStops) {
        stop.color = transparent;
      }
    }
  }
}

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

  /// cat.riv 아트보드 안에서 고양이가 실제로 차지하는 비율(세로 기준).
  /// 배경을 지워도 아트보드의 빈 여백은 남아 BoxFit.contain이 그 여백까지
  /// 맞추기 때문에, 이만큼 키워야 [size]가 눈에 보이는 고양이 크기가 된다.
  /// 시뮬레이터 화면에서 재서 얻은 값 — 여백 없는 .riv로 바꾸면 1.0으로.
  static const _artFill = 0.65;

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
          width: size * _scale / _artFill,
          height: size * _scale / _artFill,
          child: RiveAnimation.asset(
            'assets/cat.riv',
            artboard: 'Cat',
            // 상태 머신 대신 애니메이션을 직접 재생한다: 상태 머신은 포인터
            // 좌표로 눈동자를 조준하는데, 폰엔 마우스가 없어 좌표를 안 주면
            // 구석을 응시한 채 멈춰 보인다. Idle을 기본으로 깔고 Blink를
            // 얹어 자연스럽게 깜빡이게 한다.
            animations: const ['Idle', 'Blink'],
            fit: BoxFit.contain,
            onInit: _hideBg,
          ),
        ),
      ),
    );
  }
}
