import Foundation

/// Represents a Canvas assignment
struct Assignment: Codable, Identifiable, Hashable {
  let id: String
  let name: String
  let description: String?
  let createdAt: Date?
  let updatedAt: Date?
  let dueAt: Date?
  let lockAt: Date?
  let unlockAt: Date?
  let courseId: String
  let htmlUrl: String?
  let submissionsDownloadUrl: String?
  let assignmentGroupId: String?
  let dueDateRequired: Bool?
  let allowedExtensions: [String]?
  let maxNameLength: Int?
  let turnitinEnabled: Bool?
  let vericiteEnabled: Bool?
  let turnitinSettings: TurnitinSettings?
  let gradeGroupStudentsIndividually: Bool?
  let externalToolTagAttributes: ExternalToolTagAttributes?
  let peerReviews: Bool?
  let automaticPeerReviews: Bool?
  let peerReviewCount: Int?
  let peerReviewsAssignAt: Date?
  let intraGroupPeerReviews: Bool?
  let groupCategoryId: String?
  let needsGradingCount: Int?
  let needsGradingCountBySection: [GradingCountBySection]?
  let position: Int?
  let postToSis: Bool?
  let integrationId: String?
  let integrationData: [String: String]?
  let pointsPossible: Double?
  let submissionTypes: [String]?
  let hasSubmittedSubmissions: Bool?
  let gradingType: String?
  let gradingStandardId: String?
  let published: Bool?
  let unpublishable: Bool?
  let onlyVisibleToOverrides: Bool?
  let lockedForUser: Bool?
  let lockInfo: LockInfo?
  let lockExplanation: String?
  let quizId: String?
  let anonymousSubmissions: Bool?
  let discussionTopic: DiscussionTopic?
  let freezeOnCopy: Bool?
  let frozen: Bool?
  let frozenAttributes: [String]?
  // Note: submission property removed to avoid recursive type definition
  let useRubricForGrading: Bool?
  let rubricSettings: RubricSettings?
  let rubric: [RubricCriterion]?
  let assignmentVisibility: [String]?
  let overrides: [AssignmentOverride]?
  let omitFromFinalGrade: Bool?
  let hideInGradebook: Bool?
  let moderatedGrading: Bool?
  let graderCount: Int?
  let finalGraderId: String?
  let graderCommentsVisibleToGraders: Bool?
  let gradersAnonymousToGraders: Bool?
  let graderNamesVisibleToFinalGrader: Bool?
  let anonymousGrading: Bool?
  let allowedAttempts: Int?
  let postManually: Bool?
  let scoreStatistic: ScoreStatistic?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case description
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case dueAt = "due_at"
    case lockAt = "lock_at"
    case unlockAt = "unlock_at"
    case courseId = "course_id"
    case htmlUrl = "html_url"
    case submissionsDownloadUrl = "submissions_download_url"
    case assignmentGroupId = "assignment_group_id"
    case dueDateRequired = "due_date_required"
    case allowedExtensions = "allowed_extensions"
    case maxNameLength = "max_name_length"
    case turnitinEnabled = "turnitin_enabled"
    case vericiteEnabled = "vericite_enabled"
    case turnitinSettings = "turnitin_settings"
    case gradeGroupStudentsIndividually = "grade_group_students_individually"
    case externalToolTagAttributes = "external_tool_tag_attributes"
    case peerReviews = "peer_reviews"
    case automaticPeerReviews = "automatic_peer_reviews"
    case peerReviewCount = "peer_review_count"
    case peerReviewsAssignAt = "peer_reviews_assign_at"
    case intraGroupPeerReviews = "intra_group_peer_reviews"
    case groupCategoryId = "group_category_id"
    case needsGradingCount = "needs_grading_count"
    case needsGradingCountBySection = "needs_grading_count_by_section"
    case position
    case postToSis = "post_to_sis"
    case integrationId = "integration_id"
    case integrationData = "integration_data"
    case pointsPossible = "points_possible"
    case submissionTypes = "submission_types"
    case hasSubmittedSubmissions = "has_submitted_submissions"
    case gradingType = "grading_type"
    case gradingStandardId = "grading_standard_id"
    case published
    case unpublishable
    case onlyVisibleToOverrides = "only_visible_to_overrides"
    case lockedForUser = "locked_for_user"
    case lockInfo = "lock_info"
    case lockExplanation = "lock_explanation"
    case quizId = "quiz_id"
    case anonymousSubmissions = "anonymous_submissions"
    case discussionTopic = "discussion_topic"
    case freezeOnCopy = "freeze_on_copy"
    case frozen
    case frozenAttributes = "frozen_attributes"
    // case submission // Removed to avoid recursive type
    case useRubricForGrading = "use_rubric_for_grading"
    case rubricSettings = "rubric_settings"
    case rubric
    case assignmentVisibility = "assignment_visibility"
    case overrides
    case omitFromFinalGrade = "omit_from_final_grade"
    case hideInGradebook = "hide_in_gradebook"
    case moderatedGrading = "moderated_grading"
    case graderCount = "grader_count"
    case finalGraderId = "final_grader_id"
    case graderCommentsVisibleToGraders = "grader_comments_visible_to_graders"
    case gradersAnonymousToGraders = "graders_anonymous_to_graders"
    case graderNamesVisibleToFinalGrader = "grader_names_visible_to_final_grader"
    case anonymousGrading = "anonymous_grading"
    case allowedAttempts = "allowed_attempts"
    case postManually = "post_manually"
    case scoreStatistic = "score_statistic"
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
          codingPath: [CodingKeys.id], debugDescription: "ID must be either String or Int"))
    }

    // Handle courseId as either String or Int
    if let courseIdString = try? container.decode(String.self, forKey: .courseId) {
      self.courseId = courseIdString
    } else if let courseIdInt = try? container.decode(Int.self, forKey: .courseId) {
      self.courseId = String(courseIdInt)
    } else {
      self.courseId = "0"
    }

    self.name = try container.decode(String.self, forKey: .name)
    self.description = try container.decodeIfPresent(String.self, forKey: .description)
    self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    self.dueAt = try container.decodeIfPresent(Date.self, forKey: .dueAt)
    self.lockAt = try container.decodeIfPresent(Date.self, forKey: .lockAt)
    self.unlockAt = try container.decodeIfPresent(Date.self, forKey: .unlockAt)
    self.htmlUrl = try container.decodeIfPresent(String.self, forKey: .htmlUrl)
    self.submissionsDownloadUrl = try container.decodeIfPresent(
      String.self, forKey: .submissionsDownloadUrl)

    // Handle assignmentGroupId as either String or Int
    if let assignmentGroupIdString = try? container.decode(String.self, forKey: .assignmentGroupId)
    {
      self.assignmentGroupId = assignmentGroupIdString
    } else if let assignmentGroupIdInt = try? container.decode(Int.self, forKey: .assignmentGroupId)
    {
      self.assignmentGroupId = String(assignmentGroupIdInt)
    } else {
      self.assignmentGroupId = nil
    }

    self.dueDateRequired = try container.decodeIfPresent(Bool.self, forKey: .dueDateRequired)
    self.allowedExtensions = try container.decodeIfPresent(
      [String].self, forKey: .allowedExtensions)
    self.maxNameLength = try container.decodeIfPresent(Int.self, forKey: .maxNameLength)
    self.turnitinEnabled = try container.decodeIfPresent(Bool.self, forKey: .turnitinEnabled)
    self.vericiteEnabled = try container.decodeIfPresent(Bool.self, forKey: .vericiteEnabled)
    self.turnitinSettings = try container.decodeIfPresent(
      TurnitinSettings.self, forKey: .turnitinSettings)
    self.gradeGroupStudentsIndividually = try container.decodeIfPresent(
      Bool.self, forKey: .gradeGroupStudentsIndividually)
    self.externalToolTagAttributes = try container.decodeIfPresent(
      ExternalToolTagAttributes.self, forKey: .externalToolTagAttributes)
    self.peerReviews = try container.decodeIfPresent(Bool.self, forKey: .peerReviews)
    self.automaticPeerReviews = try container.decodeIfPresent(
      Bool.self, forKey: .automaticPeerReviews)
    self.peerReviewCount = try container.decodeIfPresent(Int.self, forKey: .peerReviewCount)
    self.peerReviewsAssignAt = try container.decodeIfPresent(
      Date.self, forKey: .peerReviewsAssignAt)
    self.intraGroupPeerReviews = try container.decodeIfPresent(
      Bool.self, forKey: .intraGroupPeerReviews)

    // Handle groupCategoryId as either String or Int
    if let groupCategoryIdString = try? container.decode(String.self, forKey: .groupCategoryId) {
      self.groupCategoryId = groupCategoryIdString
    } else if let groupCategoryIdInt = try? container.decode(Int.self, forKey: .groupCategoryId) {
      self.groupCategoryId = String(groupCategoryIdInt)
    } else {
      self.groupCategoryId = nil
    }

    self.needsGradingCount = try container.decodeIfPresent(Int.self, forKey: .needsGradingCount)
    self.needsGradingCountBySection = try container.decodeIfPresent(
      [GradingCountBySection].self, forKey: .needsGradingCountBySection)
    self.position = try container.decodeIfPresent(Int.self, forKey: .position)
    self.postToSis = try container.decodeIfPresent(Bool.self, forKey: .postToSis)
    self.integrationId = try container.decodeIfPresent(String.self, forKey: .integrationId)
    self.integrationData = try container.decodeIfPresent(
      [String: String].self, forKey: .integrationData)
    self.pointsPossible = try container.decodeIfPresent(Double.self, forKey: .pointsPossible)
    self.submissionTypes = try container.decodeIfPresent([String].self, forKey: .submissionTypes)
    self.hasSubmittedSubmissions = try container.decodeIfPresent(
      Bool.self, forKey: .hasSubmittedSubmissions)
    self.gradingType = try container.decodeIfPresent(String.self, forKey: .gradingType)
    self.gradingStandardId = try container.decodeIfPresent(String.self, forKey: .gradingStandardId)
    self.published = try container.decodeIfPresent(Bool.self, forKey: .published)
    self.unpublishable = try container.decodeIfPresent(Bool.self, forKey: .unpublishable)
    self.onlyVisibleToOverrides = try container.decodeIfPresent(
      Bool.self, forKey: .onlyVisibleToOverrides)
    self.lockedForUser = try container.decodeIfPresent(Bool.self, forKey: .lockedForUser)
    self.lockInfo = try container.decodeIfPresent(LockInfo.self, forKey: .lockInfo)
    self.lockExplanation = try container.decodeIfPresent(String.self, forKey: .lockExplanation)

    // Handle quizId as either String or Int
    if let quizIdString = try? container.decode(String.self, forKey: .quizId) {
      self.quizId = quizIdString
    } else if let quizIdInt = try? container.decode(Int.self, forKey: .quizId) {
      self.quizId = String(quizIdInt)
    } else {
      self.quizId = nil
    }
    self.anonymousSubmissions = try container.decodeIfPresent(
      Bool.self, forKey: .anonymousSubmissions)
    self.discussionTopic = try container.decodeIfPresent(
      DiscussionTopic.self, forKey: .discussionTopic)
    self.freezeOnCopy = try container.decodeIfPresent(Bool.self, forKey: .freezeOnCopy)
    self.frozen = try container.decodeIfPresent(Bool.self, forKey: .frozen)
    self.frozenAttributes = try container.decodeIfPresent([String].self, forKey: .frozenAttributes)
    self.useRubricForGrading = try container.decodeIfPresent(
      Bool.self, forKey: .useRubricForGrading)
    self.rubricSettings = try container.decodeIfPresent(
      RubricSettings.self, forKey: .rubricSettings)
    self.rubric = try container.decodeIfPresent([RubricCriterion].self, forKey: .rubric)
    self.assignmentVisibility = try container.decodeIfPresent(
      [String].self, forKey: .assignmentVisibility)
    self.overrides = try container.decodeIfPresent([AssignmentOverride].self, forKey: .overrides)
    self.omitFromFinalGrade = try container.decodeIfPresent(Bool.self, forKey: .omitFromFinalGrade)
    self.hideInGradebook = try container.decodeIfPresent(Bool.self, forKey: .hideInGradebook)
    self.moderatedGrading = try container.decodeIfPresent(Bool.self, forKey: .moderatedGrading)
    self.graderCount = try container.decodeIfPresent(Int.self, forKey: .graderCount)
    self.finalGraderId = try container.decodeIfPresent(String.self, forKey: .finalGraderId)
    self.graderCommentsVisibleToGraders = try container.decodeIfPresent(
      Bool.self, forKey: .graderCommentsVisibleToGraders)
    self.gradersAnonymousToGraders = try container.decodeIfPresent(
      Bool.self, forKey: .gradersAnonymousToGraders)
    self.graderNamesVisibleToFinalGrader = try container.decodeIfPresent(
      Bool.self, forKey: .graderNamesVisibleToFinalGrader)
    self.anonymousGrading = try container.decodeIfPresent(Bool.self, forKey: .anonymousGrading)
    self.allowedAttempts = try container.decodeIfPresent(Int.self, forKey: .allowedAttempts)
    self.postManually = try container.decodeIfPresent(Bool.self, forKey: .postManually)
    self.scoreStatistic = try container.decodeIfPresent(
      ScoreStatistic.self, forKey: .scoreStatistic)
  }

  // MARK: - Computed Properties

  var isOverdue: Bool {
    guard let dueAt = dueAt else { return false }
    return Date() > dueAt
  }

  var isDueSoon: Bool {
    guard let dueAt = dueAt else { return false }
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    return dueAt <= tomorrow && dueAt > Date()
  }

  var submissionStatus: SubmissionStatus {
    // Default to not submitted since we removed the recursive submission property
    if isOverdue {
      return .overdue
    } else {
      return .notSubmitted
    }
  }

  var formattedDueDate: String? {
    guard let dueAt = dueAt else { return nil }

    let formatter = DateFormatter()
    if Calendar.current.isDateInToday(dueAt) {
      formatter.dateFormat = "'Today at' h:mm a"
    } else if Calendar.current.isDateInTomorrow(dueAt) {
      formatter.dateFormat = "'Tomorrow at' h:mm a"
    } else {
      formatter.dateFormat = "MMM d 'at' h:mm a"
    }

    return formatter.string(from: dueAt)
  }

  var acceptsFileUploads: Bool {
    submissionTypes?.contains("online_upload") ?? false
  }

  var acceptsTextEntry: Bool {
    submissionTypes?.contains("online_text_entry") ?? false
  }

  var acceptsUrlSubmission: Bool {
    submissionTypes?.contains("online_url") ?? false
  }
}

