import Foundation
import MediaPlayer

public protocol MediaQueryProtocol {
    var items: [MPMediaItem]? { get }
    var groupingType: MPMediaGrouping { get set }
    init(filterPredicates: Set<MPMediaPredicate>?)
}

extension MPMediaQuery: MediaQueryProtocol { }
