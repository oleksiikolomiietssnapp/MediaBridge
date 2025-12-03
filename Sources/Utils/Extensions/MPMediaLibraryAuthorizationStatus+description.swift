import Foundation
import MediaPlayer

extension MPMediaLibraryAuthorizationStatus {
    /// A human-readable description of the authorization status.
    ///
    /// Returns a string representation of the authorization status:
    /// - `.notDetermined` returns "notDetermined"
    /// - `.denied` returns "denied"
    /// - `.restricted` returns "restricted"
    /// - `.authorized` returns "authorized"
    /// - Unknown states return "Unknown state: {raw value}"
    public var description: String {
        switch self {
        case .notDetermined:
            "notDetermined"
        case .denied:
            "denied"
        case .restricted:
            "restricted"
        case .authorized:
            "authorized"
        @unknown default:
            "Unknown state: \(self)"
        }
    }
}