// MARK: - Supporting Types

enum SubmissionStatus {
  case notSubmitted
  case submitted
  case late
  case overdue

  var displayText: String {
    switch self {
    case .notSubmitted:
      return "Not Submitted"
    case .submitted:
      return "Submitted"
    case .late:
      return "Late"
    case .overdue:
      return "Overdue"
    }
  }

  var color: String {
    switch self {
    case .notSubmitted:
      return "gray"
    case .submitted:
      return "green"
    case .late:
      return "orange"
    case .overdue:
      return "red"
    }
  }
}

struct TurnitinSettings: Codable, Hashable {
  let originalityReportVisibility: String?
  let sPaperCheck: Bool?
  let internetCheck: Bool?
  let journalCheck: Bool?
  let excludeBiblio: Bool?
  let excludeQuoted: Bool?
  let excludeSmallMatchesType: String?
  let excludeSmallMatchesValue: Int?

  enum CodingKeys: String, CodingKey {
    case originalityReportVisibility = "originality_report_visibility"
    case sPaperCheck = "s_paper_check"
    case internetCheck = "internet_check"
    case journalCheck = "journal_check"
    case excludeBiblio = "exclude_biblio"
    case excludeQuoted = "exclude_quoted"
    case excludeSmallMatchesType = "exclude_small_matches_type"
    case excludeSmallMatchesValue = "exclude_small_matches_value"
  }
}

