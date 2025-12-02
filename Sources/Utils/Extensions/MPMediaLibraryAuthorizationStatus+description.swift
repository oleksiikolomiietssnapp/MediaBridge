import Foundation
import MediaPlayer

extension MPMediaLibraryAuthorizationStatus {
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
