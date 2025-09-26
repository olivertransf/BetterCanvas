import XCTest
@testable import BetterCanvas

final class AmbiguityTest: XCTestCase {
    
    func testNoAmbiguousReferences() {
        // Test that all services can be created without ambiguous references
        
        let coreDataManager = CoreDataManager.shared
        XCTAssertNotNil(coreDataManager)
        
        let keychainManager = KeychainManager.shared
        XCTAssertNotNil(keychainManager)
        
        let userDefaults = UserDefaults.standard
        XCTAssertNotNil(userDefaults)
        
        let dataSync = DataSyncManager()
        XCTAssertNotNil(dataSync)
    }
    
    @MainActor
    func testViewModelCreation() {
        let viewModel = CourseListViewModel()
        XCTAssertNotNil(viewModel)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testExplicitInitialization() {
        // Test explicit initialization to avoid ambiguity
        let coreData = CoreDataManager.shared
        let apiService = CanvasAPIService()
        let dataSync = DataSyncManager(
            apiService: apiService,
            coreDataManager: coreData,
            userDefaults: UserDefaults.standard
        )
        
        XCTAssertNotNil(dataSync)
    }
}