struct ExternalToolTagAttributes: Codable, Hashable {
  let url: String?
  let newTab: Bool?
  let resourceLinkId: String?

  enum CodingKeys: String, CodingKey {
    case url
    case newTab = "new_tab"
    case resourceLinkId = "resource_link_id"
  }
}

struct GradingCountBySection: Codable, Hashable {
  let sectionId: String
  let needsGradingCount: Int

  enum CodingKeys: String, CodingKey {
    case sectionId = "section_id"
    case needsGradingCount = "needs_grading_count"
  }
}

struct LockInfo: Codable, Hashable {
  let assetString: String?
  let unlockAt: Date?
  let lockAt: Date?
  let contextModule: String?
  let manuallyLocked: Bool?

  enum CodingKeys: String, CodingKey {
    case assetString = "asset_string"
    case unlockAt = "unlock_at"
    case lockAt = "lock_at"
    case contextModule = "context_module"
    case manuallyLocked = "manually_locked"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.assetString = try container.decodeIfPresent(String.self, forKey: .assetString)
    self.unlockAt = try container.decodeIfPresent(Date.self, forKey: .unlockAt)
    self.lockAt = try container.decodeIfPresent(Date.self, forKey: .lockAt)
    self.manuallyLocked = try container.decodeIfPresent(Bool.self, forKey: .manuallyLocked)
    
