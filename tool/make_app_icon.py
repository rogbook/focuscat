#!/usr/bin/env python3
"""앱 아이콘을 만든다 — 흰 시계판 위에 큰 고양이.

    python3 tool/make_app_icon.py

만드는 파일 (각 크기 파일은 이걸로 만든 뒤 flutter_launcher_icons 가 생성한다):

    assets/icon/app_icon.png             iOS·기본. 민트 배경까지 들어 있다.
    assets/icon/app_icon_foreground.png  안드로이드 적응형. 배경은 투명.

고양이 원본은 assets/icon/cat_art.png 다. app_icon_foreground.png 는 이
스크립트의 출력이라 원본으로 쓰면 두 번째 실행부터 자기 출력을 다시 읽어
그림이 점점 망가진다.

안드로이드 적응형 아이콘은 가운데 66%만 확실히 보이고 바깥은 기기 모양대로
잘린다. 그래서 전경용은 시계판과 고양이를 더 작게 그린다.
"""

import math

from PIL import Image, ImageDraw

TEAL = (0x50, 0xC2, 0xC9, 255)  # lib/screens.dart 의 kTeal
DARK = (0x1A, 0x1A, 0x1A, 255)
WHITE = (255, 255, 255, 255)
CLEAR = (0, 0, 0, 0)

SIZE = 1024
SS = 4  # 4배로 그린 뒤 줄여 계단현상을 없앤다

SRC = "assets/icon/cat_art.png"


def _cat(height):
    """원본에서 고양이만 잘라 [height] 픽셀 높이로 키운다."""
    art = Image.open(SRC).convert("RGBA")
    cat = art.crop(art.getbbox())
    width = round(cat.width * height / cat.height)
    return cat.resize((width, height), Image.LANCZOS)


def _ticks(draw, center, radius, length, width):
    """12시 방향부터 눈금 12개. 3·6·9·12시는 길게."""
    for i in range(12):
        angle = math.radians(i * 30 - 90)
        long = length * 1.35 if i % 3 == 0 else length
        inner = (
            center + (radius - long) * math.cos(angle),
            center + (radius - long) * math.sin(angle),
        )
        outer = (center + radius * math.cos(angle), center + radius * math.sin(angle))
        draw.line([inner, outer], fill=DARK, width=width)
        for x, y in (inner, outer):  # 끝을 둥글게
            r = width / 2
            draw.ellipse([x - r, y - r, x + r, y + r], fill=DARK)


def build(out, background, dial_radius, cat_height):
    big = SIZE * SS
    im = Image.new("RGBA", (big, big), background)
    draw = ImageDraw.Draw(im)
    c = big / 2
    r = dial_radius * SS
    draw.ellipse([c - r, c - r, c + r, c + r], fill=WHITE)
    _ticks(draw, c, r - 34 * SS, 40 * SS, 20 * SS)

    im = im.resize((SIZE, SIZE), Image.LANCZOS)
    cat = _cat(cat_height)
    # 고양이 발밑(주황 타원)이 시계판 가운데에 오도록 살짝 올린다.
    im.alpha_composite(cat, ((SIZE - cat.width) // 2, (SIZE - cat_height) // 2 - 20))
    im.save(out)
    print(out)


if __name__ == "__main__":
    build("assets/icon/app_icon.png", TEAL, dial_radius=400, cat_height=470)
    build(
        "assets/icon/app_icon_foreground.png", CLEAR, dial_radius=330, cat_height=390
    )
