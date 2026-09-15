import SwiftUI

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingCamera = false
    @State private var scannedImage: UIImage?
    @State private var ocrResult: String = ""
    @State private var isProcessing = false
    @State private var showReview = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = scannedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .padding()
                    
                    if isProcessing {
                        ProgressView("Analyzing receipt...")
                            .padding()
                    } else if !ocrResult.isEmpty {
                        ScrollView {
                            Text(ocrResult)
                                .font(.caption)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding()
                        
                        Button("Review Transaction") {
                            showReview = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Scan a receipt to automatically extract transaction details.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button("Open Camera") {
                            showingCamera = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCamera) {
                DocumentCameraView(scannedImage: $scannedImage)
            }
            .sheet(isPresented: $showReview) {
                if let image = scannedImage {
                    TransactionReviewView(
                        parsedTransaction: TransactionParser.parse(ocrText: ocrResult),
                        receiptImage: image,
                        ocrText: ocrResult
                    )
                }
            }
            .onChange(of: scannedImage) { newImage in
                if let image = newImage {
                    processImage(image)
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        isProcessing = true
        OCRService.extractText(from: image) { text in
            DispatchQueue.main.async {
                self.ocrResult = text ?? "No text detected."
                self.isProcessing = false
            }
        }
    }
}