    // Handle contextModule as either String or Dictionary
    if let contextModuleString = try? container.decodeIfPresent(String.self, forKey: .contextModule) {
      self.contextModule = contextModuleString
    } else {
      // If it's a dictionary, we'll just ignore it for now
      // or extract a meaningful string representation if needed
      self.contextModule = nil
    }
  }
}

struct DiscussionTopic: Codable, Hashable {
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
          debugDescription: "Discussion topic ID must be either String or Int"
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
    self.discussionSubentryCount = try container.decodeIfPresent(Int.self, forKey: .discussionSubentryCount)
    self.readState = try container.decodeIfPresent(String.self, forKey: .readState)
    self.unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount)
  }
}

struct RubricSettings: Codable, Hashable {
  let id: String?
  let title: String?
  let pointsPossible: Double?
  let freeFormCriterionComments: Bool?
  let hideScoreTotal: Bool?
  let hidePoints: Bool?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case pointsPossible = "points_possible"
    case freeFormCriterionComments = "free_form_criterion_comments"
    case hideScoreTotal = "hide_score_total"
    case hidePoints = "hide_points"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    // Handle ID as either String or Int
    if let idString = try? container.decodeIfPresent(String.self, forKey: .id) {
      self.id = idString
    } else if let idInt = try? container.decodeIfPresent(Int.self, forKey: .id) {
      self.id = String(idInt)
    } else {
      self.id = nil
    }
    
