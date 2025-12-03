<div align="center">
  <img src="Sources/Documentation.docc/Resources/media_bridge_logo.png" width="200" alt="MediaBridge Logo">
</div>

# MediaBridge

A Swift bridge for MPMediaLibrary integration.

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-orange)](https://www.swift.org/)
[![iOS 15+](https://img.shields.io/badge/iOS-15%2B-blue)](https://www.apple.com/ios/)
[![License MIT](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/oleksiikolomiietssnapp/MediaBridge?color=purple)](https://github.com/oleksiikolomiietssnapp/MediaBridge/releases)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Foleksiikolomiietssnapp%2FMediaBridge%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/oleksiikolomiietssnapp/MediaBridge)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Foleksiikolomiietssnapp%2FMediaBridge%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/oleksiikolomiietssnapp/MediaBridge)

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

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to MediaBridge.

## License

MIT License - see the [LICENSE](LICENSE) file for details.
