import Foundation

struct RecyclingItem: Identifiable {
    let id = UUID()
    let name: String       // The emoji (e.g., "🥤")
    let correctBin: String // E.g., "Plastic Bin"
    let itemDescription: String // E.g., "Plastic Bottle"
}