    self.title = try container.decodeIfPresent(String.self, forKey: .title)
    self.pointsPossible = try container.decodeIfPresent(Double.self, forKey: .pointsPossible)
    self.freeFormCriterionComments = try container.decodeIfPresent(Bool.self, forKey: .freeFormCriterionComments)
    self.hideScoreTotal = try container.decodeIfPresent(Bool.self, forKey: .hideScoreTotal)
    self.hidePoints = try container.decodeIfPresent(Bool.self, forKey: .hidePoints)
  }
}

struct RubricCriterion: Codable, Hashable {
  let id: String
  let description: String?
  let longDescription: String?
  let points: Double
  let criterionUseRange: Bool?
  let ratings: [RubricRating]?

  enum CodingKeys: String, CodingKey {
    case id
    case description
    case longDescription = "long_description"
    case points
    case criterionUseRange = "criterion_use_range"
    case ratings
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
          debugDescription: "Rubric criterion ID must be either String or Int"
        )
      )
    }
    
    self.description = try container.decodeIfPresent(String.self, forKey: .description)
    self.longDescription = try container.decodeIfPresent(String.self, forKey: .longDescription)
    self.points = try container.decode(Double.self, forKey: .points)
    self.criterionUseRange = try container.decodeIfPresent(Bool.self, forKey: .criterionUseRange)
    self.ratings = try container.decodeIfPresent([RubricRating].self, forKey: .ratings)
  }
}

struct RubricRating: Codable, Hashable {
  let id: String
  let description: String?
  let longDescription: String?
  let points: Double

  enum CodingKeys: String, CodingKey {
    case id
    case description
    case longDescription = "long_description"
    case points
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
          debugDescription: "Rubric rating ID must be either String or Int"
        )
      )
    }
    
    self.description = try container.decodeIfPresent(String.self, forKey: .description)
    self.longDescription = try container.decodeIfPresent(String.self, forKey: .longDescription)
    self.points = try container.decode(Double.self, forKey: .points)
  }
}

struct AssignmentOverride: Codable, Hashable {
  let id: String
  let assignmentId: String
  let studentIds: [String]?
  let groupId: String?
  let courseSectionId: String?
  let title: String
  let dueAt: Date?
  let unlockAt: Date?
  let lockAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case assignmentId = "assignment_id"
    case studentIds = "student_ids"
    case groupId = "group_id"
    case courseSectionId = "course_section_id"
    case title
    case dueAt = "due_at"
    case unlockAt = "unlock_at"
    case lockAt = "lock_at"
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
          debugDescription: "Assignment override ID must be either String or Int"
        )
      )
    }
    
    // Handle assignmentId as either String or Int
    if let assignmentIdString = try? container.decode(String.self, forKey: .assignmentId) {
      self.assignmentId = assignmentIdString
    } else if let assignmentIdInt = try? container.decode(Int.self, forKey: .assignmentId) {
      self.assignmentId = String(assignmentIdInt)
    } else {
      throw DecodingError.typeMismatch(
        String.self,
        DecodingError.Context(
          codingPath: [CodingKeys.assignmentId],
          debugDescription: "Assignment override assignment ID must be either String or Int"
        )
      )
    }
    
    // Handle studentIds as either [String] or [Int]
    if let studentIdStrings = try? container.decodeIfPresent([String].self, forKey: .studentIds) {
      self.studentIds = studentIdStrings
    } else if let studentIdInts = try? container.decodeIfPresent([Int].self, forKey: .studentIds) {
      self.studentIds = studentIdInts.map { String($0) }
    } else {
      self.studentIds = nil
    }
    
    // Handle groupId as either String or Int
    if let groupIdString = try? container.decodeIfPresent(String.self, forKey: .groupId) {
      self.groupId = groupIdString
    } else if let groupIdInt = try? container.decodeIfPresent(Int.self, forKey: .groupId) {
      self.groupId = String(groupIdInt)
    } else {
      self.groupId = nil
    }
    
    // Handle courseSectionId as either String or Int
    if let courseSectionIdString = try? container.decodeIfPresent(String.self, forKey: .courseSectionId) {
      self.courseSectionId = courseSectionIdString
    } else if let courseSectionIdInt = try? container.decodeIfPresent(Int.self, forKey: .courseSectionId) {
      self.courseSectionId = String(courseSectionIdInt)
    } else {
      self.courseSectionId = nil
    }
    
    self.title = try container.decode(String.self, forKey: .title)
    self.dueAt = try container.decodeIfPresent(Date.self, forKey: .dueAt)
    self.unlockAt = try container.decodeIfPresent(Date.self, forKey: .unlockAt)
    self.lockAt = try container.decodeIfPresent(Date.self, forKey: .lockAt)
  }
}

