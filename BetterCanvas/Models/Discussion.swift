import Foundation

/// Represents a Canvas discussion topic
struct Discussion: Codable, Identifiable, Hashable {
  let id: String
  let title: String
  let message: String?
  let htmlUrl: String
  let postedAt: Date?
  let lastReplyAt: Date?
  let requireInitialPost: Bool?
  let userCanSeePosts: Bool?
  let discussionSubentryCount: Int?
  let readState: String?
  let unreadCount: Int?
  let subscribed: Bool?
  let subscriptionHold: String?
  let assignmentId: String?
  let delayedPostAt: Date?
  let published: Bool?
  let lockAt: Date?
  let lockedForUser: Bool?
  let lockInfo: LockInfo?
  let lockExplanation: String?
  let userName: String?
  let topicChildren: [String]?
  let groupTopicChildren: [GroupTopicChild]?
  let rootTopicId: String?
  let podcastUrl: String?
  let discussionType: String?
  let groupCategoryId: String?
  let attachments: [CanvasAttachment]?
  let permissions: DiscussionPermissions?
  let allowRating: Bool?
  let onlyGradersCanRate: Bool?
  let sortByRating: Bool?
  let isAnnouncementOnly: Bool?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case message
    case htmlUrl = "html_url"
    case postedAt = "posted_at"
    case lastReplyAt = "last_reply_at"
    case requireInitialPost = "require_initial_post"
    case userCanSeePosts = "user_can_see_posts"
    case discussionSubentryCount = "discussion_subentry_count"
    case readState = "read_state"
    case unreadCount = "unread_count"
    case subscribed
    case subscriptionHold = "subscription_hold"
    case assignmentId = "assignment_id"
    case delayedPostAt = "delayed_post_at"
    case published
    case lockAt = "lock_at"
    case lockedForUser = "locked_for_user"
    case lockInfo = "lock_info"
    case lockExplanation = "lock_explanation"
    case userName = "user_name"
    case topicChildren = "topic_children"
    case groupTopicChildren = "group_topic_children"
    case rootTopicId = "root_topic_id"
    case podcastUrl = "podcast_url"
    case discussionType = "discussion_type"
    case groupCategoryId = "group_category_id"
    case attachments
    case permissions
    case allowRating = "allow_rating"
    case onlyGradersCanRate = "only_graders_can_rate"
    case sortByRating = "sort_by_rating"
    case isAnnouncementOnly = "is_announcement_only"
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

