import Foundation

public protocol MediaItemProtocol {
    var title: String? { get }
}

public struct MediaItem: MediaItemProtocol {
    public var title: String?
}
