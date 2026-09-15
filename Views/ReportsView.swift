import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Query private var transactions: [Transaction]
    
    var totalIncome: Double {
        FinancialCalculator.shared.calculateTotalIncome(transactions: transactions, in: FinancialCalculator.shared.currentMonthRange())
    }
    
    var totalExpense: Double {
        FinancialCalculator.shared.calculateTotalExpense(transactions: transactions, in: FinancialCalculator.shared.currentMonthRange())
    }
    
    var savings: Double {
        totalIncome - totalExpense
    }
    
    var expensesByCategory: [(category: String, amount: Double)] {
        FinancialCalculator.shared.calculateCategoryBreakdown(transactions: transactions, in: FinancialCalculator.shared.currentMonthRange())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Overview Summary
                    VStack(spacing: 16) {
                        Text("This Month Overview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Income")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(CurrencyFormatter.format(totalIncome))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Expense")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(CurrencyFormatter.format(totalExpense))
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Savings")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(CurrencyFormatter.format(savings))
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Income vs Expense Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Income vs Expense")
                            .font(.headline)
                        
                        Chart {
                            BarMark(
                                x: .value("Type", "Income"),
                                y: .value("Amount", totalIncome)
                            )
                            .foregroundStyle(.green)
                            
                            BarMark(
                                x: .value("Type", "Expense"),
                                y: .value("Amount", totalExpense)
                            )
                            .foregroundStyle(.red)
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Expense Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expense Breakdown")
                            .font(.headline)
                        
                        if expensesByCategory.isEmpty {
                            Text("No expenses this month.")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            Chart(expensesByCategory, id: \.category) { item in
                                SectorMark(
                                    angle: .value("Amount", item.amount),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(by: .value("Category", item.category))
                            }
                            .frame(height: 250)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Reports")
        }
    }
}
