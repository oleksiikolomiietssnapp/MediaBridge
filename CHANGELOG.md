# Changelog

All notable changes to MediaBridge are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2025-12-06

### Added
- New Swift-like method names for cleaner, more idiomatic API:
  - `songs()` - fetch all songs without sorting
  - `songs(sortedBy:order:)` - fetch songs with optional sorting
  - `songs(matching:comparisonType:)` - fetch songs matching a predicate
  - `mediaItems(ofType:matching:comparisonType:groupingType:)` - fetch generic media items

### Deprecated
- `fetchSongs()` - use `songs()` instead
- `fetchSongs(sortedBy:order:)` - use `songs(sortedBy:order:)` instead
- `fetchSong(with:comparisonType:)` - use `songs(matching:comparisonType:)` instead
- `fetch(_:with:comparisonType:groupingType:)` - use `mediaItems(ofType:matching:comparisonType:groupingType:)` instead

### Changed
- All documentation and examples now use new method names
- Example app updated to demonstrate new API
- Old methods remain functional but show deprecation warnings

## [0.4.1] - 2025-12-06

### Added
- Debug preview mocks for `MusicLibraryProtocol` to support SwiftUI previews during development

## [0.4.0] - 2025-12-05

### Added
- `authorizationStatus` property to `MusicLibraryProtocol` for checking music library access permissions
- `requestAuthorization()` method to explicitly request music library access from the user

## [0.3.1] - 2025-12-03

### Added
- Vision OS platform information in documentation

### Changed
- Updated badge links in README

### Fixed
- Removed duplicate Swift version badge

## [0.3.0] - 2025-12-03

### Changed
- Updated badges formatting in README for Swift and iOS versions

## [0.2.8] - 2025-12-03

### Added
- GitHub Actions workflow for automated testing on iOS simulator

## [0.2.7] - 2025-12-03

### Added
- Badges to README (Swift version, iOS version, License, Latest Release, SPI badges)

## [0.2.6] - 2025-12-03

### Added
- CHANGELOG.md file for version documentation

## [0.2.5] - 2025-12-03

### Added
- .spi.yml configuration for Swift Package Index optimization

## [0.2.4] - 2025-12-03

### Added
- Pull request template for standardized PR descriptions

## [0.2.3] - 2025-12-03

### Added
- MIT License file
- License information in README

## [0.2.2] - 2025-12-03

### Added
- Comprehensive DocC documentation for service layer
- Documentation page polishing
- README improvements

## [0.2.1] - 2025-11-15

### Added
- Unit tests for service layer
- Mock implementations for testing

## [0.2.0] - 2025-11-15

### Added
- Authorization manager with media library access control
- Service layer for media queries
- Protocol-based architecture for dependency injection
- Mock implementations for testing
- Comprehensive DocC documentation

## [0.1.0] - 2025-11-15

### Added
- Initial project setup
- Basic MusicLibrary implementation
- MPMediaLibrary integration
- Swift Testing framework integration
- Package.swift configuration

---

For detailed information about each release, see the [GitHub Releases](https://github.com/oleksiikolomiietssnapp/MediaBridge/releases) page.
