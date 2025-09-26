import XCTest
import SwiftUI
@testable import BetterCanvas

final class AppLaunchTests: XCTestCase {
    
    func testAppLaunch() {
        // Test that the main app components can be created
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }
    
    @MainActor
    func testLoginViewCreation() {
        // Test that LoginView can be created
        let authManager = AuthenticationManager()
        let loginView = LoginView()
            .environmentObject(authManager)
        XCTAssertNotNil(loginView)
    }
    
    @MainActor
    func testMainTabViewCreation() {
        // Test that MainTabView can be created
        let authManager = AuthenticationManager()
        let mainTabView = MainTabView()
            .environmentObject(authManager)
        XCTAssertNotNil(mainTabView)
    }
    
    func testCoreServicesInitialization() {
        // Test that core services can be initialized
        let keychainManager = KeychainManager()
        XCTAssertNotNil(keychainManager)
        
        let coreDataManager = CoreDataManager()
        XCTAssertNotNil(coreDataManager)
        
        let networkManager = NetworkManager()
        XCTAssertNotNil(networkManager)
        
        let apiService = CanvasAPIService()
        XCTAssertNotNil(apiService)
    }
}