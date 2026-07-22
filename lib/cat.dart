import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'app_state.dart';

/// .riv에 딸려 온 주황 배경을 지운다.
///
/// 이 파일은 내보내기 과정에서 컴포넌트 이름이 모두 지워져 있어 이름으로
/// 찾을 수 없다. 그래서 배경색(#FFAA37)을 쓰는 채우기를 색으로 골라 없앤다.
/// 고양이 본체는 검정·흰색·회색이라 함께 지워질 위험이 없다(실제 색 목록을
/// 찍어 확인했다).
///
/// rive 0.13.20엔 컴포넌트를 지우는 API가 없고 opacity·isVisible도 화면에
/// 반영되지 않아, 채우기 자체를 무력화한다. 채우기 종류마다 먹히는 경로가
/// 달라 blendMode·color·shader·paintMutator를 한꺼번에 건다.
void _hideBg(Artboard artboard) {
  const bg = 0xFFFFAA37;
  const transparent = Color(0x00000000);
  artboard.forEachComponent((c) {
    if (c is! Shape) return;
    for (final fill in c.fills) {
      final mutator = fill.paintMutator;
      if (mutator is! SolidColor || mutator.color.toARGB32() != bg) continue;
      mutator.color = transparent;
      fill.paint
        ..blendMode = BlendMode.dst
        ..color = transparent
        ..shader = null;
    }
  });
  for (final fill in artboard.fills) {
    fill.paint
      ..blendMode = BlendMode.dst
      ..color = transparent
      ..shader = null;
    final mutator = fill.paintMutator;
    if (mutator is SolidColor) mutator.color = transparent;
  }
}

/// 고양이 표정.
///
/// 지금 .riv에는 기분별 동작이 없어 받아두기만 한다. 표정이 든 .riv가
/// 생기면 여기서 애니메이션을 골라 재생하면 된다.
enum CatMood { idle, focused, happy, sad }

/// 성장 단계와 기분에 따라 달라지는 고양이.
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

  /// 아트보드 안에서 고양이가 실제로 차지하는 비율. 둘레 여백만큼 되키워야
  /// [size]가 눈에 보이는 크기와 맞는다.
  static const _artFill = 0.8;

  /// 성장할수록 몸집이 커진다.
  double get _scale => switch (stage) {
    CatStage.baby => 0.7,
    CatStage.teen => 0.85,
    CatStage.adult => 1.0,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: size * _scale / _artFill,
          height: size * _scale / _artFill,
          child: RiveAnimation.asset(
            'assets/cat.riv',
            // day·night는 배경색을 칠하는 타임라인이라 쓰지 않는다.
            // State Machine 1도 매 프레임 배경을 다시 칠해 못 쓴다.
            animations: const ['head'],
            fit: BoxFit.contain,
            onInit: _hideBg,
          ),
        ),
      ),
    );
  }
}
