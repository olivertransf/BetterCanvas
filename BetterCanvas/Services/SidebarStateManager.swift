import Foundation
import SwiftUI
import Combine

/// Manages sidebar state persistence across the app
class SidebarStateManager: ObservableObject {
    static let shared = SidebarStateManager()
    
    @Published var isSidebarVisible: Bool = true
    @Published var selectedSidebarItem: String? = nil
    
    private let userDefaults = UserDefaults.standard
    private let sidebarVisibleKey = "sidebar_visible"
    private let selectedItemKey = "selected_sidebar_item"
    
    private init() {
        loadSidebarState()
    }
    
    /// Toggles sidebar visibility
    func toggleSidebar() {
        isSidebarVisible.toggle()
        saveSidebarState()
    }
    
    /// Sets sidebar visibility
    func setSidebarVisible(_ visible: Bool) {
        isSidebarVisible = visible
        saveSidebarState()
    }
    
    /// Sets the selected sidebar item
    func setSelectedItem(_ item: String?) {
        selectedSidebarItem = item
        saveSidebarState()
    }
    
    // MARK: - Private Methods
    
    private func loadSidebarState() {
        isSidebarVisible = userDefaults.bool(forKey: sidebarVisibleKey)
        selectedSidebarItem = userDefaults.string(forKey: selectedItemKey)
    }
    
    private func saveSidebarState() {
        userDefaults.set(isSidebarVisible, forKey: sidebarVisibleKey)
        if let selectedItem = selectedSidebarItem {
            userDefaults.set(selectedItem, forKey: selectedItemKey)
        } else {
            userDefaults.removeObject(forKey: selectedItemKey)
        }
    }
}
