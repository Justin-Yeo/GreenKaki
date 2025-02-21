import UIKit
import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String?
    let image: UIImage?
    let isBot: Bool
}

