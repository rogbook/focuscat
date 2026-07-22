# 스토어 등록 자료

- `listing_ko.md` · `listing_en.md` — 앱 이름, 설명, 키워드
- `screenshots/appstore/{ko,en}/` — 1320×2868 (iPhone 6.9인치)
- `screenshots/play/{ko,en}/` — 1080×2340 (Google Play 폰)

스크린샷을 다시 만들려면 시뮬레이터에서 화면을 캡처한 뒤
`scratchpad/make_store.py`를 돌린다. 캡션 문구도 그 파일에 있다.

## 등록 전에 반드시 해야 할 것

1. **AdMob 실제 광고 단위 ID로 교체** — [lib/ads.dart](../lib/ads.dart)와
   양쪽 플랫폼의 앱 ID(AndroidManifest.xml, Info.plist)가 모두 구글 테스트
   ID다. 테스트 ID로 출시하면 수익이 0이다.
2. **개인정보처리방침 URL** — 광고가 붙은 앱은 양 스토어 모두 필수.
   수집 항목은 광고 SDK가 쓰는 광고 식별자다.
3. **iOS: App Tracking Transparency** — 맞춤 광고를 쓰려면 추적 동의
   요청이 필요하다. 아직 붙이지 않았다.
4. **유럽 대상 광고 동의(UMP)** — 전 세계 출시라면 필요하다. 아직 없다.
5. **Play 데이터 보안 양식** — 광고 식별자 수집을 신고해야 한다.

## 확인되지 않은 것

- 실제 광고 노출. 구글 테스트 광고가 개발 환경에서 계속 "재고 없음"을
  반환해 화면으로 확인하지 못했다. 통합 자체(초기화·요청·응답)는 정상이다.
