import Foundation

typealias GistListResponse = [GistResponse]

// MARK: - GistResponse
struct GistResponse: Decodable {
    let url: String?
    let forksURL: String?
    let commitsURL: String?
    let id: String
    let nodeID: String?
    let gitPullURL: String?
    let gitPushURL: String?
    let htmlURL: String?
    let files: [String: FileResponse]?
    let gistResponsePublic: Bool?
    let createdAt: String?
    let updatedAt: String?
    let gistResponseDescription: String?
    let comments: Int?
    let commentsURL: String?
    let owner: OwnerResponse?
    let truncated: Bool?

    enum CodingKeys: String, CodingKey {
        case url = "url"
        case forksURL = "forks_url"
        case commitsURL = "commits_url"
        case id = "id"
        case nodeID = "node_id"
        case gitPullURL = "git_pull_url"
        case gitPushURL = "git_push_url"
        case htmlURL = "html_url"
        case files = "files"
        case gistResponsePublic = "public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case gistResponseDescription = "description"
        case comments = "comments"
        case commentsURL = "comments_url"
        case owner = "owner"
        case truncated = "truncated"
    }
}

// MARK: - FileResponse
struct FileResponse: Decodable {
    let fileName: String?
    let type: String?
    let language: String?
    let rawURL: String?
    let size: Int?

    enum CodingKeys: String, CodingKey {
        case fileName = "filename"
        case type = "type"
        case language = "language"
        case rawURL = "raw_url"
        case size = "size"
    }
}

// MARK: - OwnerResponse
struct OwnerResponse: Decodable {
    let login: String?
    let id: Int
    let nodeID: String?
    let avatarURL: String?
    let gravatarID: String?
    let url: String?
    let htmlURL: String?
    let followersURL: String?
    let followingURL: String?
    let gistsURL: String?
    let starredURL: String?
    let subscriptionsURL: String?
    let organizationsURL: String?
    let reposURL: String?
    let eventsURL: String?
    let receivedEventsURL: String?
    let type: String?
    let siteAdmin: Bool?

    enum CodingKeys: String, CodingKey {
        case login = "login"
        case id = "id"
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url = "url"
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type = "type"
        case siteAdmin = "site_admin"
    }
}