    self.title = try container.decode(String.self, forKey: .title)
    self.message = try container.decodeIfPresent(String.self, forKey: .message)
    self.htmlUrl = try container.decode(String.self, forKey: .htmlUrl)
    self.postedAt = try container.decodeIfPresent(Date.self, forKey: .postedAt)
    self.lastReplyAt = try container.decodeIfPresent(Date.self, forKey: .lastReplyAt)
    self.requireInitialPost = try container.decodeIfPresent(Bool.self, forKey: .requireInitialPost)
    self.userCanSeePosts = try container.decodeIfPresent(Bool.self, forKey: .userCanSeePosts)
    self.discussionSubentryCount = try container.decodeIfPresent(
      Int.self, forKey: .discussionSubentryCount)
    self.readState = try container.decodeIfPresent(String.self, forKey: .readState)
    self.unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount)
    self.subscribed = try container.decodeIfPresent(Bool.self, forKey: .subscribed)
    self.subscriptionHold = try container.decodeIfPresent(String.self, forKey: .subscriptionHold)

    // Handle assignmentId as either String or Int
    do {
      self.assignmentId = try container.decodeIfPresent(String.self, forKey: .assignmentId)
    } catch {
      do {
        if let assignmentIdInt = try container.decodeIfPresent(Int.self, forKey: .assignmentId) {
          self.assignmentId = String(assignmentIdInt)
        } else {
          self.assignmentId = nil
        }
      } catch {
        self.assignmentId = nil
      }
    }

    self.delayedPostAt = try container.decodeIfPresent(Date.self, forKey: .delayedPostAt)
    self.published = try container.decodeIfPresent(Bool.self, forKey: .published)
    self.lockAt = try container.decodeIfPresent(Date.self, forKey: .lockAt)
    self.lockedForUser = try container.decodeIfPresent(Bool.self, forKey: .lockedForUser)
    self.lockInfo = try container.decodeIfPresent(LockInfo.self, forKey: .lockInfo)
    self.lockExplanation = try container.decodeIfPresent(String.self, forKey: .lockExplanation)
    self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
    self.topicChildren = try container.decodeIfPresent([String].self, forKey: .topicChildren)
    self.groupTopicChildren = try container.decodeIfPresent(
      [GroupTopicChild].self, forKey: .groupTopicChildren)

    // Handle rootTopicId as either String or Int
    do {
      self.rootTopicId = try container.decodeIfPresent(String.self, forKey: .rootTopicId)
    } catch {
      do {
        if let rootTopicIdInt = try container.decodeIfPresent(Int.self, forKey: .rootTopicId) {
          self.rootTopicId = String(rootTopicIdInt)
        } else {
          self.rootTopicId = nil
        }
      } catch {
        self.rootTopicId = nil
      }
    }

    self.podcastUrl = try container.decodeIfPresent(String.self, forKey: .podcastUrl)
    self.discussionType = try container.decodeIfPresent(String.self, forKey: .discussionType)

    // Handle groupCategoryId as either String or Int
    do {
      self.groupCategoryId = try container.decodeIfPresent(String.self, forKey: .groupCategoryId)
    } catch {
      do {
        if let groupCategoryIdInt = try container.decodeIfPresent(
          Int.self, forKey: .groupCategoryId)
        {
          self.groupCategoryId = String(groupCategoryIdInt)
        } else {
          self.groupCategoryId = nil
        }
      } catch {
        self.groupCategoryId = nil
      }
    }

    self.attachments = try container.decodeIfPresent([CanvasAttachment].self, forKey: .attachments)
    self.permissions = try container.decodeIfPresent(
      DiscussionPermissions.self, forKey: .permissions)
    self.allowRating = try container.decodeIfPresent(Bool.self, forKey: .allowRating)
    self.onlyGradersCanRate = try container.decodeIfPresent(Bool.self, forKey: .onlyGradersCanRate)
    self.sortByRating = try container.decodeIfPresent(Bool.self, forKey: .sortByRating)
    self.isAnnouncementOnly = try container.decodeIfPresent(Bool.self, forKey: .isAnnouncementOnly)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id, forKey: .id)
    try container.encode(title, forKey: .title)
    try container.encodeIfPresent(message, forKey: .message)
    try container.encode(htmlUrl, forKey: .htmlUrl)
    try container.encodeIfPresent(postedAt, forKey: .postedAt)
    try container.encodeIfPresent(lastReplyAt, forKey: .lastReplyAt)
    try container.encodeIfPresent(requireInitialPost, forKey: .requireInitialPost)
    try container.encodeIfPresent(userCanSeePosts, forKey: .userCanSeePosts)
    try container.encodeIfPresent(discussionSubentryCount, forKey: .discussionSubentryCount)
    try container.encodeIfPresent(readState, forKey: .readState)
    try container.encodeIfPresent(unreadCount, forKey: .unreadCount)
    try container.encodeIfPresent(subscribed, forKey: .subscribed)
    try container.encodeIfPresent(subscriptionHold, forKey: .subscriptionHold)
    try container.encodeIfPresent(assignmentId, forKey: .assignmentId)
    try container.encodeIfPresent(delayedPostAt, forKey: .delayedPostAt)
    try container.encodeIfPresent(published, forKey: .published)
    try container.encodeIfPresent(lockAt, forKey: .lockAt)
    try container.encodeIfPresent(lockedForUser, forKey: .lockedForUser)
    try container.encodeIfPresent(lockInfo, forKey: .lockInfo)
    try container.encodeIfPresent(lockExplanation, forKey: .lockExplanation)
    try container.encodeIfPresent(userName, forKey: .userName)
    try container.encodeIfPresent(topicChildren, forKey: .topicChildren)
    try container.encodeIfPresent(groupTopicChildren, forKey: .groupTopicChildren)
    try container.encodeIfPresent(rootTopicId, forKey: .rootTopicId)
    try container.encodeIfPresent(podcastUrl, forKey: .podcastUrl)
    try container.encodeIfPresent(discussionType, forKey: .discussionType)
    try container.encodeIfPresent(groupCategoryId, forKey: .groupCategoryId)
    try container.encodeIfPresent(attachments, forKey: .attachments)
    try container.encodeIfPresent(permissions, forKey: .permissions)
    try container.encodeIfPresent(allowRating, forKey: .allowRating)
    try container.encodeIfPresent(onlyGradersCanRate, forKey: .onlyGradersCanRate)
    try container.encodeIfPresent(sortByRating, forKey: .sortByRating)
    try container.encodeIfPresent(isAnnouncementOnly, forKey: .isAnnouncementOnly)
  }

  // MARK: - Computed Properties

  var authorName: String? {
    return userName
  }

  var repliesCount: Int? {
    return discussionSubentryCount
  }

  var isRead: Bool {
    return readState == "read"
  }

  var hasUnreadPosts: Bool {
    return (unreadCount ?? 0) > 0
  }

  var isLocked: Bool {
    if let lockAt = lockAt {
      return Date() > lockAt
    }
    return lockedForUser ?? false
  }

  var canPost: Bool {
    return permissions?.reply == true && !isLocked
  }

  var formattedPostedDate: String? {
    guard let postedAt = postedAt else { return nil }

    let formatter = DateFormatter()
    if Calendar.current.isDateInToday(postedAt) {
      formatter.dateFormat = "'Today at' h:mm a"
    } else if Calendar.current.isDateInYesterday(postedAt) {
      formatter.dateFormat = "'Yesterday at' h:mm a"
    } else {
      formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
    }

    return formatter.string(from: postedAt)
  }

  var formattedLastReplyDate: String? {
    guard let lastReplyAt = lastReplyAt else { return nil }

    let formatter = DateFormatter()
    if Calendar.current.isDateInToday(lastReplyAt) {
      formatter.dateFormat = "'Today at' h:mm a"
    } else if Calendar.current.isDateInYesterday(lastReplyAt) {
      formatter.dateFormat = "'Yesterday at' h:mm a"
    } else {
      formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
    }

    return formatter.string(from: lastReplyAt)
  }

  var isAnnouncement: Bool {
    return isAnnouncementOnly == true
  }
}

