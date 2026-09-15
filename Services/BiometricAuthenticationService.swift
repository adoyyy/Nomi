import Foundation
import LocalAuthentication

protocol BiometricAuthenticationService {
    func canEvaluatePolicy() -> Bool
    func authenticate(reason: String, completion: @escaping (Bool, Error?) -> Void)
}

class DefaultBiometricAuthenticationService: BiometricAuthenticationService {
    func canEvaluatePolicy() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
    
    func authenticate(reason: String, completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
            completion(success, error)
        }
    }
}
