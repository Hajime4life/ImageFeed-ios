import Foundation

struct DateParser {
    private static let isoFormatter: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()
    
    private static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static func parseDate(from string: String?) -> Date? {
        guard let dateString = string else {
            print("Дата отсутствует")
            return nil
        }
        
        if let date = isoFormatter.date(from: dateString) {
            return date
        } else if let date = customFormatter.date(from: dateString) {
            return date
        } else {
            print("Не удалось распарсить дату: \(dateString)")
            return nil
        }
    }
}