/// Represents detailed discussion information with entries
struct DiscussionDetail: Codable, Identifiable, Hashable {
  let id: String
  let title: String
  let message: String?
  let htmlUrl: String
  let postedAt: Date?
  let lastReplyAt: Date?
  let requireInitialPost: Bool?
  let userCanSeePosts: Bool?
  let discussionSubentryCount: Int?
  let readState: String?
  let unreadCount: Int?
  let subscribed: Bool?
  let subscriptionHold: String?
  let assignmentId: String?
  let delayedPostAt: Date?
  let published: Bool?
  let lockAt: Date?
  let lockedForUser: Bool?
  let lockInfo: LockInfo?
  let lockExplanation: String?
  let userName: String?
  let topicChildren: [String]?
  let groupTopicChildren: [GroupTopicChild]?
  let rootTopicId: String?
  let podcastUrl: String?
  let discussionType: String?
  let groupCategoryId: String?
  let attachments: [CanvasAttachment]?
  let permissions: DiscussionPermissions?
  let allowRating: Bool?
  let onlyGradersCanRate: Bool?
  let sortByRating: Bool?
  let isAnnouncementOnly: Bool?
  let view: [DiscussionEntry]?

  enum CodingKeys: String, CodingKey {
    case id, title, message
    case htmlUrl = "html_url"
    case postedAt = "posted_at"
    case lastReplyAt = "last_reply_at"
    case requireInitialPost = "require_initial_post"
    case userCanSeePosts = "user_can_see_posts"
    case discussionSubentryCount = "discussion_subentry_count"
    case readState = "read_state"
    case unreadCount = "unread_count"
    case subscribed
    case subscriptionHold = "subscription_hold"
    case assignmentId = "assignment_id"
    case delayedPostAt = "delayed_post_at"
    case published
    case lockAt = "lock_at"
    case lockedForUser = "locked_for_user"
    case lockInfo = "lock_info"
    case lockExplanation = "lock_explanation"
    case userName = "user_name"
    case topicChildren = "topic_children"
    case groupTopicChildren = "group_topic_children"
    case rootTopicId = "root_topic_id"
    case podcastUrl = "podcast_url"
    case discussionType = "discussion_type"
    case groupCategoryId = "group_category_id"
    case attachments, permissions
    case allowRating = "allow_rating"
    case onlyGradersCanRate = "only_graders_can_rate"
    case sortByRating = "sort_by_rating"
    case isAnnouncementOnly = "is_announcement_only"
    case view
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

