import Foundation

struct ChatBotModel {
    // Update the dictionary with specific recycling instructions.
    static let recyclingData: [String: String] = [
        "plastic bottle": "Recycle in the Plastic Bin (rinse first!).",
        "newspaper": "Recycle in the Paper Bin.",
        "glass jar": "Recycle in the Glass Bin.",
        "soda can": "Recycle in the Metal Bin.",
        "pizza box": "Recycle in the Compost Bin (if greasy) or the Paper Bin.",
        "cardboard": "Recycle in the Paper Bin.",
        "paper": "Recycle in the Paper Bin."  // Added mapping for "paper"
    ]
    
    static func getResponse(for input: String) -> String {
        let cleanedInput = input.lowercased().trimmingCharacters(in: .whitespaces)
        return recyclingData[cleanedInput] ?? "I'm not sure. Try another item!"
    }
}

