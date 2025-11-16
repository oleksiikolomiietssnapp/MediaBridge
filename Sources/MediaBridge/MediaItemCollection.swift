import Foundation

public protocol MediaItemCollectionProtocol {
    var count: Int { get }
}

public struct MediaItemCollection: MediaItemCollectionProtocol {
    public var count: Int
}
