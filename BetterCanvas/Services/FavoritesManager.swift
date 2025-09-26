import Foundation
import Combine

/// Manages local storage of favorite courses
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteCourseIds: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorite_course_ids"
    
    private init() {
        loadFavorites()
    }
    
    /// Check if a course is favorited
    func isFavorite(courseId: String) -> Bool {
        return favoriteCourseIds.contains(courseId)
    }
    
    /// Toggle favorite status for a course
    func toggleFavorite(courseId: String) {
        if favoriteCourseIds.contains(courseId) {
            favoriteCourseIds.remove(courseId)
        } else {
            favoriteCourseIds.insert(courseId)
        }
        saveFavorites()
    }
    
    /// Add a course to favorites
    func addFavorite(courseId: String) {
        favoriteCourseIds.insert(courseId)
        saveFavorites()
    }
    
    /// Remove a course from favorites
    func removeFavorite(courseId: String) {
        favoriteCourseIds.remove(courseId)
        saveFavorites()
    }
    
    /// Get all favorite course IDs
    func getFavoriteCourseIds() -> Set<String> {
        return favoriteCourseIds
    }
    
    /// Get the count of favorite courses
    func getFavoriteCount() -> Int {
        return favoriteCourseIds.count
    }
    
    /// Clear all favorites
    func clearFavorites() {
        favoriteCourseIds.removeAll()
        saveFavorites()
    }
    
    // MARK: - Private Methods
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteCourseIds = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteCourseIds) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}
