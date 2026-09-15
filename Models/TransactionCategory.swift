import Foundation
import SwiftData

@Model
final class TransactionCategory {
    var id: UUID = UUID()
    var name: String
    var type: String // "Income", "Expense"
    var icon: String
    var color: String
    var budget: Double?
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]?
    
    init(id: UUID = UUID(), name: String, type: String, icon: String, color: String = "#FF0000", budget: Double? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.icon = icon
        self.color = color
        self.budget = budget
    }
}
