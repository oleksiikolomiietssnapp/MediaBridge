import Foundation

public final class MusicLibrary {
    public let auth: AuthorizationManager

    public init(auth: AuthorizationManager = AuthorizationManager()) async throws {
        self.auth = auth

        let status = await auth.authorize()
        switch status {
        case .authorized:
            print("Authorized")
        case .denied:
            print("Denied")
        case .notDetermined:
            print("Not Determined")
        case .restricted:
            print("Restricted")
        @unknown default:
            print("Unknown: \(status)")
        }
    }
}
