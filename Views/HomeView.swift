import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var wallets: [Wallet]
    
    @State private var isPrivacyMode = false
    @State private var showingAddTransaction = false
    @State private var showingScanner = false
    
    var totalBalance: Double {
        FinancialCalculator.shared.calculateTotalBalance(wallets: wallets)
    }
    
    var totalIncome: Double {
        FinancialCalculator.shared.calculateTotalIncome(transactions: transactions, in: FinancialCalculator.shared.currentMonthRange())
    }
    
    var totalExpense: Double {
        FinancialCalculator.shared.calculateTotalExpense(transactions: transactions, in: FinancialCalculator.shared.currentMonthRange())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(DateFormatterHelper.shared.displayFormatter.string(from: Date()))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Good morning 👋")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Balance Card
                    BalanceCard(totalBalance: totalBalance, totalIncome: totalIncome, totalExpense: totalExpense, isPrivacyMode: $isPrivacyMode)
                        .padding(.horizontal)
                    
                    // Quick Actions
                    HStack(spacing: 16) {
                        QuickActionButton(icon: "camera.fill", title: "Scan", color: .blue) {
                            showingScanner = true
                        }
                        QuickActionButton(icon: "minus.circle.fill", title: "Expense", color: .red) {
                            showingAddTransaction = true
                        }
                        QuickActionButton(icon: "plus.circle.fill", title: "Income", color: .green) {
                            showingAddTransaction = true
                        }
                        QuickActionButton(icon: "arrow.left.arrow.right", title: "Transfer", color: .purple) {
                            showingAddTransaction = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if transactions.isEmpty {
                            Text("No transactions yet.")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(transactions.prefix(5)) { transaction in
                                TransactionRow(transaction: transaction, isPrivacyMode: $isPrivacyMode)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTransaction) {
                // AddTransactionView()
                Text("Add Transaction View Placeholder")
            }
            .sheet(isPresented: $showingScanner) {
                // ScannerView()
                Text("Scanner View Placeholder")
            }
        }
    }
}

struct QuickActionButton: View {
    var icon: String
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct TransactionRow: View {
    var transaction: Transaction
    @Binding var isPrivacyMode: Bool
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category?.icon ?? "dollarsign.circle.fill")
                .font(.title2)
                .foregroundColor(Color(hex: transaction.category?.color ?? "#888888"))
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading) {
                Text(transaction.merchant ?? transaction.notes ?? transaction.category?.name ?? "Transaction")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(transaction.category?.name ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(isPrivacyMode ? "••••" : "\(transaction.type == .expense || transaction.type == .transfer ? "-" : "+")\(CurrencyFormatter.format(transaction.amount))")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor((transaction.type == .expense || transaction.type == .transfer) ? .primary : .green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
