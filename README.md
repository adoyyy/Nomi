# Nomi — Pahami Keuanganmu. 💸

Nomi is an AI-first personal finance tracker built natively for iOS. Nomi believes that tracking your finances shouldn't be tedious. With the core philosophy of **"Satu foto untuk mencatat transaksi, satu layar untuk memahami kondisi keuangan"**, Nomi eliminates the friction of manual entry through on-device receipt scanning.

## 🌟 Key Features

* **Nomi Scan (On-device OCR)**: Snap a picture of your receipt, and Nomi uses Apple's native Vision framework to extract the merchant, amount, and date. All parsing happens locally on your device for complete privacy.
* **Smart Ledger**: An accurate, dual-entry style ledger supporting Income, Expenses, and Transfers between wallets.
* **Derived Balances**: Balances are calculated dynamically (not hardcoded) to ensure mathematical accuracy when past transactions are edited or deleted.
* **Face ID Security**: Lock your financial data behind biometrics. Includes auto-lock timeouts and app-switcher blurring to protect sensitive information in public.
* **Interactive Insights**: Visualize your spending and income with beautiful, native Swift Charts.
* **Privacy First**: Built with SwiftData and local processing. No external AI APIs are required for the MVP, ensuring your financial data never leaves your iPhone without consent.

## 🛠 Tech Stack & Architecture

Nomi is built strictly with modern, native Apple frameworks:

* **Platform**: iOS 17.0+
* **UI**: SwiftUI
* **Persistence**: SwiftData
* **Machine Learning / OCR**: Vision (`VNRecognizeTextRequest`) & `VNDocumentCameraViewController`
* **Security**: LocalAuthentication (Face ID / Touch ID)
* **Architecture**: MVVM + Services/Repositories
  * **Services**: Handle business logic and mutations (e.g., `TransactionService`, `FinancialCalculator`).
  * **Repositories**: (Planned) Abstraction over SwiftData queries.

## 🚀 Development Workflow (Windows to iOS)

This project uses an unconventional but highly effective CI/CD pipeline, allowing development on a Windows machine while compiling and testing on macOS in the cloud:

1. **Code**: Write `.swift` files in VS Code on Windows.
2. **Project Generation**: Instead of manual `.xcodeproj` management, the project structure is defined in `project.yml`.
3. **CI/CD**: Push to GitHub. GitHub Actions (macOS runner) automatically runs `xcodegen` to generate the Xcode project, then runs `xcodebuild` to compile and test the app.
4. **Distribution**: (Upcoming) Push the compiled `.ipa` to TestFlight.

## 💻 How to Build Locally (macOS)

If you have a Mac and want to run this project in Xcode:

1. Clone this repository.
2. Install **XcodeGen**:
   ```bash
   brew install xcodegen
   ```
3. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
4. Open `Nomi.xcodeproj` in Xcode 15 or later.
5. Select a Simulator or physical iPhone and press `Cmd + R` to run!

## 🧪 Testing
The app includes a suite of unit tests focusing on the core financial engine:
- `FinancialCalculatorTests`: Validates derived balance math across expenses, income, transfers, and edits.
- `TransactionServiceTests`: Validates SwiftData context mutations and Duplicate Detection logic.

---
*Built with ❤️ for a smarter financial life.*