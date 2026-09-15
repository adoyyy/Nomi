import Foundation

struct DateFormatterHelper {
    static let shared = DateFormatterHelper()
    
    let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static func format(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        return shared.displayFormatter.string(from: date)
    }
    
    static func formatTime(_ date: Date) -> String {
        return shared.timeFormatter.string(from: date)
    }
}
