# 스토어 등록 자료

- `listing_ko.md` · `listing_en.md` — 앱 이름, 설명, 키워드
- `screenshots/appstore65/{ko,en}/` — 1284×2778 (iPhone 6.5인치), 각 4장
  App Store Connect가 iPhone 슬롯에서 요구하는 크기. 이걸 올린다.
- `screenshots/appstore69/{ko,en}/` — 1320×2868 (iPhone 6.9인치), 각 4장
  6.9인치 슬롯이 따로 뜰 때 쓴다.
- `screenshots/play/{ko,en}/` — 1080×2340 (Google Play 폰), 각 4장

위젯을 올린 홈 화면 장면은 없다. 시뮬레이터 위젯 갤러리가 비어 있어
(재부팅해도 마찬가지) 실제 화면을 찍지 못했고, 없는 화면을 합성해 만들지는
않았다. 위젯 이야기는 마지막 안내문 장에 한 줄로 넣었다.

스크린샷을 다시 만들려면 시뮬레이터에서 화면을 캡처한 뒤
`scratchpad/make_store.py`를 돌린다. 캡션 문구도 그 파일에 있다.

## 등록 전에 반드시 해야 할 것

1. **AdMob 실제 광고 단위 ID로 교체** — [lib/ads.dart](../lib/ads.dart)와
   양쪽 플랫폼의 앱 ID(AndroidManifest.xml, Info.plist)가 모두 구글 테스트
   ID다. 테스트 ID로 출시하면 수익이 0이다.
2. **개인정보처리방침 URL** — 문서는 docs/privacy-policy/index.html에
   한국어·영어로 준비돼 있다. 연락처 이메일만 채워 어디든 올리고 URL을
   Play·App Store·AdMob 세 곳에 넣는다.
3. ~~iOS: App Tracking Transparency~~ — 붙였다.
4. ~~유럽 대상 광고 동의(UMP)~~ — 붙였다.
5. **Play 데이터 보안 · App Store 개인정보 양식** — 답안은 data_safety.md에
   그대로 채워 뒀다.

## 확인되지 않은 것

- 실제 광고 노출. 구글 테스트 광고가 개발 환경에서 계속 "재고 없음"을
  반환해 화면으로 확인하지 못했다. 통합 자체(초기화·요청·응답)는 정상이다.

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

빌드는 확인했다 — `app-release.aab` 70.5MB, versionCode 2, minSdk 24,
targetSdk 36(Play 요구치 충족). 릴리스 APK를 에뮬레이터에 설치해 R8 축소 후에도
Rive 고양이가 정상 렌더되는 것까지 봤다.

### 남은 것 (사람이 해야 하는 것)

1. **업로드 키 만들기** — `android/SIGNING.md` 참고. 이게 없으면 디버그 키로
   서명되어 Play가 거부한다. **키를 잃어버리면 앱 업데이트가 영영 불가능하다.**
2. **AdMob 안드로이드 광고 단위 발급** — `lib/ads.dart`의 안드로이드 항목이
   아직 구글 테스트 ID다. 이대로 출시하면 수익이 0이다.
3. Play Console에서 앱 만들기 → 위 자산 업로드 → 데이터 보안 설문 →
   콘텐츠 등급 설문 → 광고 포함 '예' → 내부 테스트 트랙부터 올려보길 권한다.
