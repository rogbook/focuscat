"""스토어 등록용 스크린샷을 만든다.

앱 화면 위에 한 줄 캡션을 얹고, App Store(6.9")와 Google Play 규격으로 각각
내보낸다. 캡션은 화면만 봐서는 안 보이는 것(규칙·성장 등)을 말해준다.
"""
from PIL import Image, ImageDraw, ImageFont

S = "shots/"  # 시뮬레이터 캡처를 여기에 둔다
OUT = "store/screenshots/"

TEAL = (0x50, 0xC2, 0xC9)
BG = (0xE8, 0xF4, 0xF4)
INK = (0x22, 0x33, 0x33)

# 시스템 한글 폰트 (AppleSDGothicNeo에 한글·영문 모두 있다)
FONT = "/System/Library/Fonts/AppleSDGothicNeo.ttc"

SHOTS = {
    "ko": [
        ("ko_home.png", "고양이와 함께 집중하세요"),
        ("ko_focus.png", "집중하는 동안 lofi가 흐릅니다"),
        ("ko_result.png", "앱을 벗어나면 집중이 끊깁니다"),
        ("ko_widget.png", "홈 화면 위젯으로 바로 시작"),
    ],
    "en": [
        ("en_home.png", "Focus together with your cat"),
        ("en_focus.png", "Lofi plays while you focus"),
        ("en_result.png", "Leave the app and your focus breaks"),
        ("ko_widget.png", "Start right from the home screen"),
    ],
}

# (이름, 캔버스 크기) — App Store 6.9인치, Google Play 폰
TARGETS = [("appstore", (1320, 2868)), ("play", (1080, 2340))]


def compose(shot_path, caption, size):
    W, H = size
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)

    # 위쪽 캡션 영역
    cap_h = int(H * 0.17)
    d.rectangle([0, 0, W, cap_h], fill=TEAL)

    font = ImageFont.truetype(FONT, int(W * 0.052), index=2)
    # 길면 두 줄로 접는다
    lines, cur = [], ""
    for word in caption.split():
        trial = (cur + " " + word).strip()
        if d.textlength(trial, font=font) > W * 0.86 and cur:
            lines.append(cur)
            cur = word
        else:
            cur = trial
    lines.append(cur)

    line_h = int(W * 0.068)
    y = (cap_h - line_h * len(lines)) // 2
    for line in lines:
        w = d.textlength(line, font=font)
        d.text(((W - w) / 2, y), line, font=font, fill=(255, 255, 255))
        y += line_h

    # 기기 화면 — 캡션 아래 남는 자리에 최대한 크게
    shot = Image.open(S + shot_path).convert("RGB")
    avail_h = H - cap_h - int(H * 0.05)
    avail_w = int(W * 0.82)
    scale = min(avail_w / shot.width, avail_h / shot.height)
    shot = shot.resize(
        (int(shot.width * scale), int(shot.height * scale)), Image.LANCZOS
    )

    # 화면 모서리를 둥글게 깎는다
    r = int(shot.width * 0.09)
    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, shot.width, shot.height], r, fill=255)

    x = (W - shot.width) // 2
    y = cap_h + int(H * 0.025)
    shadow = Image.new("RGB", canvas.size, BG)
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x - 6, y - 6, x + shot.width + 6, y + shot.height + 6],
        r + 6,
        fill=(0xC9, 0xDD, 0xDD),
    )
    canvas.paste(shadow.crop((x - 8, y - 8, x + shot.width + 8, y + shot.height + 8)),
                 (x - 8, y - 8))
    canvas.paste(shot, (x, y), mask)
    return canvas


import os

for lang, items in SHOTS.items():
    for target, size in TARGETS:
        d = f"{OUT}{target}/{lang}"
        os.makedirs(d, exist_ok=True)
        for i, (path, caption) in enumerate(items, 1):
            compose(path, caption, size).save(f"{d}/{i:02d}.png")
print("done")
