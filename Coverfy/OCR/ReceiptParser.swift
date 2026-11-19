import Foundation

/// Heuristic extraction of purchase data from OCR receipt text.
enum ReceiptParser {

    struct ParsedReceipt {
        let store: String?
        let purchaseDate: Date?
        let rawText: String
    }

    private static let dateFormats = [
        (#"(\d{2})[/-](\d{2})[/-](\d{4})"#, "dd/MM/yyyy"),
        (#"(\d{2})[/-](\d{2})[/-](\d{2})"#, "dd/MM/yy"),
        (#"(\d{4})-(\d{2})-(\d{2})"#, "yyyy-MM-dd"),
    ]

    private static let skipLine = try! NSRegularExpression(
        pattern: #"(?i)(ticket|factura|fecha|hora|cif|nif|iva|total|cambio|gracias|tel|www\.|http|copia|cliente|devoluci[oó]n)"#
    )

    static func parse(_ text: String) -> ParsedReceipt {
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let date = lines.lazy.compactMap(findDate(in:)).first

        let store = lines.prefix(6).first { line in
            line.count >= 3 && line.count <= 40 &&
            line.rangeOfCharacter(from: .letters) != nil &&
            skipLine.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) == nil &&
            line.filter(\.isNumber).count <= 3
        }

        return ParsedReceipt(store: store, purchaseDate: date, rawText: text)
    }

    private static func findDate(in line: String) -> Date? {
        let nsRange = NSRange(line.startIndex..., in: line)
        for (pattern, format) in dateFormats {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: line, range: nsRange),
                  let range = Range(match.range, in: line)
            else { continue }
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.isLenient = false
            guard let date = formatter.date(from: String(line[range])) else { continue }
            let year = Calendar.current.component(.year, from: date)
            let now = Calendar.current.component(.year, from: .now)
            if year >= now - 15 && year <= now + 1 {
                return date
            }
        }
        return nil
    }
}
