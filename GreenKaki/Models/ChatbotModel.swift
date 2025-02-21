import Foundation

struct ChatBotModel {
    // Load recycling data from a JSON file at runtime
    static var recyclingData: [String: String] = loadRecyclingData()
    
    static func loadRecyclingData() -> [String: String] {
        if let url = Bundle.main.url(forResource: "recyclingData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            return decoded
        }
        // Fallback data if the JSON file is missing or fails to decode
        return [
            "plastic bottle": "Plastic Bin (rinse first!)",
            "newspaper": "Paper Bin",
            "glass jar": "Glass Bin",
            "soda can": "Metal Bin",
            "pizza box": "Compost Bin (if greasy) or Paper Bin",
            "cardboard": "Paper Bin"
        ]
    }
    
    static func getResponse(for input: String) -> String {
        let cleanedInput = input.lowercased().trimmingCharacters(in: .whitespaces)
        return recyclingData[cleanedInput] ?? "Hmm, I’m not sure. Try another item!"
    }
}

