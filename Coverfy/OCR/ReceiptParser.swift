import Foundation

/// Heuristic extraction of purchase data from OCR receipt text.
enum ReceiptParser {

    struct ParsedReceipt {
        let store: String?
        let productName: String?
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

    // Lines inside the item area that are payment/metadata, not products
    private static let skipItemLine = try! NSRegularExpression(
        pattern: #"(?i)\b(ticket|factura|fecha|hora|cif|nif|iva|cambio|gracias|tel|tfno|www|http|copia|cliente|devoluci[oó]n|subtotal|efectivo|tarjeta|visa|mastercard|importe|base|dto|descuento|entregado|pago|unidades|uds|art[ií]culos|caja|vendedor|atendid[oa]|operaci[oó]n|autoriz\w*|direcci[oó]n|calle|avda|garant[ií]a)\b"#
    )
    private static let totalLine = try! NSRegularExpression(pattern: #"(?i)\btotal\b"#)
    private static let trailingPrice = try! NSRegularExpression(
        pattern: #"\s*-?(\d{1,5}[.,]\d{2})\s*(€|eur)?\s*[A-Z]?$"#, options: .caseInsensitive
    )
    private static let leadingQtyOrCode = try! NSRegularExpression(pattern: #"^(\d{1,3}\s*[xX]?\s+|\d{5,}\s+)"#)

    private static func matches(_ regex: NSRegularExpression, _ line: String) -> Bool {
        regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil
    }

    private static func removing(_ regex: NSRegularExpression, from line: String) -> String {
        regex.stringByReplacingMatches(in: line, range: NSRange(line.startIndex..., in: line), withTemplate: "")
    }

    /// Picks the most expensive item line before the total: usually the product the warranty is for.
    private static func findProduct(in lines: [String], after storeIndex: Int?) -> String? {
        let end = lines.firstIndex { matches(totalLine, $0) } ?? lines.count
        let start = min((storeIndex ?? -1) + 1, end)
        let candidates: [(String, Double)] = lines[start..<end].compactMap { line in
            if matches(skipItemLine, line) || findDate(in: line) != nil { return nil }
            var price = 0.0
            if let m = trailingPrice.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let r = Range(m.range(at: 1), in: line) {
                price = Double(line[r].replacingOccurrences(of: ",", with: ".")) ?? 0
            }
            let name = removing(leadingQtyOrCode, from: removing(trailingPrice, from: line))
                .split(whereSeparator: \.isWhitespace).joined(separator: " ")
            let letters = name.filter(\.isLetter).count
            guard letters >= 4, name.count <= 60, letters * 2 >= name.count else { return nil }
            return (name, price)
        }
        return candidates.max { $0.1 < $1.1 }?.0
    }

    static func parse(_ text: String) -> ParsedReceipt {
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let date = lines.lazy.compactMap(findDate(in:)).first

        let storeIndex = lines.prefix(6).firstIndex { line in
            line.count >= 3 && line.count <= 40 &&
            line.rangeOfCharacter(from: .letters) != nil &&
            skipLine.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) == nil &&
            line.filter(\.isNumber).count <= 3
        }

        let store = storeIndex.map { lines[$0] }
        let productName = findProduct(in: lines, after: storeIndex)

        return ParsedReceipt(store: store, productName: productName, purchaseDate: date, rawText: text)
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
