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

# 마지막 장 — 기기 화면 없이 글로만 정리하는 안내문.
# 스크린샷을 넘겨보다 멈춘 사람에게 "무슨 앱인지" 한 번에 알려준다.
NOTICE = {
    "ko": (
        "이런 앱입니다",
        [
            "시간을 고르면 고양이가 옆에서 기다립니다",
            "앱을 벗어나면 집중이 끊깁니다 (25초 유예)",
            "집중하는 동안에는 광고가 나오지 않습니다",
            "lofi 배경음이 흐르고, 언제든 끌 수 있습니다",
            "1분부터 3시간까지 원하는 시간으로",
            "쌓인 시간만큼 고양이가 자랍니다",
            "계정 · 로그인 · 결제 없음. 무료입니다",
        ],
    ),
    "en": (
        "What this app is",
        [
            "Pick a length — your cat waits with you",
            "Leave the app and focus breaks (25s grace)",
            "No ads while you are focusing",
            "Lofi plays in the background, mute it anytime",
            "Any length from 1 minute to 3 hours",
            "Your cat grows with the time you build up",
            "No account, no sign-in, no purchases. Free",
        ],
    ),
}

# (이름, 캔버스 크기) — App Store 6.9인치, Google Play 폰
TARGETS = [("appstore", (1320, 2868)), ("play", (1080, 2340))]


def compose_notice(lang, size):
    W, H = size
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)

    title, lines = NOTICE[lang]

    cap_h = int(H * 0.17)
    d.rectangle([0, 0, W, cap_h], fill=TEAL)
    tf = ImageFont.truetype(FONT, int(W * 0.058), index=2)
    tw = d.textlength(title, font=tf)
    d.text(((W - tw) / 2, (cap_h - int(W * 0.07)) / 2), title, font=tf,
           fill=(255, 255, 255))

    # 흰 카드 하나에 항목을 담는다 — 앱 화면의 카드와 같은 모양
    m = int(W * 0.08)
    top = cap_h + int(H * 0.05)
    bottom = H - int(H * 0.16)
    d.rounded_rectangle([m, top, W - m, bottom], int(W * 0.05), fill=(255, 255, 255))

    bf = ImageFont.truetype(FONT, int(W * 0.033), index=1)
    pad = int(H * 0.045)
    y = top + pad
    step = (bottom - top - pad * 2) / (len(lines) - 1)
    for line in lines:
        d.ellipse(
            [m + int(W * 0.07), y + int(W * 0.014),
             m + int(W * 0.085), y + int(W * 0.029)],
            fill=TEAL,
        )
        d.text((m + int(W * 0.115), y), line, font=bf, fill=INK)
        y += step

    # 아래쪽에 고양이 한 마리
    cat = Image.open("assets/icon/app_icon_foreground.png").convert("RGBA")
    ch = int(H * 0.11)
    cat.thumbnail((ch, ch), Image.LANCZOS)
    canvas.paste(cat, ((W - cat.width) // 2, bottom + int(H * 0.015)), cat)
    return canvas


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
        compose_notice(lang, size).save(f"{d}/{len(items) + 1:02d}.png")
print("done")
