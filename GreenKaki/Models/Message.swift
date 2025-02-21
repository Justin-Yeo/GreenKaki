import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isBot: Bool // true if the message is from the bot, false if from the user
}

