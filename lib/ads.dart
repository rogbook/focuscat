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

  /// 구글 공식 테스트 광고 단위. 실제 출시 전에 AdMob에서 발급받은 ID로
  /// 바꿔야 한다. 테스트 ID 그대로 출시하면 수익이 0이고, 반대로 실제 ID로
  /// 개발 중 광고를 띄우면 계정이 정지될 수 있다.
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
