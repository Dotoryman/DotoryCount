# Visual direction: match the app icon

The existing `AppIcon-1024.png` is the visual reference for the new home screen:
clear thick glass, a warm ivory background, natural brown acorns with scaled caps,
and a single acorn falling into the jar. The date counter is secondary.

`Textures/jar-clean.png` is an edited, transparent-background jar keyframe derived
from that art direction. `Previews/logo-motion-reference.mp4` is a three-second
**motion study**, not a finished in-app animation or a release asset. It uses the
existing `AcornSprite` above the jar image to check scale, timing, and composition.

Before integration, the final sequence needs the acorn to pass behind the front
glass, contact and settle into the pile without overlap, and support several
visually distinct fill levels plus a golden-acorn milestone variant. It should
also replay on tap, on opening the app, and when returning to the home screen.

Regenerate the motion study with `./Production/make_motion_reference.sh` after
installing `ffmpeg`. The Blender renderer in this folder is an experiment; its
current output does **not** meet the icon's quality bar and is not used by the app.
