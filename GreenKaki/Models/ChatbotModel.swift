import Foundation

struct ChatBotModel {
    // Recycling instructions (keywords for fuzzy matching)
    static let recyclingData: [String: String] = [
        "plastic bottle": "Recycle in the Plastic Bin (rinse first!).",
        "newspaper": "Recycle in the Paper Bin.",
        "glass bottle": "Recycle in the Glass Bin.",
        "soda can": "Recycle in the Metal Bin.",
        "can": "Recycle in the Metal Bin.",
        "pizza box": "Recycle in the Compost Bin (if greasy)."
    ]
    
    static func getResponse(for input: String) -> String {
        let cleaned = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // Try exact match first.
        if let exact = recyclingData[cleaned] {
            return exact
        }
        // Fuzzy match by checking if input contains any key.
        for (key, response) in recyclingData {
            if cleaned.contains(key) {
                return response
            }
            if key.hasSuffix("can"), cleaned.contains("cans") {
                return response
            }
        }
        return "Hmm, I'm not sure. Try another item!"
    }
}