    self.title = try container.decode(String.self, forKey: .title)
    self.message = try container.decodeIfPresent(String.self, forKey: .message)
    self.htmlUrl = try container.decode(String.self, forKey: .htmlUrl)
    self.postedAt = try container.decodeIfPresent(Date.self, forKey: .postedAt)
    self.lastReplyAt = try container.decodeIfPresent(Date.self, forKey: .lastReplyAt)
    self.requireInitialPost = try container.decodeIfPresent(Bool.self, forKey: .requireInitialPost)
    self.userCanSeePosts = try container.decodeIfPresent(Bool.self, forKey: .userCanSeePosts)
    self.discussionSubentryCount = try container.decodeIfPresent(
      Int.self, forKey: .discussionSubentryCount)
    self.readState = try container.decodeIfPresent(String.self, forKey: .readState)
    self.unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount)
    self.subscribed = try container.decodeIfPresent(Bool.self, forKey: .subscribed)
    self.subscriptionHold = try container.decodeIfPresent(String.self, forKey: .subscriptionHold)

    // Handle assignmentId as either String or Int
    do {
      self.assignmentId = try container.decodeIfPresent(String.self, forKey: .assignmentId)
    } catch {
      do {
        if let assignmentIdInt = try container.decodeIfPresent(Int.self, forKey: .assignmentId) {
          self.assignmentId = String(assignmentIdInt)
        } else {
          self.assignmentId = nil
        }
      } catch {
        self.assignmentId = nil
      }
    }

    self.delayedPostAt = try container.decodeIfPresent(Date.self, forKey: .delayedPostAt)
    self.published = try container.decodeIfPresent(Bool.self, forKey: .published)
    self.lockAt = try container.decodeIfPresent(Date.self, forKey: .lockAt)
    self.lockedForUser = try container.decodeIfPresent(Bool.self, forKey: .lockedForUser)
    self.lockInfo = try container.decodeIfPresent(LockInfo.self, forKey: .lockInfo)
    self.lockExplanation = try container.decodeIfPresent(String.self, forKey: .lockExplanation)
    self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
    self.topicChildren = try container.decodeIfPresent([String].self, forKey: .topicChildren)
    self.groupTopicChildren = try container.decodeIfPresent(
      [GroupTopicChild].self, forKey: .groupTopicChildren)

    // Handle rootTopicId as either String or Int
    do {
      self.rootTopicId = try container.decodeIfPresent(String.self, forKey: .rootTopicId)
    } catch {
      do {
        if let rootTopicIdInt = try container.decodeIfPresent(Int.self, forKey: .rootTopicId) {
          self.rootTopicId = String(rootTopicIdInt)
        } else {
          self.rootTopicId = nil
        }
      } catch {
        self.rootTopicId = nil
      }
    }

    self.podcastUrl = try container.decodeIfPresent(String.self, forKey: .podcastUrl)
    self.discussionType = try container.decodeIfPresent(String.self, forKey: .discussionType)

    // Handle groupCategoryId as either String or Int
    do {
      self.groupCategoryId = try container.decodeIfPresent(String.self, forKey: .groupCategoryId)
    } catch {
      do {
        if let groupCategoryIdInt = try container.decodeIfPresent(
          Int.self, forKey: .groupCategoryId)
        {
          self.groupCategoryId = String(groupCategoryIdInt)
        } else {
          self.groupCategoryId = nil
        }
      } catch {
        self.groupCategoryId = nil
      }
    }

