import Foundation

/// Represents a Canvas user
struct User: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let email: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle ID as either String or Int
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = idString
        } else if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = String(idInt)
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.id], debugDescription: "ID must be either String or Int"))
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL)
    }
}