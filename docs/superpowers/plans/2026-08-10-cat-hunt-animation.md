# 고양이 사냥 애니메이션 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 집중 타이머가 도는 동안 고양이가 나비를 사냥하는 4단계 애니메이션을 보여주고, 시간이 끝나면 덮치는 장면으로 마무리한다.

**Architecture:** 힉스필드에서 받은 mp4 5개를 움직이는 WebP로 변환해 `assets/hunt/`에 넣는다. 플러터의 `Image.asset`이 움직이는 WebP를 그대로 재생하므로 새 패키지가 필요 없다. 진행률 → 단계 판단은 `lib/hunt.dart`의 순수 함수로 떼어 테스트하고, 화면은 그 결과에 맞는 그림 한 장을 그린다.

**Tech Stack:** Flutter 3.x / Dart (sdk ^3.12.2), ffmpeg + img2webp(libwebp), 새 pub 의존성 없음

**Spec:** [docs/superpowers/specs/2026-08-10-cat-hunt-animation-design.md](../specs/2026-08-10-cat-hunt-animation-design.md)

## Global Constraints

- **새 pub 의존성을 추가하지 않는다.** `pubspec.yaml`의 `dependencies:` 블록은 건드리지 않는다. `flutter: assets:` 목록만 수정한다.
- 앱 배경색은 `kBg = Color(0xFFF0F4F3)` (`lib/screens.dart:21`). 모든 사냥 애셋의 배경은 이 색이다.
- 사냥 애셋은 **성장 단계(baby/teen/adult)와 무관하게 한 종류**다. `CatStage`를 참조하지 않는다.
- 홈 화면(`HomeScreen`)과 성공 결과 화면의 고양이는 기존 `CatView`(Rive) 그대로 둔다. 사냥 애셋으로 바꾸지 않는다.
- 새 사용자 문구가 없다. `lib/l10n/*.arb`를 건드리지 않는다.
- 주석은 한국어로, 기존 파일들의 톤(무엇을 하는지가 아니라 **왜** 그런지)을 따른다.
- 커밋 메시지는 한국어 평서문. 기존 로그(`광고를 매번이 아니라 집중 3회마다 한 번만 띄운다`)와 같은 결.

---

### Task 1: 진행률 → 사냥 단계 (순수 함수)

애셋이 없어도 **지금 바로** 할 수 있는 유일한 작업이다. 나머지 태스크는 힉스필드 영상이 들어와야 시작한다.

**Files:**
- Create: `lib/hunt.dart`
- Test: `test/hunt_test.dart`

**Interfaces:**
- Consumes: 없음 (플러터를 import 하지 않는 순수 Dart)
- Produces:
  - `enum HuntPhase { watch, aim, stalk, pounce, miss }`
  - `HuntPhase huntPhaseFor(double progress)` — `watch`/`aim`/`stalk` **셋만** 돌려준다. `pounce`와 `miss`는 진행률이 아니라 사건(시간 끝남 / 실패)이라서 호출부가 직접 고른다.

- [ ] **Step 1: 실패하는 테스트를 쓴다**

`test/hunt_test.dart`:

```dart
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
```

- [ ] **Step 2: 실패하는지 확인한다**

```bash
flutter test test/hunt_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:focuscat/hunt.dart'`

- [ ] **Step 3: 최소 구현을 쓴다**

`lib/hunt.dart`:

```dart
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
```

- [ ] **Step 4: 통과하는지 확인한다**

```bash
flutter test test/hunt_test.dart
```

Expected: PASS (4 tests)

- [ ] **Step 5: 커밋한다**

```bash
git add lib/hunt.dart test/hunt_test.dart
git commit -m "집중 진행률을 고양이 사냥 단계로 옮긴다"
```

---

### Task 2: 힉스필드 영상 → 움직이는 WebP 변환

**선행 조건:** 오너가 힉스필드에서 뽑은 mp4 5개가 `~/Downloads/hunt/` 같은 폴더에 `watch.mp4`, `aim.mp4`, `stalk.mp4`, `pounce.mp4`, `miss.mp4` 이름으로 있어야 한다. 없으면 이 태스크는 시작하지 않는다.

**Files:**
- Create: `tool/make_hunt_webp.sh`
- Create: `assets/hunt/watch.webp`, `aim.webp`, `stalk.webp`, `pounce.webp`, `miss.webp`
- Modify: `pubspec.yaml` (`flutter: assets:` 목록에 `assets/hunt/` 추가)

**Interfaces:**
- Consumes: 없음
- Produces: `assets/hunt/<phase>.webp` 다섯 개. Task 3의 `HuntView`가 이 경로를 그대로 쓴다.

