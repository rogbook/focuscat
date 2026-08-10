import 'package:flutter/widgets.dart';

/// 집중이 흐르는 동안 고양이가 밟아 가는 사냥 단계.
///
/// [pounce]와 [miss]는 진행률로 정해지지 않는다. 시간이 끝났다는 사건과
/// 실패했다는 사건이라서, 화면 쪽에서 직접 고른다.
enum HuntPhase { watch, aim, stalk, pounce, miss }

/// 진행률(0~1)에 맞는 사냥 단계. 집중 길이가 몇 분이든 비율로 나뉜다.
HuntPhase huntPhaseFor(double progress) {
  if (progress < 0.35) return HuntPhase.watch;
  if (progress < 0.65) return HuntPhase.aim;
  return HuntPhase.stalk;
}

/// 사냥 장면 한 컷.
///
/// 움직이는 WebP라 플러터가 알아서 재생한다. 영상 재생기를 붙이지 않은
/// 이유가 이것이다 — 집중은 25분씩 이어지는데 그 내내 영상 디코더를
/// 돌리면 배터리와 발열이 부담된다.
class HuntView extends StatelessWidget {
  const HuntView({super.key, required this.phase, this.size = 200});

  final HuntPhase phase;
  final double size;

  String get _asset => switch (phase) {
    HuntPhase.watch => 'assets/hunt/watch.webp',
    HuntPhase.aim => 'assets/hunt/aim.webp',
    HuntPhase.stalk => 'assets/hunt/stalk.webp',
    HuntPhase.pounce => 'assets/hunt/pounce.webp',
    HuntPhase.miss => 'assets/hunt/miss.webp',
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // 다음 장면을 읽는 동안 앞 장면을 붙들고 있는다. 없으면 단계가
      // 넘어갈 때 한 프레임 빈 칸이 번쩍인다.
      gaplessPlayback: true,
    );
  }
}
