import Foundation

// Test function to verify Discussion decoding works
func testDiscussionDecoding() {
    let sampleJSON = """
    {
        "id": 67434,
        "title": "YEAR-END INFO AND AP EXAM REVIEW DISCUSSION THREAD",
        "last_reply_at": "2025-05-12T03:42:42Z",
        "created_at": "2025-04-14T21:29:48Z",
        "delayed_post_at": null,
        "posted_at": "2025-04-14T21:51:25Z",
        "assignment_id": null,
        "root_topic_id": null,
        "position": null,
        "podcast_has_student_posts": false,
        "discussion_type": "threaded",
        "lock_at": null,
        "allow_rating": false,
        "only_graders_can_rate": false,
        "sort_by_rating": false,
        "is_section_specific": false,
        "anonymous_state": "partial_anonymity",
        "html_url": "https://example.com/discussion"
    }
    """
    
    let jsonData = sampleJSON.data(using: .utf8)!
    
    do {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        let discussion = try decoder.decode(Discussion.self, from: jsonData)
        print("Successfully decoded discussion: \(discussion.title)")
        print("ID: \(discussion.id)")
    } catch {
        print("Failed to decode discussion: \(error)")
    }
}