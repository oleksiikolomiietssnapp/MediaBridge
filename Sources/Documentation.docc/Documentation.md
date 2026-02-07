# ``MediaBridge``

@Metadata {
    @PageImage(purpose: icon, source:"media_bridge_logo")
    @SupportedLanguage(swift)
    @PageColor(orange)
}

A Swift bridge for MPMediaLibrary integration. Provides easy, lightweight and flexible methods to fetch media library content from you phone.

## Overview

MediaBridge simplifies access to the device's music library with a clean API that handles authorization automatically. It's built on two core components: a service layer for querying and an authorization manager for permissions.

### General Usage

For most use cases, simply create a `MusicLibrary` instance and start fetching:

```swift
let library = MusicLibrary()
let songs = try await library.songs()
```

Or inject it into SwiftUI views via environment values:

```swift
extension EnvironmentValues {
    @Entry var library: MusicLibraryProtocol = MusicLibrary()
}

struct ContentView: View {
    @Environment(\.library) var library

    var body: some View {
        VStack {
            // Use library to fetch songs
        }
        .task {
            // Optional: Request authorization if not yet determined
            if library.authorizationStatus == .notDetermined {
                try await library.requestAuthorization()
            }
        }
    }
}
```

### Service Layer & Authorization

Both the service layer and authorization manager use production-ready implementations by default (`.live`), but you can provide custom implementations for testing or specialized behavior:

```swift
let customAuth = MyAuthorizationManager()
let customService = MyMusicLibraryService()
let library = MusicLibrary(auth: customAuth, service: customService)
```

## Topics

### Fetching Media Items
- ``MusicLibrary``
- ``MusicLibraryProtocol``

### Service Layer
- ``MusicLibraryServiceProtocol``
- ``MusicLibraryService``
- ``MediaQueryProtocol``
- ``MusicLibraryServiceError``

### Filtering & Predicates
- ``MediaItemPredicateInfo``

### Authorization
- ``AuthorizationManagerProtocol``
- ``AuthorizationManager``
- ``MediaLibraryProtocol``
- ``AuthorizationManagerError``

