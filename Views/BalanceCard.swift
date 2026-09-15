import SwiftUI
import SwiftData

struct BalanceCard: View {
    var totalBalance: Double
    var totalIncome: Double
    var totalExpense: Double
    
    @Binding var isPrivacyMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(isPrivacyMode ? "•••••••••" : CurrencyFormatter.format(totalBalance))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                Spacer()
                Button(action: {
                    isPrivacyMode.toggle()
                }) {
                    Image(systemName: isPrivacyMode ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(isPrivacyMode ? "••••••" : "+\(CurrencyFormatter.format(totalIncome))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading) {
                    Text("Expense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(isPrivacyMode ? "••••••" : "-\(CurrencyFormatter.format(totalExpense))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
