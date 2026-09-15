import Foundation

struct ParsedTransaction {
    var amount: Double?
    var amountConfidence: Double?
    
    var merchant: String?
    var merchantConfidence: Double?
    
    var date: Date?
    var dateConfidence: Double?
}

class TransactionParser {
    static let extractionVersion = 2
    
    static func parse(ocrText: String) -> ParsedTransaction {
        var parsed = ParsedTransaction()
        let lines = ocrText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !lines.isEmpty else { return parsed }
        
        let amountCandidates = extractAmounts(from: lines)
        if let bestAmount = amountCandidates.max(by: { $0.score < $1.score }) {
            parsed.amount = bestAmount.value
            parsed.amountConfidence = bestAmount.score
        }
        
        if let merchant = extractMerchant(from: lines) {
            parsed.merchant = merchant.value
            parsed.merchantConfidence = merchant.score
        }
        
        if let date = extractDate(from: lines) {
            parsed.date = date.value
            parsed.dateConfidence = date.score
        }
        
        return parsed
    }
    
    private static func extractAmounts(from lines: [String]) -> [(value: Double, score: Double)] {
        var candidates: [(Double, Double)] = []
        let totalKeywords = ["total", "grand total", "total bayar", "total payment", "jumlah", "amount", "tagihan"]
        
        let amountRegex = try? NSRegularExpression(pattern: "(?:rp\\s*)?(\\d{1,3}(?:[.,]\\d{3})*(?:[.,]\\d{2})?)")
        
        for line in lines {
            let lowerLine = line.lowercased()
            var lineHasTotalKeyword = false
            for kw in totalKeywords {
                if lowerLine.contains(kw) {
                    lineHasTotalKeyword = true
                    break
                }
            }
            
            if let regex = amountRegex {
                let matches = regex.matches(in: lowerLine, range: NSRange(lowerLine.startIndex..., in: lowerLine))
                for match in matches {
                    if let range = Range(match.range(at: 1), in: lowerLine) {
                        let amountStr = lowerLine[range].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")
                        if let amount = Double(amountStr) {
                            var score = 0.5
                            if lineHasTotalKeyword { score += 0.4 }
                            if amount > 1000 { score += 0.05 }
                            candidates.append((amount, min(1.0, score)))
                        }
                    }
                }
            }
        }
        return candidates
    }
    
    private static func extractMerchant(from lines: [String]) -> (value: String, score: Double)? {
        let exclusions = ["pt", "cabang", "kasir", "jl", "jalan", "telp"]
        for line in lines {
            let lower = line.lowercased()
            if exclusions.contains(where: { lower.hasPrefix($0) }) {
                continue
            }
            if line.count > 3 && Double(line) == nil {
                return (line, 0.8)
            }
        }
        return (lines.first ?? "", 0.4)
    }
    
    private static func extractDate(from lines: [String]) -> (value: Date, score: Double)? {
        let dateRegex = try? NSRegularExpression(pattern: "\\b(\\d{1,2})[/.-](\\d{1,2})[/.-](\\d{2,4})\\b")
        for line in lines {
            if let regex = dateRegex, let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                if let range = Range(match.range, in: line) {
                    let dateStr = String(line[range])
                    let df = DateFormatter()
                    df.dateFormat = "dd/MM/yyyy"
                    if let date = df.date(from: dateStr.replacingOccurrences(of: "-", with: "/").replacingOccurrences(of: ".", with: "/")) {
                        return (date, 0.9)
                    }
                }
            }
        }
        return nil
    }
}
