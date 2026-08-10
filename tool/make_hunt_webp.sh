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
# 배경색은 normalize_bg.py 가 앱 배경색으로 맞춘다.
set -euo pipefail

src=$1
out=$2
mode=${3:-loop}
here=$(cd "$(dirname "$0")" && pwd)

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

python3 "$here/normalize_bg.py" "${frames[@]}"

if [ "$mode" = once ]; then
  loop=1
else
  # 뒤로 되감는 프레임을 덧붙인다. 첫·끝 프레임은 겹치지 않게 뺀다.
  n=${#frames[@]}
  for ((i = n - 2; i > 0; i--)); do frames+=("${frames[i]}"); done
  loop=0
fi

# img2webp 는 기본이 무손실이고, -lossy·-q 는 프레임마다 붙여야 먹는다.
# 전역으로 한 번만 주면 조용히 무시된다(그래서 700KB가 나왔다).
args=()
for f in "${frames[@]}"; do args+=(-lossy -q 70 "$f"); done

# -min_size 를 쓰면 안 된다. 프레임 대부분에 "배경으로 지우기"(Dispose 1)를
# 붙이는데, 플러터(Skia)가 그걸 못 읽고 재생 중에 예외를 던진다
# — "Could not getPixels for frame 14". 실제로 겪었다. 파일이 30KB쯤
# 커지는 대신 그냥 재생된다.
#
# -d 83ms = 12fps. 위 fps 와 맞춘다.
img2webp -loop "$loop" -d 83 "${args[@]}" -o "$out" >/dev/null

size=$(stat -f%z "$out")
echo "$out — ${#frames[@]}프레임, $((size / 1024))KB"
[ "$size" -lt 512000 ] || echo "  ⚠ 500KB 넘음. -q 를 낮추거나 fps 를 줄여라."
