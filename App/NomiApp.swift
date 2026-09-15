import SwiftUI
import SwiftData

@main
struct NomiApp: App {
    @StateObject private var securityManager = SecurityManager()
    @Environment(\.scenePhase) var scenePhase
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Wallet.self,
            TransactionCategory.self,
            Transaction.self,
            Receipt.self
        ])
        let isRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isRunningTests)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if securityManager.isAuthenticated {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    Text("Transactions View Placeholder")
                        .tabItem {
                            Label("Transactions", systemImage: "list.bullet")
                        }
                    
                    ReportsView()
                        .tabItem {
                            Label("Reports", systemImage: "chart.pie")
                        }
                }
                .environment(\.modelContext, sharedModelContainer.mainContext)
                .blur(radius: securityManager.isBlurAppScreen ? 15 : 0)
            } else {
                LockView(securityManager: securityManager)
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                securityManager.handleAppBackgrounding()
            } else if newPhase == .active {
                securityManager.handleAppForegrounding()
            }
        }
    }
}

struct LockView: View {
    @ObservedObject var securityManager: SecurityManager
    @State private var hasAttemptedInitialAuth = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding()
            
            Text("Nomi is locked")
                .font(.title2)
                .fontWeight(.semibold)
                
            if securityManager.authState == .failed {
                Text("Face ID couldn't verify you.")
                    .foregroundColor(.red)
                    .font(.subheadline)
            } else if securityManager.authState == .unavailable {
                Text("Face ID is temporarily unavailable.\nUse your device passcode or retry later.")
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            
            if securityManager.authState == .authenticating {
                ProgressView()
                    .padding()
            } else {
                Button("Unlock Nomi") {
                    securityManager.authenticate()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .onAppear {
            if !hasAttemptedInitialAuth && securityManager.authState == .locked {
                hasAttemptedInitialAuth = true
                securityManager.authenticate()
            }
        }
    }
}
