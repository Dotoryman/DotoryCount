# Changelog

All notable changes to DotoryCount are recorded in this file.

## [0.5.0] - 2026-09-26

- Apply Liquid Glass to the dashboard action and information panel on iOS 26+,
  with material fallbacks on older supported iOS versions.
- Add a compact rectangular Lock Screen day counter and a small Home Screen
  widget with the photographic jar, staged acorn pile, and D+ counter.
- Share the current anniversary summary with WidgetKit and refresh its timeline
  after edits, deletion, and the next calendar day.
- Bumped the app and widget to version 0.5.0 (build 11).

## [0.4.2] - 2026-09-24

- Keep the photographed glass floor behind the acorns while retaining the
  front rim and side reflections. A softly feathered oval removes only the
  foreground floor overlay that made acorns appear behind the base.
- Add a contact shadow along the inner floor to ground sparse and full piles.
- Bumped the app to version 0.4.2 (build 10).

## [0.4.1] - 2026-09-24

- Keep the iPhone experience in portrait, where the photographic jar and date
  card have the intended spacing. This prevents overlap while the device is
  held sideways.
- Bumped the app to version 0.4.1 (build 9).

## [0.4.0] - 2026-09-24

- Replaced the fixed home-screen film with an icon-matched glass jar assembled from
  a photographic empty jar, glass foreground, and individual acorn artwork.
- Added 36 visual fill stages, including daily changes for the first eight days;
  exact anniversary dates and yearly capacity remain unchanged.
- Varied each replay's entry point, tumble, bounce, roll, and resting angle while
  keeping the acorn's entry through the jar mouth visible.
- Moved the jar above the supporting date panel so the two no longer overlap.
- Kept exact anniversary dates, milestones, and local SwiftData records intact.
- Kept tap, app-open, and return-to-home replay with a Reduced Motion still scene.
- Replaced uniform rows with deterministic curved-floor collision placement.
- Added side/back acorn views, varied resting angles, contact shadows, a base
  shadow, softer depth shading, and correctly scaled golden acorns.
- Reworked the base-date control into a dedicated calendar sheet with direct
  date entry and quick presets for today, yesterday, and one year ago.
- Added unit coverage for stable non-overlapping placement and date parsing.
- Bumped the app to version 0.4.0 (build 8).

## [0.3.1] - 2026-09-20

### Added

- Replayable acorn-drop animation whenever the dashboard is tapped.
- Acorn-drop replay after app launch, foreground return, and dismissal of editor or milestone screens.
- UI coverage for tap-triggered and screen-return animations.

### Fixed

- Preserved the square sprite aspect ratio in Canvas so acorns are no longer stretched.
- Tightened scale, rotation, overlap, and row spacing for a more natural layered pile.
- Bumped the app to version 0.3.1 (build 5).

## [0.3.0] - 2026-09-19

### Added

- Photorealistic acorn and golden-acorn artwork derived from the app icon's visual language.
- Golden acorns for every 100-day milestone and yearly anniversary.
- A celebration banner for milestones and a tappable milestone detail sheet.
- Unit and UI coverage for visual intervals and golden milestones.

### Changed

- Rebuilt the glass jar with layered reflections, refraction, rim depth, and a curved glass base.
- Replaced one-sprite-per-day rendering with a dense visual scale: exact daily acorns through day 14, then one acorn per seven-day interval.
- Preserved exact day and milestone calculations while limiting a yearly jar to about 64 large, detailed acorns.
- Bumped the app to version 0.3.0 (build 4).

## [0.2.0] - 2026-09-14

### Added

- A daily acorn drop animation that plays once when a new day is first viewed.
- Stable, deterministic acorn placement for up to 366 days.
- Dedicated light and dark appearance colors.
- Layout tests and UI coverage for a populated acorn jar.
- Reduced Motion fallback for the daily animation.

### Changed

- Replaced the flat oval grid with individually shaped, shaded, and rotated acorns.
- Refined the glass jar with adaptive highlights, gradients, and depth.
- Bumped the app to version 0.2.0 (build 3).

## [0.1.1] - 2026-09-13

### Added

- Production app icon featuring a glass jar filled with acorns.
- Anniversary deletion with a confirmation step.
- Automated builds and unit tests for pull requests and `main`.
- Unit coverage for milestone selection and leap-year jar capacity.
- UI coverage for creating and deleting an anniversary.

### Changed

- Improved the anniversary editor with title validation, a character counter,
  keyboard focus, and clearer save behavior.

### Fixed

- Persistence errors now roll back safely and appear to the user instead of
  failing silently.

## [0.1.0] - 2026-09-12

### Added

- Initial anniversary tracking experience.
- D-day calculations and yearly acorn jars.
- Local SwiftData persistence.
- Initial unit and UI tests.
