import Foundation
import SwiftData

@Model
final class Wallet {
    var id: UUID = UUID()
    var name: String
    var type: String // "Cash", "Bank", "E-Wallet", "Credit Card"
    var initialBalance: Double
    var currency: String
    var icon: String
    var isActive: Bool
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.wallet)
    var transactions: [Transaction]?
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.destinationWallet)
    var incomingTransfers: [Transaction]?
    
    init(id: UUID = UUID(), name: String, type: String, initialBalance: Double, currency: String = "IDR", icon: String = "creditcard", isActive: Bool = true) {
        self.id = id
        self.name = name
        self.type = type
        self.initialBalance = initialBalance
        self.currency = currency
        self.icon = icon
        self.isActive = isActive
    }
}
