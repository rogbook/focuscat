# 스토어 등록 자료

- `listing_ko.md` · `listing_en.md` — 앱 이름, 설명, 키워드
- `screenshots/appstore65/{ko,en}/` — 1284×2778 (iPhone 6.5인치), 각 4장
  App Store Connect가 iPhone 슬롯에서 요구하는 크기. 이걸 올린다.
- `screenshots/appstore69/{ko,en}/` — 1320×2868 (iPhone 6.9인치), 각 4장
  6.9인치 슬롯이 따로 뜰 때 쓴다.
- `screenshots/play/{ko,en}/` — 1080×2340 (Google Play 폰), 각 4장

홈 화면 위젯은 1.0.1에서 들어냈다. 세션이 겹쳐 도는 문제의 창구였고,
실기기에서 확인하기 어려운 기능을 안고 갈 이유가 없었다.

스크린샷을 다시 만들려면 시뮬레이터에서 화면을 캡처한 뒤
`scratchpad/make_store.py`를 돌린다. 캡션 문구도 그 파일에 있다.

## 등록 전에 반드시 해야 할 것

1. ~~AdMob 실제 광고 단위 ID로 교체~~ — 끝났다(2026-08-10 확인). 광고 단위도
   앱 ID도 양쪽 다 실제 값이다. 구글 테스트 계정은 `~3940256099942544`로
   시작하는데 우리 것은 `~8879427346433924`다.
2. ~~개인정보처리방침 URL~~ — https://rogbook.github.io/focuscat/privacy-policy/
   에 게시돼 있고 앱 안에서도 이 주소로 보낸다.
3. ~~iOS: App Tracking Transparency~~ — 붙였다.
4. ~~유럽 대상 광고 동의(UMP)~~ — 붙였다.
5. **Play 데이터 보안 · App Store 개인정보 양식** — 답안은 data_safety.md에
   그대로 채워 뒀다.

## 확인되지 않은 것

- **스크린샷이 1.0 화면이다.** 사냥하는 고양이가 없다. 다시 찍어 올려야
  1.1.0 내용과 맞는다.

## 확인된 것 (2026-08-10, 1.1.0 준비 중)

- 실제 광고 노출 — 오너 실기기에서 3회째에 뜨는 것까지 봤다. 그 기기는
  AdMob 테스트 기기로 코드에 등록해 두었다(lib/ads.dart).
- 완료 야옹 소리, 사냥 애니메이션 4단계, 새 아이콘 모두 실기기 확인.

---

## 안드로이드 (Google Play) 준비 상태

문구는 `listing_play.md`에 따로 있다 — Play는 글자 수 제한이 App Store와 달라
그대로 못 쓴다(제목 30자, 간단한 설명 80자).

| 자산 | 위치 | 상태 |
|---|---|---|
| 앱 아이콘 512×512 | `play_assets/icon_512.png` | 준비됨 |
| 그래픽 이미지 1024×500 | `play_assets/feature_ko.png` · `feature_en.png` | 준비됨 |
| 휴대전화 스크린샷 | `screenshots/play/{ko,en}/` 각 4장 | 준비됨 |
| 등록 문구 | `listing_play.md` | 준비됨 |
| 데이터 보안 답안 | `data_safety.md` | 준비됨 |
| 개인정보처리방침 | https://rogbook.github.io/focuscat/privacy-policy/ | 게시됨 |

1.1.0 빌드는 `app-release.aab` 68MB, versionCode 16, minSdk 24, targetSdk 36.
(versionCode·versionName 은 pubspec의 `version:` 을 그대로 따른다 —
`android/app/build.gradle.kts`의 `flutter.versionCode`.)

### 남은 것 (사람이 해야 하는 것)

1. ~~업로드 키 만들기~~ — 끝났다. `android/key.properties`가 있고 저장소에는
   안 들어간다. **키를 잃어버리면 앱 업데이트가 영영 불가능하다** — 백업 확인.
2. ~~AdMob 안드로이드 광고 단위 발급~~ — 끝났다. 실제 ID다.
3. **프로덕션은 아직 못 간다** — 개인 개발자 계정은 비공개 테스트에서
   12명이 14일 연속 참여해야 프로덕션 신청이 열린다. **내부 테스트 트랙은
   이 규칙과 무관하니** 거기부터 올려서 확인한다.
