#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

ffmpeg -hide_banner -loglevel error \
  -f lavfi -i 'color=c=0xfff9ef:s=720x1280:r=24:d=3' \
  -loop 1 -framerate 24 -i Production/Textures/jar-clean.png \
  -loop 1 -framerate 24 -i DotoryCount/Assets.xcassets/AcornSprite.imageset/acorn@3x.png \
  -filter_complex "[1:v]scale=720:1280,format=rgba[jar];[2:v]scale=195:195,format=rgba[acorn];[0:v][jar]overlay=0:0:shortest=1[scene];[scene][acorn]overlay=x=262:y='if(lt(t,1.3),130+370*pow(t/1.3,2),if(lt(t,1.65),500-24*sin((t-1.3)/0.35*PI),500))':shortest=1,format=yuv420p[out]" \
  -map '[out]' -t 3 -c:v libx264 -preset medium -crf 18 \
  -movflags +faststart -y Production/Previews/logo-motion-reference.mp4
