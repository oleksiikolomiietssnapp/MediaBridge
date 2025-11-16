import Foundation
import MediaPlayer

public class AuthorizationManager {
    public init() {}

    public func authorize() async -> MPMediaLibraryAuthorizationStatus {
        await MPMediaLibrary.requestAuthorization()
    }

    public func status() -> MPMediaLibraryAuthorizationStatus {
        MPMediaLibrary.authorizationStatus()
    }
}
