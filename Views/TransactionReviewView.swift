import SwiftUI
import SwiftData

struct TransactionReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var wallets: [Wallet]
    @Query private var categories: [TransactionCategory]
    @Query private var existingTransactions: [Transaction]
    
    var parsedTransaction: ParsedTransaction
    var receiptImage: UIImage?
    var ocrText: String?
    
    @State private var amountString: String = ""
    @State private var merchant: String = ""
    @State private var date: Date = Date()
    @State private var selectedWallet: Wallet?
    @State private var selectedCategory: TransactionCategory?
    @State private var showDuplicateWarning = false
    
    var body: some View {
        NavigationView {
            Form {
                if let image = receiptImage {
                    Section {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                            .listRowInsets(EdgeInsets())
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Amount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Rp")
                                .foregroundColor(.secondary)
                            TextField("Amount", text: $amountString)
                                .keyboardType(.numberPad)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }
                    if let score = parsedTransaction.amountConfidence {
                        ConfidenceBadge(score: score)
                    }
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Merchant")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Merchant", text: $merchant)
                            .font(.headline)
                    }
                    if let score = parsedTransaction.merchantConfidence {
                        ConfidenceBadge(score: score)
                    }
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    if let score = parsedTransaction.dateConfidence {
                        ConfidenceBadge(score: score)
                    }
                }
                
                Section {
                    Picker("Wallet", selection: $selectedWallet) {
                        Text("Select Wallet").tag(Wallet?.none)
                        ForEach(wallets) { wallet in
                            Text(wallet.name).tag(Wallet?.some(wallet))
                        }
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(TransactionCategory?.none)
                        ForEach(categories.filter { $0.type == TransactionType.expense.rawValue }) { category in
                            Text("\(Image(systemName: category.icon)) \(category.name)").tag(TransactionCategory?.some(category))
                        }
                    }
                }
            }
            .navigationTitle("Review Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { checkAndSave() }
                        .disabled(amountString.isEmpty || selectedWallet == nil || selectedCategory == nil || merchant.isEmpty)
                }
            }
            .onAppear {
                if let amount = parsedTransaction.amount {
                    amountString = String(format: "%.0f", amount)
                }
                if let parsedMerchant = parsedTransaction.merchant {
                    merchant = parsedMerchant
                }
                if let parsedDate = parsedTransaction.date {
                    date = parsedDate
                }
                selectedWallet = wallets.first
                selectedCategory = categories.first(where: { $0.type == TransactionType.expense.rawValue })
            }
            .alert("Possible Duplicate", isPresented: $showDuplicateWarning) {
                Button("Save Anyway") {
                    saveTransaction()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("A transaction for \(merchant) with the same amount on this date already exists.")
            }
        }
    }
    
    private func checkAndSave() {
        guard let amount = Double(amountString) else { return }
        let service = TransactionService(modelContext: modelContext)
        if service.checkDuplicate(merchant: merchant, amount: amount, date: date, existingTransactions: existingTransactions) {
            showDuplicateWarning = true
        } else {
            saveTransaction()
        }
    }
    
    private func saveTransaction() {
        guard let amount = Double(amountString), let wallet = selectedWallet, let category = selectedCategory else { return }
        
        let receipt = Receipt(
            ocrText: ocrText,
            merchantConfidence: parsedTransaction.merchantConfidence,
            amountConfidence: parsedTransaction.amountConfidence,
            dateConfidence: parsedTransaction.dateConfidence,
            processedAt: Date(),
            extractionVersion: TransactionParser.extractionVersion
        )
        
        let service = TransactionService(modelContext: modelContext)
        service.createExpense(amount: amount, wallet: wallet, category: category, merchant: merchant, notes: nil, date: date, source: .scanner, receipt: receipt)
        
        dismiss()
    }
}

struct ConfidenceBadge: View {
    var score: Double
    var body: some View {
        HStack {
            Spacer()
            if score >= 0.9 {
                Text("✓ High confidence")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else if score >= 0.7 {
                Text("Medium confidence")
                    .font(.caption2)
                    .foregroundColor(.orange)
            } else {
                Text("⚠ Please verify")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
    }
}