struct ScoreStatistic: Codable, Hashable {
  let min: Double?
  let max: Double?
  let mean: Double?

  enum CodingKeys: String, CodingKey {
    case min
    case max
    case mean
  }
}

/// Represents a submission comment
struct CanvasSubmissionComment: Codable, Hashable {
  let id: String
  let authorId: String?
  let authorName: String?
  let comment: String?
  let createdAt: Date?
  let editedAt: Date?
  let mediaComment: CanvasMediaComment?
  let attachments: [CanvasAttachment]?

  enum CodingKeys: String, CodingKey {
    case id
    case authorId = "author_id"
    case authorName = "author_name"
    case comment
    case createdAt = "created_at"
    case editedAt = "edited_at"
    case mediaComment = "media_comment"
    case attachments
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

    // Handle authorId as either String or Int
    do {
      self.authorId = try container.decodeIfPresent(String.self, forKey: .authorId)
    } catch {
      do {
        if let authorIdInt = try container.decodeIfPresent(Int.self, forKey: .authorId) {
          self.authorId = String(authorIdInt)
        } else {
          self.authorId = nil
        }
      } catch {
        self.authorId = nil
      }
    }

    self.authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
    self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
    self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    self.editedAt = try container.decodeIfPresent(Date.self, forKey: .editedAt)
    self.mediaComment = try container.decodeIfPresent(
      CanvasMediaComment.self, forKey: .mediaComment)
    self.attachments = try container.decodeIfPresent([CanvasAttachment].self, forKey: .attachments)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(authorId, forKey: .authorId)
    try container.encodeIfPresent(authorName, forKey: .authorName)
    try container.encodeIfPresent(comment, forKey: .comment)
    try container.encodeIfPresent(createdAt, forKey: .createdAt)
    try container.encodeIfPresent(editedAt, forKey: .editedAt)
    try container.encodeIfPresent(mediaComment, forKey: .mediaComment)
    try container.encodeIfPresent(attachments, forKey: .attachments)
  }
}

/// Represents a media comment
struct CanvasMediaComment: Codable, Hashable {
  let contentType: String?
  let displayName: String?
  let mediaId: String?
  let mediaType: String?
  let url: String?

  enum CodingKeys: String, CodingKey {
    case contentType = "content-type"
    case displayName = "display_name"
    case mediaId = "media_id"
    case mediaType = "media_type"
    case url
  }
}

/// Represents a rubric assessment
struct CanvasRubricAssessment: Codable, Hashable {
  let points: Double?
  let rating: RubricRating?
  let comments: String?

  enum CodingKeys: String, CodingKey {
    case points
    case rating
    case comments
  }
}

/// Represents a submission response from Canvas API
struct AssignmentSubmissionResponse: Codable, Identifiable, Hashable {
  let id: String
  let assignmentId: String
  let courseId: String?
  let userId: String
  let submissionType: String?
  let submittedAt: Date?
  let score: Double?
  let grade: String?
  let attempt: Int?
  let body: String?
  let url: String?
  let previewUrl: String?
  let attachments: [CanvasAttachment]?
  let gradedAt: Date?
  let graderComments: [CanvasSubmissionComment]?
  let rubricAssessment: [String: CanvasRubricAssessment]?
  let submissionComments: [CanvasSubmissionComment]?
  let late: Bool?
  let missing: Bool?
  let excused: Bool?
  let workflowState: String
  let gradingPeriodId: String?
  let gradeMatchesCurrentSubmission: Bool?
  let htmlUrl: String?
  let secondsLate: Int?
  let enteredGrade: String?
  let enteredScore: Double?
  let cachedDueDate: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case assignmentId = "assignment_id"
    case courseId = "course_id"
    case userId = "user_id"
    case submissionType = "submission_type"
    case submittedAt = "submitted_at"
    case score
    case grade
    case attempt
    case body
    case url
    case previewUrl = "preview_url"
    case attachments
    case gradedAt = "graded_at"
    case graderComments = "grader_comments"
    case rubricAssessment = "rubric_assessment"
    case submissionComments = "submission_comments"
    case late
    case missing
    case excused
    case workflowState = "workflow_state"
    case gradingPeriodId = "grading_period_id"
    case gradeMatchesCurrentSubmission = "grade_matches_current_submission"
    case htmlUrl = "html_url"
    case secondsLate = "seconds_late"
    case enteredGrade = "entered_grade"
    case enteredScore = "entered_score"
    case cachedDueDate = "cached_due_date"
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

