import MediaPlayer

public protocol MusicLibraryServiceProtocol {
    associatedtype E: Error
    func fetchSongs() async throws(E) -> [MPMediaItem]
}

public final class MusicLibraryService: MusicLibraryServiceProtocol {
    public enum MusicLibraryServiceError: Error, LocalizedError {
        case noSongsFound
        public var errorDescription: String? {
            switch self {
            case .noSongsFound:
                "No songs found"
            }
        }
    }

    public init() {}

    public func fetchSongs() async throws(MusicLibraryServiceError) -> [MPMediaItem] {
        if let songs = MPMediaQuery.songs().items {
            return songs
        } else {
            throw .noSongsFound
        }
    }
}

extension MusicLibraryServiceProtocol where Self == MusicLibraryService, E == MusicLibraryService.MusicLibraryServiceError {
    public static var live: MusicLibraryService {
        MusicLibraryService()
    }
}
