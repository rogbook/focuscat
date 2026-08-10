#!/usr/bin/env python3
"""프레임의 배경색을 앱 배경색(#F0F4F3)으로 맞춘다.

힉스필드가 만든 그림의 배경은 앱 배경과 미세하게 다르다(#E6ECE8 같은 색).
그대로 쓰면 화면 가운데 네모난 자국이 보인다.

첫 프레임의 네 모서리에서 배경색을 재고, 그 색에서 충분히 가까운 픽셀만
목표색으로 바꾼다. 고양이 몸(검정)·눈(흰색)·나비(주황)는 배경색과 멀어서
건드려지지 않는다. 모든 프레임에 같은 기준을 써야 프레임마다 배경이
미묘하게 달라지는 깜빡임이 안 생긴다.
"""

import sys

from PIL import Image

TARGET = (240, 244, 243)  # #F0F4F3 — lib/screens.dart 의 kBg

# 배경으로 칠 색 거리(제곱). 흰 눈(#FFFFFF)은 배경에서 40 이상 떨어져 있어
# 안전하고, 배경의 미세한 노이즈는 30 안쪽이라 함께 잡힌다.
TOL2 = 30 * 30


def sample_bg(im):
    """네 모서리 픽셀의 평균. 한 곳에 얼룩이 있어도 휩쓸리지 않는다."""
    w, h = im.size
    pts = [(2, 2), (w - 3, 2), (2, h - 3), (w - 3, h - 3)]
    px = [im.getpixel(p) for p in pts]
    return tuple(sum(c[i] for c in px) // len(px) for i in range(3))


def normalize(path, bg):
    im = Image.open(path).convert("RGB")
    out = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b = out[x, y]
            d = (r - bg[0]) ** 2 + (g - bg[1]) ** 2 + (b - bg[2]) ** 2
            if d < TOL2:
                out[x, y] = TARGET
    im.save(path)


def main(paths):
    if not paths:
        sys.exit("쓸 프레임이 없다")
    bg = sample_bg(Image.open(paths[0]).convert("RGB"))
    print(f"  배경색 #{bg[0]:02x}{bg[1]:02x}{bg[2]:02x} → #f0f4f3")
    for p in paths:
        normalize(p, bg)


if __name__ == "__main__":
    main(sys.argv[1:])
