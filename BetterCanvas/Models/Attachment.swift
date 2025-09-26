import Foundation

/// Represents a file attachment
struct CanvasAttachment: Codable, Hashable {
  let id: String
  let filename: String?
  let displayName: String?
  let contentType: String?
  let url: String?
  let size: Int?
  let createdAt: Date?
  let updatedAt: Date?
  let unlockAt: Date?
  let locked: Bool?
  let hidden: Bool?
  let lockedForUser: Bool?
  let thumbnailUrl: String?
  let previewUrl: String?

  enum CodingKeys: String, CodingKey {
    case id
    case filename
    case displayName = "display_name"
    case contentType = "content-type"
    case url
    case size
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case unlockAt = "unlock_at"
    case locked
    case hidden
    case lockedForUser = "locked_for_user"
    case thumbnailUrl = "thumbnail_url"
    case previewUrl = "preview_url"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // Handle ID as either String or Int
    if let idString = try? container.decode(String.self, forKey: .id) {
      self.id = idString
    } else if let idInt = try? container.decode(Int.self, forKey: .id) {
      self.id = String(idInt)
    } else {
      throw DecodingError.typeMismatch(
        String.self,
        DecodingError.Context(
          codingPath: [CodingKeys.id],
          debugDescription: "ID must be either String or Int"
        )
      )
    }

    self.filename = try container.decodeIfPresent(String.self, forKey: .filename)
    self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
    self.contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
    self.url = try container.decodeIfPresent(String.self, forKey: .url)
    self.size = try container.decodeIfPresent(Int.self, forKey: .size)
    self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    self.unlockAt = try container.decodeIfPresent(Date.self, forKey: .unlockAt)
    self.locked = try container.decodeIfPresent(Bool.self, forKey: .locked)
    self.hidden = try container.decodeIfPresent(Bool.self, forKey: .hidden)
    self.lockedForUser = try container.decodeIfPresent(Bool.self, forKey: .lockedForUser)
    self.thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
    self.previewUrl = try container.decodeIfPresent(String.self, forKey: .previewUrl)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(filename, forKey: .filename)
    try container.encodeIfPresent(displayName, forKey: .displayName)
    try container.encodeIfPresent(contentType, forKey: .contentType)
    try container.encodeIfPresent(url, forKey: .url)
    try container.encodeIfPresent(size, forKey: .size)
    try container.encodeIfPresent(createdAt, forKey: .createdAt)
    try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    try container.encodeIfPresent(unlockAt, forKey: .unlockAt)
    try container.encodeIfPresent(locked, forKey: .locked)
    try container.encodeIfPresent(hidden, forKey: .hidden)
    try container.encodeIfPresent(lockedForUser, forKey: .lockedForUser)
    try container.encodeIfPresent(thumbnailUrl, forKey: .thumbnailUrl)
    try container.encodeIfPresent(previewUrl, forKey: .previewUrl)
  }
}
