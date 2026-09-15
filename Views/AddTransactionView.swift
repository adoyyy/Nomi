import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Wallet> { $0.isActive }) private var wallets: [Wallet]
    @Query private var categories: [TransactionCategory]
    
    @State private var type: TransactionType = .expense
    @State private var amountString: String = ""
    @State private var selectedWallet: Wallet?
    @State private var selectedDestinationWallet: Wallet?
    @State private var selectedCategory: TransactionCategory?
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var merchant: String = ""
    
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Type", selection: $type) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                    Text("Transfer").tag(TransactionType.transfer)
                }
                .pickerStyle(SegmentedPickerStyle())
                .listRowBackground(Color.clear)
                
                Section {
                    HStack {
                        Text("Rp")
                            .foregroundColor(.secondary)
                        TextField("0", text: $amountString)
                            .keyboardType(.numberPad)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .focused($isAmountFocused)
                    }
                }
                
                Section {
                    if type == .transfer {
                        Picker("From Wallet", selection: $selectedWallet) {
                            Text("Select Wallet").tag(Wallet?.none)
                            ForEach(wallets) { wallet in
                                Text(wallet.name).tag(Wallet?.some(wallet))
                            }
                        }
                        
                        Picker("To Wallet", selection: $selectedDestinationWallet) {
                            Text("Select Wallet").tag(Wallet?.none)
                            ForEach(wallets) { wallet in
                                Text(wallet.name).tag(Wallet?.some(wallet))
                            }
                        }
                    } else {
                        Picker("Wallet", selection: $selectedWallet) {
                            Text("Select Wallet").tag(Wallet?.none)
                            ForEach(wallets) { wallet in
                                Text(wallet.name).tag(Wallet?.some(wallet))
                            }
                        }
                        
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select Category").tag(TransactionCategory?.none)
                            ForEach(categories.filter { $0.type == type.rawValue }) { category in
                                Text("\(Image(systemName: category.icon)) \(category.name)").tag(TransactionCategory?.some(category))
                            }
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section {
                    if type != .transfer {
                        TextField("Merchant (Optional)", text: $merchant)
                    }
                    TextField("Notes (Optional)", text: $notes)
                }
            }
            .navigationTitle(titleForType())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTransaction() }
                        .disabled(amountString.isEmpty || selectedWallet == nil || (type != .transfer && selectedCategory == nil) || (type == .transfer && selectedDestinationWallet == nil))
                }
            }
            .onAppear {
                if wallets.isEmpty {
                    let defaultWallet = Wallet(name: "BCA", type: "Bank", initialBalance: 5000000)
                    modelContext.insert(defaultWallet)
                    selectedWallet = defaultWallet
                    
                    let defaultCat = TransactionCategory(name: "Food", type: "expense", icon: "fork.knife", color: "#FF5733")
                    modelContext.insert(defaultCat)
                    selectedCategory = defaultCat
                } else {
                    selectedWallet = wallets.first
                    selectedCategory = categories.first(where: { $0.type == type.rawValue })
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAmountFocused = true
                }
            }
            .onChange(of: type) { _ in
                selectedCategory = categories.first(where: { $0.type == type.rawValue })
            }
        }
    }
    
    private func titleForType() -> String {
        switch type {
        case .expense: return "Add Expense"
        case .income: return "Add Income"
        case .transfer: return "Transfer"
        }
    }
    
    private func saveTransaction() {
        guard let amount = Double(amountString), let wallet = selectedWallet else { return }
        
        let service = TransactionService(modelContext: modelContext)
        
        if type == .expense {
            service.createExpense(amount: amount, wallet: wallet, category: selectedCategory, merchant: merchant.isEmpty ? nil : merchant, notes: notes.isEmpty ? nil : notes, date: date)
        } else if type == .income {
            service.createIncome(amount: amount, wallet: wallet, category: selectedCategory, merchant: merchant.isEmpty ? nil : merchant, notes: notes.isEmpty ? nil : notes, date: date)
        } else if type == .transfer {
            guard let destWallet = selectedDestinationWallet else { return }
            service.createTransfer(amount: amount, sourceWallet: wallet, destinationWallet: destWallet, notes: notes.isEmpty ? nil : notes, date: date)
        }
        
        dismiss()
    }
}