**도구 확인 (이 환경에서 실측함):** `ffmpeg`은 `/opt/homebrew/bin/ffmpeg`에 있지만 **WebP 인코더가 빠져 있다.** 그래서 ffmpeg으로는 PNG 프레임만 뽑고, 움직이는 WebP는 `/opt/homebrew/bin/img2webp`(libwebp)로 만든다. 둘 다 이미 설치돼 있다.

- [ ] **Step 1: 변환 스크립트를 쓴다**

`tool/make_hunt_webp.sh`:

```bash
#!/bin/bash
# 힉스필드 mp4 하나를 움직이는 WebP 하나로 바꾼다.
#
#   ./tool/make_hunt_webp.sh <입력.mp4> <출력.webp> [loop|once]
#
# loop(기본): 앞으로 갔다 뒤로 오게 이어붙여 끊김 없이 반복한다. AI 영상은
#   첫 프레임과 끝 프레임이 달라서 그냥 반복하면 튄다.
# once: 그대로 한 번만 재생한다(덮치기 장면용).
#
# ffmpeg에 WebP 인코더가 없어서 PNG 프레임을 거쳐 img2webp로 묶는다.
set -euo pipefail

src=$1
out=$2
mode=${3:-loop}

command -v ffmpeg >/dev/null || { echo "ffmpeg 이 없다: brew install ffmpeg"; exit 1; }
command -v img2webp >/dev/null || { echo "img2webp 이 없다: brew install webp"; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 12fps, 400x400. 영상이 정사각형이 아니면 앱 배경색으로 채운다.
ffmpeg -v error -y -i "$src" \
  -vf "fps=12,scale=400:400:force_original_aspect_ratio=decrease,pad=400:400:-1:-1:color=0xF0F4F3" \
  "$tmp/f_%04d.png"

frames=("$tmp"/f_*.png)
[ ${#frames[@]} -gt 1 ] || { echo "프레임이 안 나왔다: $src"; exit 1; }

if [ "$mode" = once ]; then
  loop=1
else
  # 뒤로 되감는 프레임을 덧붙인다. 첫·끝 프레임은 겹치지 않게 뺀다.
  n=${#frames[@]}
  for ((i = n - 2; i > 0; i--)); do frames+=("${frames[i]}"); done
  loop=0
fi

# -d 83ms = 12fps. 위 fps 와 맞춘다.
img2webp -loop "$loop" -d 83 -q 70 "${frames[@]}" -o "$out"

size=$(stat -f%z "$out")
echo "$out — ${#frames[@]}프레임, $((size / 1024))KB"
[ "$size" -lt 512000 ] || echo "  ⚠ 500KB 넘음. -q 를 낮추거나 fps 를 줄여라."
```

```bash
chmod +x tool/make_hunt_webp.sh
```

- [ ] **Step 2: 다섯 개를 변환한다**

`$SRC`를 mp4가 있는 실제 폴더로 바꿔서 실행한다.

```bash
SRC=~/Downloads/hunt
mkdir -p assets/hunt
for p in watch aim stalk miss; do
  ./tool/make_hunt_webp.sh "$SRC/$p.mp4" "assets/hunt/$p.webp" loop
done
./tool/make_hunt_webp.sh "$SRC/pounce.mp4" "assets/hunt/pounce.webp" once
```

Expected: 파일 5개가 생기고, 각각 KB 크기가 찍힌다. 합계가 2MB를 넘으면 `-q 70`을 `-q 55`로 낮춰 다시 돌린다.

- [ ] **Step 3: 눈으로 확인한다**

```bash
open assets/hunt/watch.webp
```

확인할 것 — 배경이 앱 배경색(`#F0F4F3`)과 같은지, 반복이 튀지 않는지, 고양이 그림체가 홈 화면 고양이와 같은 계열인지. 하나라도 어긋나면 코드로 못 고친다. 힉스필드에서 다시 뽑아야 한다.

- [ ] **Step 4: pubspec에 등록한다**

`pubspec.yaml`의 `flutter: assets:` 목록에서 `- assets/lofi.mp3` 다음 줄에 추가:

```yaml
    # 집중 중 고양이 사냥 장면. 움직이는 WebP라 Image.asset 이 그대로 재생한다.
    # 원본 mp4 → tool/make_hunt_webp.sh 로 변환한다.
    - assets/hunt/
```

- [ ] **Step 5: 애셋이 실제로 묶이는지 확인한다**

```bash
flutter pub get && flutter build bundle
ls build/flutter_assets/assets/hunt/
```

Expected: `aim.webp  miss.webp  pounce.webp  stalk.webp  watch.webp` 다섯 개가 보인다.

- [ ] **Step 6: 커밋한다**

```bash
git add tool/make_hunt_webp.sh assets/hunt pubspec.yaml
git commit -m "고양이 사냥 장면 다섯 개를 움직이는 WebP로 넣는다"
```

---

### Task 3: 사냥 장면을 그리는 위젯

