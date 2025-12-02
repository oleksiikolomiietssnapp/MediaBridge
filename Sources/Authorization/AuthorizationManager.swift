import Foundation
import MediaPlayer

/// Protocol for managing access to the device's music library.
///
/// Conforming types handle requesting and checking authorization status for accessing the user's music library.
/// All authorization requests should go through this protocol to enable testing with mock implementations.
///
/// The protocol uses an associated type `T` that conforms to `MediaLibraryProtocol` to abstract the underlying
/// media library implementation, allowing for easy testing and dependency injection.
public protocol AuthorizationManagerProtocol {
    associatedtype T: MediaLibraryProtocol

    /// Requests authorization to access the music library.
    ///
    /// If authorization is already granted, returns immediately with `.authorized`.
    /// If not authorized, shows the system authorization dialog to the user.
    /// Safe to call multiple times.
    ///
    /// - Returns: The authorization status after the request completes
    /// - Throws: `AuthorizationManagerError.unauthorized` if the user denies access
    ///
    /// ## Example
    /// ```swift
    /// let manager = AuthorizationManager<MPMediaLibrary>()
    /// do {
    ///     let status = try await manager.authorize()
    ///     print("Authorization status: \(status)")
    /// } catch {
    ///     print("Authorization denied: \(error)")
    /// }
    /// ```
    @discardableResult
    func authorize() async throws -> MPMediaLibraryAuthorizationStatus

    /// Checks the current authorization status without requesting new permissions.
    ///
    /// Non-blocking call that returns the user's current authorization status.
    /// Does not trigger the authorization dialog.
    ///
    /// - Returns: The current `MPMediaLibraryAuthorizationStatus`
    ///
    /// ## Example
    /// ```swift
    /// let manager = AuthorizationManager<MPMediaLibrary>()
    /// let status = manager.status()
    /// if case .authorized = status {
    ///     // User has granted access
    /// } else {
    ///     // Not authorized, request permission
    /// }
    /// ```
    func status() -> MPMediaLibraryAuthorizationStatus
}

/// Default implementation of `AuthorizationManagerProtocol`.
///
/// This generic class manages the app's authorization status for accessing the device's music library.
/// The type parameter `T` specifies the underlying media library implementation (typically `MPMediaLibrary`).
/// It uses the provided media library type to handle authorization requests.
///
/// ## Generic Parameter
/// - `T`: The media library type conforming to `MediaLibraryProtocol` (e.g., `MPMediaLibrary`)
///
/// ## Usage
/// ```swift
/// let manager = AuthorizationManager<MPMediaLibrary>()
/// try await manager.authorize()  // Request authorization if needed
/// let songs = try await library.fetchSongs()  // Now able to access music library
/// ```
public class AuthorizationManager<T: MediaLibraryProtocol>: AuthorizationManagerProtocol {
    /// Initializes a new authorization manager for the specified media library type.
    public init() {}
    
    /// Requests authorization to access the music library.
    ///
    /// Checks if authorization is already granted. If so, returns immediately.
    /// Otherwise, presents the system authorization dialog to the user.
    ///
    /// - Returns: `.authorized` if permission is granted
    /// - Throws: `AuthorizationManagerError.unauthorized(status)` if access is denied
    @discardableResult
    public func authorize() async throws -> MPMediaLibraryAuthorizationStatus {
        guard status() != .authorized else {
            log.debug("Access to music library is already authorized")
            return .authorized
        }
        
        let status = await T.requestAuthorization()
        
        guard status == .authorized else {
            throw AuthorizationManagerError.unauthorized(status.description)
        }
        
        log.info("Access to music library is authorized")
        return .authorized
    }
    
    /// Returns the current authorization status for music library access.
    ///
    /// Queries the system for the current authorization status.
    /// Does not trigger any user prompts or permission dialogs.
    ///
    /// - Returns: The current `MPMediaLibraryAuthorizationStatus`
    public func status() -> MPMediaLibraryAuthorizationStatus {
        T.authorizationStatus()
    }
}


