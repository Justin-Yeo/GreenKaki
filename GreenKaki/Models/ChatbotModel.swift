import Foundation

struct ChatBotModel {
    static let recyclingData: [String: String] = [
        // Plastic Items
        "plastic bottle": "Recycle in the Plastic Bin (rinse first!).",
        "water bottle": "Recycle in the Plastic Bin after rinsing.",
        "soda bottle": "Recycle in the Plastic Bin (rinse first!).",
        "detergent bottle": "Recycle in the Plastic Bin if empty and rinsed.",
        "plastic container": "Recycle in the Plastic Bin (ensure it's clean).",
        "lotion bottle": "Recycle in the Plastic Bin (rinse if possible).",
        "plastic cup": "Recycle in the Plastic Bin if it's clean; otherwise, check local guidelines.",
        "plastic bag": "Many stores offer recycling for plastic bags—check your local guidelines.",
        "plastic straw": "Plastic straws are often not recyclable; consider reusing or disposing in the trash.",
        "plastic wrapper": "Plastic wrappers are generally not accepted in curbside recycling. Check local guidelines.",
        "plastic utensils": "Plastic utensils are usually not recyclable in curbside programs.",
        
        // Glass Items
        "glass bottle": "Recycle in the Glass Bin.",
        "glass jar": "Recycle in the Glass Bin.",
        "broken glass": "Broken glass is dangerous and typically not recycled. Dispose of it carefully.",
        
        // Paper Items
        "newspaper": "Recycle in the Paper Bin.",
        "magazine": "Recycle in the Paper Bin.",
        "cardboard": "Recycle in the Paper Bin.",
        "paper": "Recycle in the Paper Bin.",
        "junk mail": "Recycle in the Paper Bin.",
        "book": "Recycle in the Paper Bin if damaged; otherwise, consider donating.",
        
        // Metal Items
        "aluminum can": "Recycle in the Metal Bin.",
        "soda can": "Recycle in the Metal Bin.",
        "tin can": "Recycle in the Metal Bin.",
        "can": "Recycle in the Metal Bin.",
        "metal container": "Recycle in the Metal Bin.",
        "metal lid": "Recycle in the Metal Bin.",
        
        // Compostable Items
        "pizza box": "Recycle in the Compost Bin if greasy, or in the Paper Bin if clean.",
        "food waste": "Food waste can often be composted—check local guidelines.",
        "fruit peel": "Compost the peel if possible.",
        "vegetable peel": "Compost the peel if possible.",
        
        // Non-Recyclable / Hazardous Items
        "battery": "Batteries are hazardous and not recycled in curbside programs. Please take them to a designated e-waste facility.",
        "diaper": "Diapers are not recyclable. Dispose of them in the trash.",
        "styrofoam": "Styrofoam is generally not recyclable in curbside programs.",
        "plastic wrap": "Plastic wrap is typically not accepted in recycling programs. Check local guidelines.",
        "light bulb": "Light bulbs are not recycled in regular programs. Look for special disposal options.",
        "cigarette butt": "Cigarette butts are not recyclable. Dispose of them safely.",
        "electronics": "Electronics require special recycling. Please take them to an e-waste recycling center.",
        "mirror": "Mirrors are not recycled in curbside programs. Check local guidelines."
    ]
    
    static func getResponse(for input: String) -> String {
        let cleaned = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let exact = recyclingData[cleaned] {
            return exact
        }
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

