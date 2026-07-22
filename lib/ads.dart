import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

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

  /// 보상형 전면 광고 단위. iOS는 실제(focus-end), 안드로이드는 아직
  /// 구글 테스트 ID다 — AdMob에서 안드로이드 앱에도 같은 형식의 단위를
  /// 만들어 교체해야 안드로이드에서 수익이 발생한다.
  ///
  /// 실제 단위 ID로 개발하며 광고를 반복해 띄우면 무효 트래픽으로 계정이
  /// 정지될 수 있다. 기기에서 시험할 때는 AdMob의 테스트 기기로 등록하고 쓴다.
  static String get _unitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5354046379'
      : 'ca-app-pub-8879427346433924/3200981586';

  RewardedInterstitialAd? _ad;
  bool _loading = false;

  /// 동의를 먼저 받고 광고를 초기화한다. 순서가 중요하다 — 초기화가 먼저면
  /// 동의 없이 맞춤 광고 식별자가 쓰일 수 있다.
  Future<void> init() async {
    await _requestConsent();
    await _requestTracking();
    await MobileAds.instance.initialize();
    load();
  }

  /// 유럽(EEA·영국) 사용자에게 광고 동의를 받는다(UMP).
  /// 다른 지역에서는 구글이 "필요 없음"으로 응답해 아무것도 뜨지 않는다.
  /// 전 세계 출시라면 이게 없으면 정책 위반이다.
  Future<void> _requestConsent() async {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        if (!done.isCompleted) done.complete();
      },
      (_) {
        // 동의 정보를 못 받아도 앱은 계속 돌아가야 한다. 이 경우 구글이
        // 맞춤 광고 대신 비맞춤 광고를 내려준다.
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  /// iOS 추적 동의(ATT). 이게 없으면 맞춤 광고를 못 쓰고 심사에서 걸린다.
  /// 안드로이드에는 없는 개념이라 그쪽에서는 아무 일도 하지 않는다.
  Future<void> _requestTracking() async {
    if (!Platform.isIOS) return;
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status != TrackingStatus.notDetermined) return;
    // 앱이 완전히 떠오른 뒤에 요청해야 시스템 창이 뜬다.
    await Future.delayed(const Duration(milliseconds: 400));
    await AppTrackingTransparency.requestTrackingAuthorization();
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
