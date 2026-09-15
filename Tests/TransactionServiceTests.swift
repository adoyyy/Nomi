import XCTest
import SwiftData
@testable import Nomi

final class TransactionServiceTests: XCTestCase {
    
    var container: ModelContainer!
    var context: ModelContext!
    var service: TransactionService!
    var wallet: Wallet!
    
    override func setUpWithError() throws {
        let schema = Schema([Wallet.self, TransactionCategory.self, Transaction.self, Receipt.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = container.mainContext
        service = TransactionService(modelContext: context)
        
        wallet = Wallet(name: "Test Wallet", type: "Bank", initialBalance: 1000)
        context.insert(wallet)
    }
    
    func testCreateExpense() {
        service.createExpense(amount: 100, wallet: wallet, category: nil, merchant: "Test", notes: nil, date: Date())
        
        let descriptor = FetchDescriptor<Transaction>()
        let transactions = try? context.fetch(descriptor)
        
        XCTAssertEqual(transactions?.count, 1)
        XCTAssertEqual(transactions?.first?.amount, 100)
        XCTAssertEqual(transactions?.first?.type, .expense)
        XCTAssertFalse(transactions!.first!.isDeleted)
    }
    
    func testDeleteTransaction() {
        service.createExpense(amount: 100, wallet: wallet, category: nil, merchant: "Test", notes: nil, date: Date())
        
        let descriptor = FetchDescriptor<Transaction>()
        let transactions = try! context.fetch(descriptor)
        XCTAssertEqual(transactions.count, 1)
        
        let transaction = transactions.first!
        service.deleteTransaction(transaction)
        
        XCTAssertTrue(transaction.isDeleted)
        XCTAssertNotNil(transaction.deletedAt)
    }
    
    func testCheckDuplicate() {
        let date = Date()
        service.createExpense(amount: 500, wallet: wallet, category: nil, merchant: "Starbucks", notes: nil, date: date)
        
        let transactions = try! context.fetch(FetchDescriptor<Transaction>())
        
        let isDuplicate = service.checkDuplicate(merchant: "Starbucks", amount: 500, date: date, existingTransactions: transactions)
        XCTAssertTrue(isDuplicate)
        
        let isNotDuplicateAmount = service.checkDuplicate(merchant: "Starbucks", amount: 200, date: date, existingTransactions: transactions)
        XCTAssertFalse(isNotDuplicateAmount)
    }
}