**Files:**
- Modify: `lib/hunt.dart` (Task 1에서 만든 파일에 위젯을 더한다)

**Interfaces:**
- Consumes: Task 1의 `HuntPhase`, Task 2의 `assets/hunt/*.webp`
- Produces: `class HuntView extends StatelessWidget` — 생성자 `HuntView({Key? key, required HuntPhase phase, double size = 200})`

**왜 테스트를 안 쓰나:** 이 위젯은 `phase` → 파일 경로 대응표 하나가 전부다. 대응표는 `HuntPhase` 값마다 항목이 있어야 컴파일되게(`switch` 표현식) 써서, 값을 빠뜨리면 테스트가 아니라 **컴파일이 깨진다.** 실제로 그림이 뜨는지는 위젯 테스트가 확인해 주지 못하고 Task 6의 시뮬레이터 확인에서만 드러난다.

- [ ] **Step 1: 위젯을 더한다**

`lib/hunt.dart` 맨 위에 import를 넣고:

```dart
import 'package:flutter/widgets.dart';
```

파일 끝에 추가:

```dart
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
```

- [ ] **Step 2: 컴파일과 기존 테스트를 확인한다**

```bash
flutter analyze && flutter test
```

Expected: analyze는 `No issues found!`, 기존 테스트 전부 통과.

- [ ] **Step 3: 커밋한다**

```bash
git add lib/hunt.dart
git commit -m "사냥 장면을 그리는 위젯을 만든다"
```

---

### Task 4: 집중 화면을 사냥 장면으로 바꾸고, 끝날 때 덮치게 한다

**Files:**
- Modify: `lib/screens.dart` — import 추가, `_FocusScreenState`의 필드·`_finish()`·`build()`

**Interfaces:**
- Consumes: `huntPhaseFor`, `HuntView`, `HuntPhase` (`lib/hunt.dart`)
- Produces: 없음 (화면 안에서 끝난다)

**주의할 것 — 이 파일은 세션이 유령처럼 남았던 사고 이력이 있다.** `_finish()`에 2초 기다림을 넣으면 그동안 위젯이 사라질 수 있다. `await` 뒤마다 `mounted`를 확인해야 한다. 실패로 끝난 경우(포기·앱 이탈)는 **기다리지 않고 곧바로** 넘어간다 — 사냥에 실패했는데 덮치는 장면을 보여줄 수는 없다.

- [ ] **Step 1: import와 상수, 필드를 더한다**

`lib/screens.dart`의 import 목록에 추가 (`import 'focus_timer.dart';` 옆):

```dart
import 'hunt.dart';
```

`kBg` 선언 아래(파일 상단 상수 자리)에 추가:

```dart
/// 시간이 끝나고 덮치는 장면을 보여주는 시간.
///
/// 0초가 되자마자 결과 화면으로 넘어가면 사냥의 마무리가 안 보인다.
const kPounceDuration = Duration(seconds: 2);
```

`_FocusScreenState`의 필드 목록(`bool _muted = false;` 아래)에 추가:

```dart
/// 덮치는 장면을 보여주는 중. 이 동안 화면을 떠나지 못하게 한다.
bool _pouncing = false;
```

- [ ] **Step 2: `_finish()`에 덮치기를 끼워 넣는다**

`lib/screens.dart:434` 의 `_finish()`를 통째로 바꾼다:

```dart
  Future<void> _finish() async {
    if (_isFinishing) return;
    _isFinishing = true;
    _ticker?.cancel();
    _graceTimer?.cancel();
    // 성공했을 때만 덮치는 장면을 보여준다. 포기·이탈은 사냥이 아니라
    // 중단이라, 기다리게 하면 벌 세우는 것처럼 느껴진다.
    if (_timer.succeeded && mounted) {
      setState(() => _pouncing = true);
      await Future.delayed(kPounceDuration);
      if (!mounted) return;
    }
    await appState.recordSession(
      FocusSession(
        startedAt: _startedAt,
        durationSeconds: _timer.elapsedSeconds,
        success: _timer.succeeded,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(outcome: _timer.outcome!)),
    );
  }
```

- [ ] **Step 3: `build()`에서 고양이를 사냥 장면으로 바꾸고 포기 버튼을 잠근다**

`lib/screens.dart:474`의 한 줄

```dart
              CatView(stage: appState.stage, mood: CatMood.focused, size: 200),
```

을 이렇게 바꾼다:

```dart
              HuntView(
                phase: _pouncing
                    ? HuntPhase.pounce
                    : huntPhaseFor(_timer.progress),
                size: 200,
              ),
```

같은 `build()` 안 포기 버튼(`lib/screens.dart:497` 근처)의 `onPressed`를 바꾼다:

