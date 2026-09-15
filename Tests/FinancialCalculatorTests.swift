import XCTest
import SwiftData
@testable import Nomi

final class FinancialCalculatorTests: XCTestCase {
    
    var calculator: FinancialCalculator!
    var bcaWallet: Wallet!
    var gopayWallet: Wallet!
    
    override func setUp() {
        super.setUp()
        calculator = FinancialCalculator.shared
        
        bcaWallet = Wallet(name: "BCA", type: "Bank", initialBalance: 5_000_000)
        gopayWallet = Wallet(name: "GoPay", type: "E-Wallet", initialBalance: 1_000_000)
    }
    
    func testInitialBalance() {
        let bcaBalance = calculator.calculateBalance(for: bcaWallet)
        XCTAssertEqual(bcaBalance, 5_000_000)
    }
    
    func testIncome() {
        let income = Transaction(type: .income, amount: 1_000_000, wallet: bcaWallet)
        bcaWallet.transactions = [income]
        
        XCTAssertEqual(calculator.calculateBalance(for: bcaWallet), 6_000_000)
    }
    
    func testExpense() {
        let expense = Transaction(type: .expense, amount: 100_000, wallet: bcaWallet)
        bcaWallet.transactions = [expense]
        
        XCTAssertEqual(calculator.calculateBalance(for: bcaWallet), 4_900_000)
    }
    
    func testTransfer() {
        let transfer = Transaction(type: .transfer, amount: 1_000_000, wallet: bcaWallet, destinationWallet: gopayWallet)
        bcaWallet.transactions = [transfer]
        gopayWallet.incomingTransfers = [transfer]
        
        XCTAssertEqual(calculator.calculateBalance(for: bcaWallet), 4_000_000)
        XCTAssertEqual(calculator.calculateBalance(for: gopayWallet), 2_000_000)
        
        let totalNetWorth = calculator.calculateTotalBalance(wallets: [bcaWallet, gopayWallet])
        XCTAssertEqual(totalNetWorth, 6_000_000)
    }
    
    func testEditExpense() {
        let expense = Transaction(type: .expense, amount: 100_000, wallet: bcaWallet)
        bcaWallet.transactions = [expense]
        
        XCTAssertEqual(calculator.calculateBalance(for: bcaWallet), 4_900_000)
        
        expense.amount = 50_000
        
        XCTAssertEqual(calculator.calculateBalance(for: bcaWallet), 4_950_000)
    }
    
    func testDeleteExpense() {
        let expense = Transaction(type: .expense, amount: 100_000, wallet: bcaWallet)
        bcaWallet.transactions = [expense]
        
        XCTAssertEqual(calculator.calculateBalance(for: bcaWallet), 4_900_000)
        
        expense.isSoftDeleted = true
        
        XCTAssertEqual(calculator.calculateBalance(for: bcaWallet), 5_000_000)
    }
}
