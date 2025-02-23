import Foundation

struct ChatBotModel {
    // Dictionary of recycling instructions. The keys are phrases we want to detect.
    static let recyclingData: [String: String] = [
        "plastic bottle": "Recycle in the Plastic Bin (rinse first!).",
        "newspaper": "Recycle in the Paper Bin.",
        "glass bottle": "Recycle in the Glass Bin.",
        "soda can": "Recycle in the Metal Bin.",
        "can": "Recycle in the Metal Bin.",
        "pizza box": "Recycle in the Compost Bin (if greasy)."
    ]
    
    static func getResponse(for input: String) -> String {
        // Lowercase and trim the input for consistency.
        let cleaned = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // First, try an exact match.
        if let exact = recyclingData[cleaned] {
            return exact
        }
        
        // Otherwise, iterate over the keys and check if the cleaned input contains any of the keywords.
        for (key, response) in recyclingData {
            // If the input contains the key, return the response.
            if cleaned.contains(key) {
                return response
            }
            
            // As an extra check, if the key is singular and the input uses plural (e.g. "can" vs "cans")
            // you might add additional conditions.
            if key.hasSuffix("can"), cleaned.contains("cans") {
                return response
            }
        }
        
        // If no keyword is found, return a default message.
        return "I'm not sure. Try another item!"
    }
}
