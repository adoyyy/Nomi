import Foundation
import SwiftData

class TransactionService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createIncome(amount: Double, wallet: Wallet, category: TransactionCategory?, merchant: String?, notes: String?, date: Date, source: TransactionSource = .manual) {
        let transaction = Transaction(type: .income, amount: amount, category: category, wallet: wallet, merchant: merchant, notes: notes, date: date, source: source)
        modelContext.insert(transaction)
        try? modelContext.save()
    }
    
    func createExpense(amount: Double, wallet: Wallet, category: TransactionCategory?, merchant: String?, notes: String?, date: Date, source: TransactionSource = .manual, receipt: Receipt? = nil) {
        let transaction = Transaction(type: .expense, amount: amount, category: category, wallet: wallet, merchant: merchant, notes: notes, date: date, receipt: receipt, source: source)
        modelContext.insert(transaction)
        try? modelContext.save()
    }
    
    func createTransfer(amount: Double, sourceWallet: Wallet, destinationWallet: Wallet, notes: String?, date: Date, source: TransactionSource = .manual) {
        let transaction = Transaction(type: .transfer, amount: amount, wallet: sourceWallet, destinationWallet: destinationWallet, notes: notes, date: date, source: source)
        modelContext.insert(transaction)
        try? modelContext.save()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transaction.isSoftDeleted = true
        transaction.deletedAt = Date()
        transaction.updatedAt = Date()
        try? modelContext.save()
    }
    
    func checkDuplicate(merchant: String, amount: Double, date: Date, existingTransactions: [Transaction]) -> Bool {
        let calendar = Calendar.current
        return existingTransactions.contains { t in
            !t.isSoftDeleted &&
            t.amount == amount &&
            t.merchant?.lowercased() == merchant.lowercased() &&
            calendar.isDate(t.date, inSameDayAs: date)
        }
    }
}
