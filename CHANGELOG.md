# Changelog

All notable changes to DotoryCount are recorded in this file.

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