    // Handle assignmentId as either String or Int
    if let assignmentIdString = try? container.decode(String.self, forKey: .assignmentId) {
      self.assignmentId = assignmentIdString
    } else if let assignmentIdInt = try? container.decode(Int.self, forKey: .assignmentId) {
      self.assignmentId = String(assignmentIdInt)
    } else {
      throw DecodingError.typeMismatch(
        String.self,
        DecodingError.Context(
          codingPath: [CodingKeys.assignmentId],
          debugDescription: "Assignment ID must be either String or Int"
        )
      )
    }

    // Handle courseId as either String or Int
    do {
      self.courseId = try container.decodeIfPresent(String.self, forKey: .courseId)
    } catch {
      do {
        if let courseIdInt = try container.decodeIfPresent(Int.self, forKey: .courseId) {
          self.courseId = String(courseIdInt)
        } else {
          self.courseId = nil
        }
      } catch {
        self.courseId = nil
      }
    }

    // Handle userId as either String or Int
    if let userIdString = try? container.decode(String.self, forKey: .userId) {
      self.userId = userIdString
    } else if let userIdInt = try? container.decode(Int.self, forKey: .userId) {
      self.userId = String(userIdInt)
    } else {
      throw DecodingError.typeMismatch(
        String.self,
        DecodingError.Context(
          codingPath: [CodingKeys.userId],
          debugDescription: "User ID must be either String or Int"
        )
      )
    }

    self.submissionType = try container.decodeIfPresent(String.self, forKey: .submissionType)
    self.submittedAt = try container.decodeIfPresent(Date.self, forKey: .submittedAt)
    self.score = try container.decodeIfPresent(Double.self, forKey: .score)
    self.grade = try container.decodeIfPresent(String.self, forKey: .grade)
    self.attempt = try container.decodeIfPresent(Int.self, forKey: .attempt)
    self.body = try container.decodeIfPresent(String.self, forKey: .body)
    self.url = try container.decodeIfPresent(String.self, forKey: .url)
    self.previewUrl = try container.decodeIfPresent(String.self, forKey: .previewUrl)
    self.attachments = try container.decodeIfPresent([CanvasAttachment].self, forKey: .attachments)
    self.gradedAt = try container.decodeIfPresent(Date.self, forKey: .gradedAt)
    self.graderComments = try container.decodeIfPresent(
      [CanvasSubmissionComment].self, forKey: .graderComments)
    self.rubricAssessment = try container.decodeIfPresent(
      [String: CanvasRubricAssessment].self, forKey: .rubricAssessment)
    self.submissionComments = try container.decodeIfPresent(
      [CanvasSubmissionComment].self, forKey: .submissionComments)
    self.late = try container.decodeIfPresent(Bool.self, forKey: .late)
    self.missing = try container.decodeIfPresent(Bool.self, forKey: .missing)
    self.excused = try container.decodeIfPresent(Bool.self, forKey: .excused)
    self.workflowState = try container.decode(String.self, forKey: .workflowState)

    // Handle gradingPeriodId as either String or Int
    do {
      self.gradingPeriodId = try container.decodeIfPresent(String.self, forKey: .gradingPeriodId)
    } catch {
      do {
        if let gradingPeriodIdInt = try container.decodeIfPresent(
          Int.self, forKey: .gradingPeriodId)
        {
          self.gradingPeriodId = String(gradingPeriodIdInt)
        } else {
          self.gradingPeriodId = nil
        }
      } catch {
        self.gradingPeriodId = nil
      }
    }

