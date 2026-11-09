#!/usr/bin/env bash
# Mark what changed between a before and an after screenshot.
#
# Usage: mark-diff.sh <before.png> <after.png> <out-dir>
#
# Writes to <out-dir>:
#   before.png, after.png    both images, padded to the same canvas, unmarked
#   before-marked.png,       the same, with a box around each changed
#   after-marked.png         region, numbered when there is more than one
#   side-by-side.png         the two marked images next to each other
#   mask.png                 white where pixels changed
# Also copies side-by-side.png into $BEFORE_AFTER_DIR. By default, this is a
# branch-named folder under /tmp/before-after; set BEFORE_AFTER_DIR to
# choose a different folder.
# Prints one line per box, "<n> <WxH+X+Y>", top to bottom. Prints nothing
# and draws no boxes when nothing changed.
#
# Tuning, through the environment:
#   FUZZ=2%       color distance that still counts as the same pixel
#   MERGE=8       changes closer than about this many pixels share a box
#   MIN_AREA=25   regions smaller than this many pixels (after merging) are
#                 dropped as noise
#   COLOR=magenta box and number color
#   BEFORE_AFTER_DIR=/tmp/before-after/<branch>  output folder
#   SHOT_NAME=<name>  file name, without extension, in the output folder
#
# Needs ImageMagick 7 (`magick`).
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: $0 <before.png> <after.png> <out-dir>" >&2
  exit 2
fi
command -v magick >/dev/null || { echo "mark-diff: needs ImageMagick 7 (magick)" >&2; exit 2; }

before=$1 after=$2 out=$3
fuzz=${FUZZ:-2%} merge=${MERGE:-8} min_area=${MIN_AREA:-25} color=${COLOR:-magenta}
mkdir -p "$out"

# Pad both to the larger width and the larger height. compare only looks at
# the overlap of differently sized images, so added content would be missed.
read -r w1 h1 < <(magick identify -format '%w %h\n' "${before}[0]")
read -r w2 h2 < <(magick identify -format '%w %h\n' "${after}[0]")
w=$(( w1 > w2 ? w1 : w2 )) h=$(( h1 > h2 ? h1 : h2 ))

# Normalize to opaque 8-bit sRGB, so a grayscale or palette PNG compares
# channel for channel with a color one.
for pair in "before:$before" "after:$after"; do
  name=${pair%%:*} src=${pair#*:}
  magick "${src}[0]" -colorspace sRGB -background white -alpha remove -alpha off \
    -gravity NorthWest -extent "${w}x${h}" PNG24:"$out/$name.png"
done

# Changed pixels white, unchanged black. compare exits 1 when the images
# differ, which is expected; only 2 is an error.
status=0
magick compare -fuzz "$fuzz" -metric AE "$out/before.png" "$out/after.png" \
  -compose src -highlight-color white -lowlight-color black \
  "$out/mask.png" 2>/dev/null || status=$?
[ "$status" -le 1 ] || { echo "mark-diff: compare failed" >&2; exit 2; }

# Grow each change so nearby pieces (the letters of one word) join up, then
# list the white regions. Black regions (the background, holes) are skipped.
boxes=$(
  magick "$out/mask.png" -colorspace gray -threshold 50% \
    -morphology Dilate "Disk:$merge" \
    -define connected-components:verbose=true \
    -define connected-components:area-threshold="$min_area" \
    -connected-components 8 null: |
  awk '$NF == "gray(255)" || $NF == "srgb(255,255,255)" { print $2 }' |
  awk -F'[x+]' '{ print $4, $3, $0 }' | sort -n -k1,1 -k2,2 | awk '{ print $3 }'
)

# Number the boxes only when there are several, since a lone box needs no
# label to tell it apart.
count=$(grep -c . <<<"$boxes" || true)

draw=() n=0
while read -r box; do
  [ -n "$box" ] || continue
  n=$((n + 1))
  IFS='x+' read -r bw bh bx by <<<"$box"
  draw+=(-stroke "$color" -strokewidth 3 -fill none
         -draw "rectangle $bx,$by $((bx + bw - 1)),$((by + bh - 1))")
  if [ "$count" -gt 1 ]; then
    # Number above the box's top-left corner, or inside it at the top edge.
    ty=$(( by > 22 ? by - 4 : by + 20 ))
    draw+=(-stroke none -fill "$color" -pointsize 20
           -annotate "+$((bx + 2))+$ty" "$n")
  fi
  echo "$n $box"
done <<<"$boxes"

for name in before after; do
  magick "$out/$name.png" "${draw[@]}" PNG24:"$out/$name-marked.png"
done
magick "$out/before-marked.png" -size 12x"$h" xc:white "$out/after-marked.png" \
  +append PNG24:"$out/side-by-side.png"

# Copy the side-by-side into this branch's folder.
if [ -n "${BEFORE_AFTER_DIR:-}" ]; then
  shared=$BEFORE_AFTER_DIR
else
  branch=$(git branch --show-current 2>/dev/null || true)
  branch=${branch:-detached}
  folder=${branch//[^A-Za-z0-9._-]/_}
  shared="/tmp/before-after/$folder"
fi
if [ -z "${SHOT_NAME:-}" ]; then
  repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
  branch=$(git branch --show-current 2>/dev/null || true)
  SHOT_NAME="$repo${branch:+-$branch}-$(date +%Y%m%d-%H%M%S)"
fi
# Branch names may hold slashes, so keep only characters that are safe in a
# file name.
name=${SHOT_NAME//[^A-Za-z0-9._-]/_}
mkdir -p "$shared"
cp "$out/side-by-side.png" "$shared/$name.png"
echo "output: $shared/$name.png" >&2
