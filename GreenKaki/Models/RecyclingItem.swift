import Foundation

struct RecyclingItem: Identifiable {
    let id = UUID()
    let name: String
    let correctBin: String
    let itemDescription: String 
}

