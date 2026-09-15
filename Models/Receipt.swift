import Foundation
import SwiftData

@Model
final class Receipt {
    var id: UUID = UUID()
    
    @Relationship(inverse: \Transaction.receipt)
    var transaction: Transaction?
    
    var imagePath: String? 
    var originalImageHash: String?
    var ocrText: String?
    
    var merchantConfidence: Double?
    var amountConfidence: Double?
    var dateConfidence: Double?
    
    var processedAt: Date
    var extractionVersion: Int
    
    init(id: UUID = UUID(), imagePath: String? = nil, originalImageHash: String? = nil, ocrText: String? = nil, merchantConfidence: Double? = nil, amountConfidence: Double? = nil, dateConfidence: Double? = nil, processedAt: Date = Date(), extractionVersion: Int = 1) {
        self.id = id
        self.imagePath = imagePath
        self.originalImageHash = originalImageHash
        self.ocrText = ocrText
        self.merchantConfidence = merchantConfidence
        self.amountConfidence = amountConfidence
        self.dateConfidence = dateConfidence
        self.processedAt = processedAt
        self.extractionVersion = extractionVersion
    }
}
