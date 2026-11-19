import UIKit
import Vision

enum ReceiptScanner {

    /// Runs Vision text recognition on the receipt image and parses the result.
    static func scan(_ image: UIImage) async throws -> ReceiptParser.ParsedReceipt {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ReceiptScanner", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }

        let text = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["es-ES", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: CGImagePropertyOrientation(image.imageOrientation)
            )
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }

        return ReceiptParser.parse(text)
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
