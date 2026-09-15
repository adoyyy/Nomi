import Foundation
import SwiftData

enum TransactionType: String, Codable {
    case income
    case expense
    case transfer
}

enum TransactionSource: String, Codable {
    case manual
    case scanner
    case recurring
}

@Model
final class Transaction {
    var id: UUID = UUID()
    var type: TransactionType
    var amount: Double
    var currency: String
    
    var category: TransactionCategory?
    
    // For Expense/Income this is the primary wallet. For Transfer this is the Source Wallet.
    var wallet: Wallet?
    // For Transfer this is the Destination Wallet.
    var destinationWallet: Wallet?
    
    var merchant: String?
    var notes: String?
    
    var date: Date
    
    @Relationship(deleteRule: .cascade)
    var receipt: Receipt?
    
    var source: TransactionSource
    var createdAt: Date
    var updatedAt: Date
    var isSoftDeleted: Bool = false
    var deletedAt: Date?
    
    init(id: UUID = UUID(), type: TransactionType, amount: Double, currency: String = "IDR", category: TransactionCategory? = nil, wallet: Wallet? = nil, destinationWallet: Wallet? = nil, merchant: String? = nil, notes: String? = nil, date: Date = Date(), receipt: Receipt? = nil, source: TransactionSource = .manual, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.amount = amount
        self.currency = currency
        self.category = category
        self.wallet = wallet
        self.destinationWallet = destinationWallet
        self.merchant = merchant
        self.notes = notes
        self.date = date
        self.receipt = receipt
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
