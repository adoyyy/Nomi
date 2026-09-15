import XCTest
@testable import Nomi

class MockBiometricAuthenticationService: BiometricAuthenticationService {
    var canEvaluate = true
    var shouldSucceed = true
    var errorToReturn: Error? = nil
    
    var authenticateCallCount = 0
    
    // Support asynchronous tests
    var delay: TimeInterval = 0
    
    func canEvaluatePolicy() -> Bool {
        return canEvaluate
    }
    
    func authenticate(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        authenticateCallCount += 1
        
        if delay > 0 {
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                completion(self.shouldSucceed, self.errorToReturn)
            }
        } else {
            completion(shouldSucceed, errorToReturn)
        }
    }
}

class SecurityManagerTests: XCTestCase {
    
    var securityManager: SecurityManager!
    var mockAuthService: MockBiometricAuthenticationService!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockBiometricAuthenticationService()
        securityManager = SecurityManager(authService: mockAuthService)
        // Reset AppStorage to predictable state for tests
        securityManager.autoLockTimeoutRawValue = AutoLockTimeout.immediately.rawValue
    }
    
    func testInitialStateIsLocked() {
        XCTAssertEqual(securityManager.authState, .locked)
        XCTAssertFalse(securityManager.isAuthenticated)
    }
    
    func testAuthenticationTransitionsToAuthenticated() {
        let expectation = XCTestExpectation(description: "Authenticate completion")
        mockAuthService.shouldSucceed = true
        
        securityManager.authenticate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.securityManager.authState, .authenticated)
            XCTAssertTrue(self.securityManager.isAuthenticated)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAuthenticationFailureReturnsToFailed() {
        let expectation = XCTestExpectation(description: "Authenticate completion")
        mockAuthService.shouldSucceed = false
        
        securityManager.authenticate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.securityManager.authState, .failed)
            XCTAssertFalse(self.securityManager.isAuthenticated)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAuthenticationUnavailable() {
        let expectation = XCTestExpectation(description: "Authenticate completion")
        mockAuthService.canEvaluate = false
        
        securityManager.authenticate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.securityManager.authState, .unavailable)
            XCTAssertFalse(self.securityManager.isAuthenticated)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConcurrentAuthenticationRequestsArePrevented() {
        mockAuthService.delay = 0.5 // Delay completion to keep it in .authenticating state
        
        securityManager.authenticate()
        securityManager.authenticate()
        securityManager.authenticate()
        
        // Wait just a bit to ensure async dispatch starts
        let expectation = XCTestExpectation(description: "Authenticate calls")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.securityManager.authState, .authenticating)
            XCTAssertEqual(self.mockAuthService.authenticateCallCount, 1) // Should only be called once
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testBackgroundCanLock() {
        // Set up authenticated state
        securityManager.authState = .authenticated
        
        // Background app
        securityManager.handleAppBackgrounding()
        XCTAssertTrue(securityManager.isBlurAppScreen)
        
        // Wait to trigger lock timeout (immediately timeout is 0 seconds)
        Thread.sleep(forTimeInterval: 0.1)
        
        // Foreground app
        securityManager.handleAppForegrounding()
        
        XCTAssertEqual(securityManager.authState, .locked)
        XCTAssertFalse(securityManager.isAuthenticated)
    }
    
    func testForegroundDoesNotAuthenticateIfAlreadyFailed() {
        securityManager.authState = .failed
        
        securityManager.handleAppForegrounding()
        
        // Should remain failed, waiting for user interaction, instead of looping
        XCTAssertEqual(securityManager.authState, .failed)
    }
}