    self.attachments = try container.decodeIfPresent([CanvasAttachment].self, forKey: .attachments)
    self.permissions = try container.decodeIfPresent(
      DiscussionPermissions.self, forKey: .permissions)
    self.allowRating = try container.decodeIfPresent(Bool.self, forKey: .allowRating)
    self.onlyGradersCanRate = try container.decodeIfPresent(Bool.self, forKey: .onlyGradersCanRate)
    self.sortByRating = try container.decodeIfPresent(Bool.self, forKey: .sortByRating)
    self.isAnnouncementOnly = try container.decodeIfPresent(Bool.self, forKey: .isAnnouncementOnly)
    self.view = try container.decodeIfPresent([DiscussionEntry].self, forKey: .view)
  }
}

/// Represents a discussion entry/reply
struct DiscussionEntry: Codable, Identifiable, Hashable {
  let id: String
  let userId: String?
  let parentId: String?
  let createdAt: Date?
  let updatedAt: Date?
  let message: String?
  let userName: String?
  let userDisplayName: String?
  let replies: [DiscussionEntry]?
  let attachment: CanvasAttachment?
  let editorId: String?
  let deleted: Bool?
  let readState: String?
  let forcedReadState: Bool?
  let ratingCount: Int?
  let ratingSum: Int?

  enum CodingKeys: String, CodingKey {
    case id
    case userId = "user_id"
    case parentId = "parent_id"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case message
    case userName = "user_name"
    case userDisplayName = "user_display_name"
    case replies
    case attachment
    case editorId = "editor_id"
    case deleted
    case readState = "read_state"
    case forcedReadState = "forced_read_state"
    case ratingCount = "rating_count"
    case ratingSum = "rating_sum"
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

    // Handle userId as either String or Int
    if let userIdString = try? container.decodeIfPresent(String.self, forKey: .userId) {
      self.userId = userIdString
    } else {
      let userIdInt = try? container.decodeIfPresent(Int.self, forKey: .userId)
      self.userId = userIdInt.map(String.init)
    }

    // Handle parentId as either String or Int
    if let parentIdString = try? container.decodeIfPresent(String.self, forKey: .parentId) {
      self.parentId = parentIdString
    } else {
      let parentIdInt = try? container.decodeIfPresent(Int.self, forKey: .parentId)
      self.parentId = parentIdInt.map(String.init)
    }

    // Handle editorId as either String or Int
    if let editorIdString = try? container.decodeIfPresent(String.self, forKey: .editorId) {
      self.editorId = editorIdString
    } else {
      let editorIdInt = try? container.decodeIfPresent(Int.self, forKey: .editorId)
      self.editorId = editorIdInt.map(String.init)
    }

    self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    self.message = try container.decodeIfPresent(String.self, forKey: .message)
    self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
    self.userDisplayName = try container.decodeIfPresent(String.self, forKey: .userDisplayName)
    self.replies = try container.decodeIfPresent([DiscussionEntry].self, forKey: .replies)
    self.attachment = try container.decodeIfPresent(CanvasAttachment.self, forKey: .attachment)
    self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
    self.readState = try container.decodeIfPresent(String.self, forKey: .readState)
    self.forcedReadState = try container.decodeIfPresent(Bool.self, forKey: .forcedReadState)
    self.ratingCount = try container.decodeIfPresent(Int.self, forKey: .ratingCount)
    self.ratingSum = try container.decodeIfPresent(Int.self, forKey: .ratingSum)
  }
}
/// Represents discussion permissions
struct DiscussionPermissions: Codable, Hashable {
  let attach: Bool?
  let update: Bool?
  let reply: Bool?
  let delete: Bool?

  enum CodingKeys: String, CodingKey {
    case attach
    case update
    case reply
    case delete
  }
}

/// Represents a group topic child
struct GroupTopicChild: Codable, Hashable {
  let id: String
  let groupId: String

  enum CodingKeys: String, CodingKey {
    case id
    case groupId = "group_id"
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

    // Handle groupId as either String or Int
    if let groupIdString = try? container.decode(String.self, forKey: .groupId) {
      self.groupId = groupIdString
    } else if let groupIdInt = try? container.decode(Int.self, forKey: .groupId) {
      self.groupId = String(groupIdInt)
    } else {
      throw DecodingError.typeMismatch(
        String.self,
        DecodingError.Context(
          codingPath: [CodingKeys.groupId],
          debugDescription: "Group ID must be either String or Int"
        )
      )
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id, forKey: .id)
    try container.encode(groupId, forKey: .groupId)
  }
}