```dart
              TextButton(
                // 덮치는 중엔 못 누른다. 이미 성공으로 끝난 세션이라
                // 여기서 포기가 먹히면 결과가 뒤집힌다.
                onPressed: _pouncing
                    ? null
                    : () {
                        _timer.abandon();
                        _finish();
                      },
                child: Text(t.giveUp),
              ),
```

- [ ] **Step 4: `CatView` import가 아직 필요한지 확인한다**

`CatView`는 홈 화면과 성공 결과 화면에서 아직 쓴다. `import 'cat.dart';`는 **지우지 않는다.**

```bash
flutter analyze
```

Expected: `No issues found!` — 특히 `unused_import` 경고가 없어야 한다. 나오면 잘못 지운 것이다.

- [ ] **Step 5: 기존 테스트가 안 깨졌는지 확인한다**

```bash
flutter test
```

Expected: 전부 통과.

- [ ] **Step 6: 커밋한다**

```bash
git add lib/screens.dart
git commit -m "집중하는 동안 고양이가 사냥하고, 끝나면 덮치게 한다"
```

---

### Task 5: 실패 결과 화면에 놓치는 장면

**Files:**
- Modify: `lib/screens.dart` — `_ResultScreenState.build()`

**Interfaces:**
- Consumes: `HuntView`, `HuntPhase` (Task 3)
- Produces: 없음

- [ ] **Step 1: 실패일 때만 사냥 장면으로 바꾼다**

`lib/screens.dart:555` 근처의

```dart
                CatView(
                  stage: appState.stage,
                  mood: success ? CatMood.happy : CatMood.sad,
                  size: 220,
                ),
```

를 이렇게 바꾼다:

```dart
                // 성공은 기존 고양이 그대로 — 사냥의 마무리는 집중 화면에서
                // 이미 보여줬다. 실패했을 때만 놓친 장면을 보여준다.
                if (success)
                  CatView(
                    stage: appState.stage,
                    mood: CatMood.happy,
                    size: 220,
                  )
                else
                  const HuntView(phase: HuntPhase.miss, size: 220),
```

- [ ] **Step 2: 컴파일과 테스트를 확인한다**

```bash
flutter analyze && flutter test
```

Expected: `No issues found!`, 테스트 전부 통과.

- [ ] **Step 3: 커밋한다**

```bash
git add lib/screens.dart
git commit -m "사냥에 실패하면 나비를 놓친 고양이를 보여준다"
```

---

### Task 6: 실제로 돌려서 눈으로 확인한다

코드가 컴파일된다고 애니메이션이 보이는 건 아니다. **이 태스크를 건너뛰고 "됐다"고 말하지 않는다.**

**Files:** 없음 (확인만)

- [ ] **Step 1: 1분짜리로 시뮬레이터에서 돌린다**

```bash
flutter run
```

앱에서 **1분**을 골라 집중을 시작한다. 1분이면 21초·39초 근처에서 단계가 넘어간다.

- [ ] **Step 2: 네 가지를 확인한다**

| 확인할 것 | 기대 |
|---|---|
| 시작 직후 | 꼬리 살랑(`watch`). 배경이 화면 배경과 이어져 네모가 안 보임 |
| 21초쯤 | 동공 커진 조준 자세(`aim`)로 **깜빡임 없이** 바뀜 |
| 39초쯤 | 살금살금(`stalk`) |
| 0초 도달 | 덮치는 장면이 2초 보이고, 그동안 "포기"가 회색으로 눌리지 않음. 그 뒤 성공 결과 화면 |

- [ ] **Step 3: 실패 경로를 확인한다**

다시 시작해서 중간에 **포기**를 누른다.

Expected: 기다림 없이 곧바로 결과 화면, 나비를 놓치고 아쉬워하는 고양이가 **반복** 재생된다.

- [ ] **Step 4: 앱 이탈도 확인한다**

다시 시작해서 홈 버튼으로 나갔다가 25초(`kGraceSeconds`) 넘게 기다린 뒤 돌아온다.

Expected: 실패 결과 화면 + 놓친 고양이.

- [ ] **Step 5: 앱 용량이 얼마나 늘었는지 본다**

```bash
du -sh assets/hunt
```

Expected: 2MB 이하. 넘으면 Task 2의 `-q` 값을 낮춰 다시 변환한다.

- [ ] **Step 6: 확인 결과를 커밋 메시지 없이 오너에게 보고한다**

표 네 줄(위 Step 2)에 실제로 본 것을 적어 보고한다. 하나라도 어긋나면 "됐다"고 하지 않는다.

---

## 안 하는 것 (스펙에서 제외됨)

- 성장 단계별 사냥 장면 — 사냥은 한 종류
- 성공 결과 화면의 전리품 장면
- 사냥 소리 효과 — 배경음이 이미 있다
- reduce-motion 대응 — 요청이 오면 정지 프레임으로 대체
