<div align="center">
  <img src="Sources/Documentation.docc/Resources/media_bridge_logo.png" width="200" alt="MediaBridge Logo">
</div>

# MediaBridge

A Swift bridge for MPMediaLibrary integration.

[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Foleksiikolomiietssnapp%2FMediaBridge%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/oleksiikolomiietssnapp/MediaBridge)
[![iOS 15.0+](https://img.shields.io/badge/iOS-15.0+-007AFF?logo=apple&logoColor=white)](https://www.apple.com/ios/)
[![visionOS 1.0+](https://img.shields.io/badge/🥽_visionOS-1.0+-7B68EE)](https://developer.apple.com/visionos/)
[![Latest Release](https://img.shields.io/github/v/release/oleksiikolomiietssnapp/MediaBridge?color=8B5CF6&logo=github&logoColor=white)](https://github.com/oleksiikolomiietssnapp/MediaBridge/releases)
[![Tests](https://github.com/oleksiikolomiietssnapp/MediaBridge/actions/workflows/test.yml/badge.svg)](https://github.com/oleksiikolomiietssnapp/MediaBridge/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-22C55E)](LICENSE)

## Quick Start

```swift
let library = MusicLibrary()
let songs = try await library.fetchSongs()
```

For SwiftUI, inject via environment:

```swift
extension EnvironmentValues {
    @Entry var library: MusicLibraryProtocol = MusicLibrary()
}

@Environment(\.library) var library
let songs = try await library.fetchSongs(sortedBy: \MPMediaItem.skipCount, order: .reverse)
```

Both the service layer and authorization manager use production implementations by default (`.live`), but you can provide custom implementations for testing or specialized behavior.

## Documentation

For more information visit [Documentation](https://swiftpackageindex.com/oleksiikolomiietssnapp/MediaBridge/main/documentation/mediabridge).

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to MediaBridge.

## License

MIT License - see the [LICENSE](LICENSE) file for details.
