import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 집중이 끝난 뒤에 한 번 보여주는 보상형 전면 광고.
///
/// 형식이 Rewarded Interstitial인 이유: 닫기 버튼이 언제 뜨는지는 앱이 정할
/// 수 없고 광고 형식이 정한다. 일반 전면 광고는 몇 초 뒤 바로 닫을 수 있고,
/// 이 형식은 카운트다운이 끝나야 건너뛸 수 있다.
///
/// 집중하는 동안에는 절대 띄우지 않는다 — 그건 이 앱의 존재 이유를 깨뜨린다.
class Ads {
  Ads._();

  static final instance = Ads._();

  /// 아직 구글 공식 테스트 광고 단위다.
  ///
  /// 앱 ID는 실제 것으로 바꿨지만(Info.plist, AndroidManifest.xml) 광고 단위는
  /// 아직 발급 전이다. AdMob에서 각 앱에 '보상형 전면 광고' 단위를 만들고
  /// 여기 슬래시(/) 형태의 ID로 교체해야 수익이 발생한다.
  ///
  /// 반대로 실제 단위 ID를 넣은 채 개발하며 광고를 반복해 띄우면 무효 트래픽으로
  /// 계정이 정지될 수 있다. 개발 중에는 테스트 ID를 쓴다.
  static String get _unitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5354046379'
      : 'ca-app-pub-3940256099942544/6978759866';

  RewardedInterstitialAd? _ad;
  bool _loading = false;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    load();
  }

  /// 미리 받아둔다. 집중이 끝난 뒤에 그제서야 받으면 몇 초를 기다리게 된다.
  void load() {
    if (_ad != null || _loading) return;
    _loading = true;
    RewardedInterstitialAd.load(
      adUnitId: _unitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  /// 준비된 광고가 있으면 보여준다. 없으면 그냥 넘어간다 —
  /// 광고 때문에 결과 화면을 못 보는 일은 없어야 한다.
  Future<void> showIfReady() async {
    final ad = _ad;
    if (ad == null) {
      load();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        load(); // 다음 집중을 위해 미리 받아둔다
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        load();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) {});
  }
}
