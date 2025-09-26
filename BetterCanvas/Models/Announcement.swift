import Foundation

/// Represents a Canvas course announcement
struct Announcement: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let message: String
    let postedAt: Date
    let author: User
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case message
        case postedAt = "posted_at"
        case author
    }
}