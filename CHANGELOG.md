# Changelog

All notable changes to DotoryCount are recorded in this file.

## [0.1.1] - 2026-09-13

### Added

- Production app icon featuring a glass jar filled with acorns.
- Anniversary deletion with a confirmation step.
- Automated unit and core UI tests for pull requests and `main`.
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
