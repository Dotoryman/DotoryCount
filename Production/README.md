# Visual direction: match the app icon

The existing `AppIcon-1024.png` is the visual reference for the new home screen:
clear thick glass, a warm ivory background, natural brown acorns with scaled caps,
and a single acorn falling into the jar. The date counter is secondary.

`Textures/jar-clean.png` is the approved transparent-background art-direction
reference. The built-in image-generation edit tool produced two project assets
from it: `Textures/jar-empty-base.png` removes the original acorn pile, and
`Textures/jar-glass-front.png` preserves the glass rim, walls, and highlights
with a transparent center for foreground compositing. They are copied into
`DotoryCount/Assets.xcassets` and layered around the existing acorn sprites.
The edit prompts held the jar geometry, teal reflections, warm lighting,
position, and transparent outer canvas fixed; only the acorns or central
glass opacity changed.

`Previews/logo-motion-reference.mp4` remains an earlier three-second **motion
study**, not the current in-app animation or a release asset. The app now
draws 36 date-dependent visual stages and animates the newest acorn in SwiftUI.

Before an official release, inspect the pile and the rim crossing on the user's
phone, especially at sparse, middle, full, and golden-acorn stages.

Regenerate the motion study with `./Production/make_motion_reference.sh` after
installing `ffmpeg`. The Blender renderer in this folder is an experiment; its
current output does **not** meet the icon's quality bar and is not used by the app.
