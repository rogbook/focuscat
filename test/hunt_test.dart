import 'package:flutter_test/flutter_test.dart';
import 'package:focuscat/hunt.dart';

void main() {
  test('처음엔 지켜본다', () {
    expect(huntPhaseFor(0), HuntPhase.watch);
    expect(huntPhaseFor(0.34), HuntPhase.watch);
  });

  test('35%부터 조준한다', () {
    expect(huntPhaseFor(0.35), HuntPhase.aim);
    expect(huntPhaseFor(0.64), HuntPhase.aim);
  });

  test('65%부터 다가간다', () {
    expect(huntPhaseFor(0.65), HuntPhase.stalk);
    expect(huntPhaseFor(0.99), HuntPhase.stalk);
  });

  test('끝까지 가도 stalk 다 — 덮치기는 진행률이 아니라 사건이다', () {
    expect(huntPhaseFor(1), HuntPhase.stalk);
  });
}
