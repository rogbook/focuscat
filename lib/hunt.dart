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
