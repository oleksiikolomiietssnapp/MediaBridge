import MediaBridge
import MediaPlayer

class MockMediaLibraryNotDetermined: MediaLibraryProtocol {
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus { .notDetermined }
    static func requestAuthorization() async -> MPMediaLibraryAuthorizationStatus { .notDetermined }
}

class MockMediaLibraryAuthorized: MediaLibraryProtocol {
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus { .authorized }
    static func requestAuthorization() async -> MPMediaLibraryAuthorizationStatus { .authorized }
}

class MockMediaLibraryDenied_Denied: MediaLibraryProtocol {
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus { .denied }
    static func requestAuthorization() async -> MPMediaLibraryAuthorizationStatus { .denied }
}

class MockMediaLibraryDenied_Authorized: MediaLibraryProtocol {
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus { .denied }
    static func requestAuthorization() async -> MPMediaLibraryAuthorizationStatus { .authorized }
}

class MockMediaLibraryRestricted: MediaLibraryProtocol {
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus { .restricted }
    static func requestAuthorization() async -> MPMediaLibraryAuthorizationStatus { .restricted }
}
