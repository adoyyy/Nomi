import Foundation
import LocalAuthentication
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

class SecurityManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isPrivacyMode = false
    @Published var isBlurAppScreen = false
    
    @AppStorage("autoLockTimeout") var autoLockTimeoutRawValue: Int = AutoLockTimeout.immediately.rawValue
    
    var autoLockTimeout: AutoLockTimeout {
        AutoLockTimeout(rawValue: autoLockTimeoutRawValue) ?? .immediately
    }
    
    private var lastInactiveTime: Date?
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock Nomi to view your financial data."
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                        self.isBlurAppScreen = false
                    } else {
                        print(authenticationError?.localizedDescription ?? "Authentication failed")
                        self.isAuthenticated = false
                        self.isBlurAppScreen = true
                    }
                }
            }
        } else {
            self.isAuthenticated = true
            self.isBlurAppScreen = false
        }
    }
    
    func handleAppBackgrounding() {
        self.isBlurAppScreen = true
        self.lastInactiveTime = Date()
    }
    
    func handleAppForegrounding() {
        if !isAuthenticated {
            authenticate()
            return
        }
        
        guard let lastTime = lastInactiveTime else {
            self.isBlurAppScreen = false
            return
        }
        
        let elapsed = Date().timeIntervalSince(lastTime)
        if elapsed >= Double(autoLockTimeout.rawValue) {
            self.isAuthenticated = false
            authenticate()
        } else {
            self.isBlurAppScreen = false
        }
    }
}
