import Foundation
import SwiftUI

enum AutoLockTimeout: Int, CaseIterable {
    case immediately = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900
    
    var description: String {
        switch self {
        case .immediately: return "Immediately"
        case .oneMinute: return "After 1 minute"
        case .fiveMinutes: return "After 5 minutes"
        case .fifteenMinutes: return "After 15 minutes"
        }
    }
}

enum AuthenticationState {
    case locked
    case authenticating
    case authenticated
    case failed
    case unavailable
}

class SecurityManager: ObservableObject {
    @Published var authState: AuthenticationState = .locked
    @Published var isPrivacyMode = false
    @Published var isBlurAppScreen = false
    
    @AppStorage("autoLockTimeout") var autoLockTimeoutRawValue: Int = AutoLockTimeout.immediately.rawValue
    
    var autoLockTimeout: AutoLockTimeout {
        AutoLockTimeout(rawValue: autoLockTimeoutRawValue) ?? .immediately
    }
    
    private var lastInactiveTime: Date?
    private let authService: BiometricAuthenticationService
    
    init(authService: BiometricAuthenticationService = DefaultBiometricAuthenticationService()) {
        self.authService = authService
    }
    
    var isAuthenticated: Bool {
        return authState == .authenticated
    }
    
    func authenticate() {
        guard authState != .authenticating else { return }
        
        if authService.canEvaluatePolicy() {
            DispatchQueue.main.async {
                self.authState = .authenticating
            }
            
            let reason = "Unlock Nomi to view your financial data."
            
            authService.authenticate(reason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.authState = .authenticated
                        self.isBlurAppScreen = false
                    } else {
                        print(error?.localizedDescription ?? "Authentication failed")
                        self.authState = .failed
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.authState = .unavailable
            }
        }
    }
    
    func handleAppBackgrounding() {
        self.isBlurAppScreen = true
        self.lastInactiveTime = Date()
    }
    
    func handleAppForegrounding() {
        guard authState == .authenticated else {
            return
        }
        
        guard let lastTime = lastInactiveTime else {
            self.isBlurAppScreen = false
            return
        }
        
        let elapsed = Date().timeIntervalSince(lastTime)
        if elapsed >= Double(autoLockTimeout.rawValue) {
            self.authState = .locked
        } else {
            self.isBlurAppScreen = false
        }
    }
}
