import Foundation
import UIKit

struct ImageCandidate: Identifiable, Hashable {
    let id = UUID()
    let thumbnail: URL
    let original: URL?
}

/// Looks up product pictures by name through SerpAPI (Google Images). Only the query text leaves the device.
enum ProductImageSearch {
    /// Replaced by the release workflow with the SERPAPI_API_KEY secret.
    private static let apiKey = "__SERPAPI_API_KEY__"

    static var isEnabled: Bool { !apiKey.isEmpty && !apiKey.hasPrefix("__") }

    static func search(_ query: String, limit: Int = 8) async throws -> [ImageCandidate] {
        var components = URLComponents(string: "https://serpapi.com/search.json")!
        components.queryItems = [
            URLQueryItem(name: "engine", value: "google_images"),
            URLQueryItem(name: "q", value: query.trimmingCharacters(in: .whitespaces)),
            URLQueryItem(name: "api_key", value: apiKey),
        ]
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let results = json?["images_results"] as? [[String: Any]] ?? []
        return results.prefix(limit).compactMap { item in
            guard let thumb = (item["thumbnail"] as? String).flatMap(URL.init(string:)) else { return nil }
            return ImageCandidate(thumbnail: thumb, original: (item["original"] as? String).flatMap(URL.init(string:)))
        }
    }

    /// Downloads the full image, falling back to the thumbnail.
    static func download(_ candidate: ImageCandidate) async -> UIImage? {
        for url in [candidate.original, candidate.thumbnail].compactMap({ $0 }) {
            if let (data, _) = try? await URLSession.shared.data(from: url), let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }
}
