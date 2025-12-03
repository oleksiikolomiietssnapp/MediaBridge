<div align="center">
  <img src="Sources/Documentation.docc/Resources/media_bridge_logo.png" width="200" alt="MediaBridge Logo">
</div>

# MediaBridge

A Swift bridge for MPMediaLibrary integration.

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

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to MediaBridge.

## License

MIT License - see the [LICENSE](LICENSE) file for details.
