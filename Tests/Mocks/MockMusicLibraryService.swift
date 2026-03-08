import MediaBridge
import MediaPlayer

final class MockMusicLibraryService: MusicLibraryServiceProtocol {
    typealias E = MockError
    typealias Q = MPMediaQuery

    enum MockError: Error {
        case noSong, noSongs, noAlbum, noAlbums, noArtist, noArtists, noPlaylist, noPlaylists
    }

    init(
        fetchSongError: MockError? = nil,
        fetchSongsError: MockError? = nil,
        songs: [MPMediaItem] = [.mock],
        albums: [MPMediaItemCollection] = [.mock],
        albumsError: MockError? = nil,
        fetchAlbumsError: MockError? = nil,
        artists: [MPMediaItemCollection] = [.mock],
        artistsError: MockError? = nil,
        fetchArtistsError: MockError? = nil,
        playlists: [MPMediaPlaylist] = [],
        playlistsError: MockError? = nil,
        fetchPlaylistsError: MockError? = nil
    ) {
        self.fetchSongError = fetchSongError
        self.fetchSongsError = fetchSongsError
        self.songs = songs
        self.albums = albums
        self.albumsError = albumsError
        self.fetchAlbumsError = fetchAlbumsError
        self.artists = artists
        self.artistsError = artistsError
        self.fetchArtistsError = fetchArtistsError
        self.playlists = playlists
        self.playlistsError = playlistsError
        self.fetchPlaylistsError = fetchPlaylistsError
    }

    @MainActor var fetchSongsError: MockError?
    func fetchAll(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws(MockError) -> [MPMediaItem] {
        guard let fetchSongsError = await fetchSongsError else { return [] }
        throw fetchSongsError
    }

    @MainActor var songs: [MPMediaItem]
    @MainActor var fetchSongError: MockError?
    @MainActor var noSongError: MockError?
    func fetch(
        _ type: MPMediaType,
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws(MockError) -> [MPMediaItem] {
        guard let fetchSongError = await fetchSongError else { return await songs }
        throw fetchSongError
    }

    @MainActor var albums: [MPMediaItemCollection]
    @MainActor var albumsError: MockError?
    @MainActor var artists: [MPMediaItemCollection]
    @MainActor var artistsError: MockError?
    func fetchCollections(
        _ type: MPMediaType,
        with predicate: MediaBridge.MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison,
        groupingType: MPMediaGrouping
    ) async throws -> [MPMediaItemCollection] {
        if groupingType == .artist {
            guard let artistsError = await artistsError else { return await artists }
            throw artistsError
        }
        guard let albumsError = await albumsError else { return await albums }
        throw albumsError
    }

    @MainActor var fetchAlbumsError: MockError?
    @MainActor var fetchArtistsError: MockError?
    func fetchAllCollections(_ type: MPMediaType, groupingType: MPMediaGrouping) async throws -> [MPMediaItemCollection] {
        if groupingType == .artist {
            guard let fetchArtistsError = await fetchArtistsError else { return [] }
            throw fetchArtistsError
        }
        guard let fetchAlbumsError = await fetchAlbumsError else { return [] }
        throw fetchAlbumsError
    }

    @MainActor var playlists: [MPMediaPlaylist]
    @MainActor var fetchPlaylistsError: MockError?
    func fetchAllPlaylists() async throws(MockError) -> [MPMediaPlaylist] {
        guard let fetchPlaylistsError = await fetchPlaylistsError else { return await playlists }
        throw fetchPlaylistsError
    }

    @MainActor var playlistsError: MockError?
    func fetchPlaylists(
        with predicate: MediaItemPredicateInfo,
        comparisonType: MPMediaPredicateComparison
    ) async throws(MockError) -> [MPMediaPlaylist] {
        guard let playlistsError = await playlistsError else { return await playlists }
        throw playlistsError
    }
}

extension MusicLibraryServiceProtocol where Self == MockMusicLibraryService {
    static var mock: MockMusicLibraryService {
        MockMusicLibraryService(albums: [], artists: [], playlists: [])
    }
}

extension MPMediaItem: @unchecked @retroactive Sendable {}
extension MPMediaItem {
    static var mock: MPMediaItem { MPMediaItem() }
}

extension MPMediaItemCollection: @unchecked @retroactive Sendable {}
extension MPMediaItemCollection {
    static var mock: MPMediaItemCollection { MPMediaItemCollection(items: []) }
}
