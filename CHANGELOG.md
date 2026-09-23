# Changelog

All notable changes to DotoryCount are recorded in this file.

## [Unreleased] - 0.4.0 device preview

- Replaced the home-screen jar card with the app-icon-led motion study.
- Kept exact anniversary dates, milestones, and local SwiftData records intact.
- Added tap, app-open, and return-to-home replay with a Reduced Motion still image.
- The filmed jar is a fixed visual prototype; date-specific fill levels and the final
  behind-glass landing sequence remain to be produced before a 0.4.0 release.

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
