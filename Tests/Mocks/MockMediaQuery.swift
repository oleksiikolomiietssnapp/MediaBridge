import MediaPlayer

@testable import MediaBridge

class MockMediaQueryWithFewMedia: MediaQueryProtocol {
    var items: [MPMediaItem]?
    var collections: [MPMediaItemCollection]?
    var groupingType: MPMediaGrouping

    required init(filterPredicates: Set<MPMediaPredicate>? = nil) {
        items = [.mock, .mock]
        collections = [.mock, .mock]
        groupingType = .title
    }
}

class MockMediaQueryWithNoMedia: MediaQueryProtocol {
    var items: [MPMediaItem]?
    var collections: [MPMediaItemCollection]?
    var groupingType: MPMediaGrouping

    required init(filterPredicates: Set<MPMediaPredicate>? = nil) {
        items = []
        collections = []
        groupingType = .title
    }
}

class MockMediaQueryWithNilMedia: MediaQueryProtocol {
    var items: [MPMediaItem]?
    var collections: [MPMediaItemCollection]?
    var groupingType: MPMediaGrouping

    required init(filterPredicates: Set<MPMediaPredicate>? = nil) {
        items = nil
        collections = nil
        groupingType = .title
    }
}