    self.gradeMatchesCurrentSubmission = try container.decodeIfPresent(
      Bool.self, forKey: .gradeMatchesCurrentSubmission)
    self.htmlUrl = try container.decodeIfPresent(String.self, forKey: .htmlUrl)
    self.secondsLate = try container.decodeIfPresent(Int.self, forKey: .secondsLate)
    self.enteredGrade = try container.decodeIfPresent(String.self, forKey: .enteredGrade)
    self.enteredScore = try container.decodeIfPresent(Double.self, forKey: .enteredScore)
    self.cachedDueDate = try container.decodeIfPresent(Date.self, forKey: .cachedDueDate)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id, forKey: .id)
    try container.encode(assignmentId, forKey: .assignmentId)
    try container.encodeIfPresent(courseId, forKey: .courseId)
    try container.encode(userId, forKey: .userId)
    try container.encodeIfPresent(submissionType, forKey: .submissionType)
    try container.encodeIfPresent(submittedAt, forKey: .submittedAt)
    try container.encodeIfPresent(score, forKey: .score)
    try container.encodeIfPresent(grade, forKey: .grade)
    try container.encodeIfPresent(attempt, forKey: .attempt)
    try container.encodeIfPresent(body, forKey: .body)
    try container.encodeIfPresent(url, forKey: .url)
    try container.encodeIfPresent(previewUrl, forKey: .previewUrl)
    try container.encodeIfPresent(attachments, forKey: .attachments)
    try container.encodeIfPresent(gradedAt, forKey: .gradedAt)
    try container.encodeIfPresent(graderComments, forKey: .graderComments)
    try container.encodeIfPresent(rubricAssessment, forKey: .rubricAssessment)
    try container.encodeIfPresent(submissionComments, forKey: .submissionComments)
    try container.encodeIfPresent(late, forKey: .late)
    try container.encodeIfPresent(missing, forKey: .missing)
    try container.encodeIfPresent(excused, forKey: .excused)
    try container.encode(workflowState, forKey: .workflowState)
    try container.encodeIfPresent(gradingPeriodId, forKey: .gradingPeriodId)
    try container.encodeIfPresent(
      gradeMatchesCurrentSubmission, forKey: .gradeMatchesCurrentSubmission)
    try container.encodeIfPresent(htmlUrl, forKey: .htmlUrl)
    try container.encodeIfPresent(secondsLate, forKey: .secondsLate)
    try container.encodeIfPresent(enteredGrade, forKey: .enteredGrade)
    try container.encodeIfPresent(enteredScore, forKey: .enteredScore)
    try container.encodeIfPresent(cachedDueDate, forKey: .cachedDueDate)
  }
}
// MARK: - Assignment Extensions for Testing
extension Assignment {
  init(
    id: String,
    name: String,
    description: String? = nil,
    courseId: String,
    dueAt: Date? = nil,
    pointsPossible: Double? = nil,
    submissionTypes: [String]? = nil
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.createdAt = Date()
    self.updatedAt = Date()
    self.dueAt = dueAt
    self.lockAt = nil
    self.unlockAt = nil
    self.courseId = courseId
    self.htmlUrl = "https://example.com/assignments/\(id)"
    self.submissionsDownloadUrl = nil
    self.assignmentGroupId = "1"
    self.dueDateRequired = false
    self.allowedExtensions = nil
    self.maxNameLength = nil
    self.turnitinEnabled = nil
    self.vericiteEnabled = nil
    self.turnitinSettings = nil
    self.gradeGroupStudentsIndividually = false
    self.externalToolTagAttributes = nil
    self.peerReviews = false
    self.automaticPeerReviews = nil
    self.peerReviewCount = nil
    self.peerReviewsAssignAt = nil
    self.intraGroupPeerReviews = nil
    self.groupCategoryId = nil
    self.needsGradingCount = nil
    self.needsGradingCountBySection = nil
    self.position = nil
    self.postToSis = nil
    self.integrationId = nil
    self.integrationData = nil
    self.pointsPossible = pointsPossible
    self.submissionTypes = submissionTypes ?? ["online_text_entry"]
    self.hasSubmittedSubmissions = nil
    self.gradingType = "points"
    self.gradingStandardId = nil
    self.published = true
    self.unpublishable = nil
    self.onlyVisibleToOverrides = false
    self.lockedForUser = nil
    self.lockInfo = nil
    self.lockExplanation = nil
    self.quizId = nil
    self.anonymousSubmissions = nil
    self.discussionTopic = nil
    self.freezeOnCopy = nil
    self.frozen = nil
    self.frozenAttributes = nil
    // self.submission = nil // Removed to avoid recursive type
    self.useRubricForGrading = nil
    self.rubricSettings = nil
    self.rubric = nil
    self.assignmentVisibility = nil
    self.overrides = nil
    self.omitFromFinalGrade = nil
    self.hideInGradebook = nil
    self.moderatedGrading = nil
    self.graderCount = nil
    self.finalGraderId = nil
    self.graderCommentsVisibleToGraders = nil
    self.gradersAnonymousToGraders = nil
    self.graderNamesVisibleToFinalGrader = nil
    self.anonymousGrading = nil
    self.allowedAttempts = nil
    self.postManually = nil
    self.scoreStatistic = nil
  }
}
