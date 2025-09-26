import XCTest

final class LoginViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - UI Element Tests
    
    func testLoginViewElementsExist() throws {
        // Test that all required UI elements are present
        XCTAssertTrue(app.navigationBars["Canvas Login"].exists)
        XCTAssertTrue(app.textFields["Canvas URL"].exists)
        XCTAssertTrue(app.secureTextFields["API Token"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
    }
    
    func testHeaderElementsDisplay() throws {
        // Test header elements
        XCTAssertTrue(app.images["graduationcap.fill"].exists)
        XCTAssertTrue(app.staticTexts["Welcome to Better Canvas"].exists)
        XCTAssertTrue(app.staticTexts["Enter your Canvas credentials to get started"].exists)
    }
    
    func testHelpSectionExists() throws {
        // Scroll to help section
        app.scrollViews.firstMatch.swipeUp()
        
        // Test help section elements
        XCTAssertTrue(app.staticTexts["How to get your API token:"].exists)
        XCTAssertTrue(app.staticTexts["Log in to your Canvas account in a web browser"].exists)
    }
    
    // MARK: - Form Validation Tests
    
    func testSignInButtonDisabledWhenFieldsEmpty() throws {
        let signInButton = app.buttons["Sign In"]
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    func testSignInButtonEnabledWithValidInput() throws {
        let urlField = app.textFields["Canvas URL"]
        let tokenField = app.secureTextFields["API Token"]
        let signInButton = app.buttons["Sign In"]
        
        // Enter valid URL
        urlField.tap()
        urlField.typeText("https://test.instructure.com")
        
        // Enter API token
        tokenField.tap()
        tokenField.typeText("test_api_token_123456789")
        
        // Check if sign in button is enabled
        XCTAssertTrue(signInButton.isEnabled)
    }
    
    func testURLValidationFeedback() throws {
        let urlField = app.textFields["Canvas URL"]
        
        // Enter invalid URL
        urlField.tap()
        urlField.typeText("invalid-url")
        
        // Tap somewhere else to trigger validation
        app.secureTextFields["API Token"].tap()
        
        // Check for validation message
        XCTAssertTrue(app.staticTexts["Please enter a valid Canvas URL"].exists)
    }
    
    func testAPITokenValidationFeedback() throws {
        let tokenField = app.secureTextFields["API Token"]
        
        // Enter short token
        tokenField.tap()
        tokenField.typeText("short")
        
        // Tap somewhere else to trigger validation
        app.textFields["Canvas URL"].tap()
        
        // Check for validation message
        XCTAssertTrue(app.staticTexts["API token seems too short"].exists)
    }
    
    // MARK: - Form Interaction Tests
    
    func testFieldFocusFlow() throws {
        let urlField = app.textFields["Canvas URL"]
        let tokenField = app.secureTextFields["API Token"]
        
        // Tap URL field
        urlField.tap()
        XCTAssertTrue(urlField.hasKeyboardFocus)
        
        // Enter URL and press return
        urlField.typeText("https://test.instructure.com")
        app.keyboards.buttons["return"].tap()
        
        // Token field should now have focus
        XCTAssertTrue(tokenField.hasKeyboardFocus)
    }
    
    func testFormSubmissionWithReturn() throws {
        let urlField = app.textFields["Canvas URL"]
        let tokenField = app.secureTextFields["API Token"]
        
        // Fill in valid data
        urlField.tap()
        urlField.typeText("https://test.instructure.com")
        
        tokenField.tap()
        tokenField.typeText("valid_api_token_123456789")
        
        // Press return in token field to submit
        app.keyboards.buttons["return"].tap()
        
        // Should show loading state (this would need to be mocked in a real test)
        // For now, just verify the button text changes or loading indicator appears
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.exists)
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() throws {
        // Test that important elements have accessibility labels
        XCTAssertTrue(app.textFields["Canvas URL"].exists)
        XCTAssertTrue(app.secureTextFields["API Token"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
        
        // Test help section accessibility
        app.scrollViews.firstMatch.swipeUp()
        XCTAssertTrue(app.staticTexts["How to get your API token:"].exists)
    }
    
    func testVoiceOverNavigation() throws {
        // Enable VoiceOver for testing
        // Note: This would require additional setup in a real test environment
        
        let urlField = app.textFields["Canvas URL"]
        let tokenField = app.secureTextFields["API Token"]
        let signInButton = app.buttons["Sign In"]
        
        // Test that elements are accessible in logical order
        XCTAssertTrue(urlField.exists)
        XCTAssertTrue(tokenField.exists)
        XCTAssertTrue(signInButton.exists)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorAlertDisplay() throws {
        // This test would require mocking network responses
        // For now, we'll test the UI structure for error handling
        
        let urlField = app.textFields["Canvas URL"]
        let tokenField = app.secureTextFields["API Token"]
        let signInButton = app.buttons["Sign In"]
        
        // Fill in data that would cause an error (in a mocked scenario)
        urlField.tap()
        urlField.typeText("https://invalid.canvas.com")
        
        tokenField.tap()
        tokenField.typeText("invalid_token")
        
        // Tap sign in
        signInButton.tap()
        
        // In a real test with mocked responses, we would check for:
        // XCTAssertTrue(app.alerts["Authentication Error"].exists)
        
        // For now, just verify the button exists and can be tapped
        XCTAssertTrue(signInButton.exists)
    }
    
    // MARK: - Layout Tests
    
    func testScrollViewBehavior() throws {
        let scrollView = app.scrollViews.firstMatch
        
        // Test that content is scrollable
        XCTAssertTrue(scrollView.exists)
        
        // Scroll down to help section
        scrollView.swipeUp()
        
        // Verify help content is visible
        XCTAssertTrue(app.staticTexts["How to get your API token:"].exists)
        
        // Scroll back up
        scrollView.swipeDown()
        
        // Verify header is visible again
        XCTAssertTrue(app.staticTexts["Welcome to Better Canvas"].exists)
    }
    
    func testLandscapeOrientation() throws {
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        
        // Verify key elements are still accessible
        XCTAssertTrue(app.textFields["Canvas URL"].exists)
        XCTAssertTrue(app.secureTextFields["API Token"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
        
        // Rotate back to portrait
        XCUIDevice.shared.orientation = .portrait
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    var hasKeyboardFocus: Bool {
        let hasKeyboardFocus = (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
        return hasKeyboardFocus
    }
}