import Foundation

class FinancialCalculator {
    static let shared = FinancialCalculator()
    
    private init() {}
    
    func calculateBalance(for wallet: Wallet) -> Double {
        var currentBalance = wallet.initialBalance
        
        if let transactions = wallet.transactions {
            for transaction in transactions where !transaction.isDeleted {
                if transaction.type == .income {
                    currentBalance += transaction.amount
                } else if transaction.type == .expense {
                    currentBalance -= transaction.amount
                } else if transaction.type == .transfer {
                    currentBalance -= transaction.amount
                }
            }
        }
        
        if let incoming = wallet.incomingTransfers {
            for transfer in incoming where !transfer.isDeleted && transfer.type == .transfer {
                currentBalance += transfer.amount
            }
        }
        
        return currentBalance
    }
    
    func calculateTotalBalance(wallets: [Wallet]) -> Double {
        var total: Double = 0
        for wallet in wallets {
            total += calculateBalance(for: wallet)
        }
        return total
    }
    
    func currentMonthRange() -> Range<Date> {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components)!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        return startOfMonth..<endOfMonth
    }
    
    func calculateTotalIncome(transactions: [Transaction], in dateRange: Range<Date>? = nil) -> Double {
        let validTransactions = filterTransactions(transactions, in: dateRange)
        return validTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    func calculateTotalExpense(transactions: [Transaction], in dateRange: Range<Date>? = nil) -> Double {
        let validTransactions = filterTransactions(transactions, in: dateRange)
        return validTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    func calculateCategoryBreakdown(transactions: [Transaction], in dateRange: Range<Date>? = nil) -> [(category: String, amount: Double)] {
        let validTransactions = filterTransactions(transactions, in: dateRange)
        let expenses = validTransactions.filter { $0.type == .expense }
        var dict: [String: Double] = [:]
        for exp in expenses {
            let catName = exp.category?.name ?? "Other"
            dict[catName, default: 0] += exp.amount
        }
        return dict.map { (category: $0.key, amount: $0.value) }.sorted(by: { $0.amount > $1.amount })
    }
    
    private func filterTransactions(_ transactions: [Transaction], in dateRange: Range<Date>?) -> [Transaction] {
        let notDeleted = transactions.filter { !$0.isDeleted }
        if let range = dateRange {
            return notDeleted.filter { range.contains($0.date) }
        }
        return notDeleted
    }
}
