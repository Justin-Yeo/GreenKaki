import SwiftUI
import AVFoundation

struct SortingGameView: View {
    @Environment(\.presentationMode) var presentationMode

    // Bank of 20 recycling items.
    let allItems: [RecyclingItem] = [
        // ✅ Plastic Bin
        RecyclingItem(name: "🥤", correctBin: "Plastic Bin", itemDescription: "Plastic Bottle"),
        RecyclingItem(name: "🧴", correctBin: "Plastic Bin", itemDescription: "Lotion Bottle"),
        RecyclingItem(name: "🍶", correctBin: "Plastic Bin", itemDescription: "Water Bottle"),
        RecyclingItem(name: "🛍", correctBin: "Plastic Bin", itemDescription: "Plastic Bag"),
        RecyclingItem(name: "📏", correctBin: "Plastic Bin", itemDescription: "Plastic Ruler"),
        RecyclingItem(name: "🎤", correctBin: "Plastic Bin", itemDescription: "Plastic Microphone Toy"),

        // ✅ Paper Bin
        RecyclingItem(name: "📰", correctBin: "Paper Bin", itemDescription: "Newspaper"),
        RecyclingItem(name: "📦", correctBin: "Paper Bin", itemDescription: "Cardboard Box"),
        RecyclingItem(name: "✉️", correctBin: "Paper Bin", itemDescription: "Envelope"),
        RecyclingItem(name: "📜", correctBin: "Paper Bin", itemDescription: "Paper Scroll"),
        RecyclingItem(name: "📕", correctBin: "Paper Bin", itemDescription: "Book"),
        RecyclingItem(name: "📄", correctBin: "Paper Bin", itemDescription: "Loose Paper Sheet"),

        // ✅ Glass Bin
        RecyclingItem(name: "🍾", correctBin: "Glass Bin", itemDescription: "Glass Bottle"),
        RecyclingItem(name: "🏺", correctBin: "Glass Bin", itemDescription: "Glass Jar"),
        RecyclingItem(name: "🥛", correctBin: "Glass Bin", itemDescription: "Glass Cup"),
        RecyclingItem(name: "🥂", correctBin: "Glass Bin", itemDescription: "Wine Glass"),
        RecyclingItem(name: "🫙", correctBin: "Glass Bin", itemDescription: "Mason Jar"),
        RecyclingItem(name: "🍯", correctBin: "Glass Bin", itemDescription: "Honey Jar"),

        // ✅ Metal Bin
        RecyclingItem(name: "🥫", correctBin: "Metal Bin", itemDescription: "Aluminum Can"),
        RecyclingItem(name: "🔩", correctBin: "Metal Bin", itemDescription: "Bolt"),
        RecyclingItem(name: "⚙️", correctBin: "Metal Bin", itemDescription: "Gear"),
        RecyclingItem(name: "🔧", correctBin: "Metal Bin", itemDescription: "Wrench"),
        RecyclingItem(name: "🔗", correctBin: "Metal Bin", itemDescription: "Metal Chain"),
        RecyclingItem(name: "🗝", correctBin: "Metal Bin", itemDescription: "Metal Key"),
        RecyclingItem(name: "🥄", correctBin: "Metal Bin", itemDescription: "Metal Spoon"),
        RecyclingItem(name: "🛎", correctBin: "Metal Bin", itemDescription: "Small Bell"),

        // ✅ Compost Bin (Balanced, Not Increasing)
        RecyclingItem(name: "🍎", correctBin: "Compost Bin", itemDescription: "Apple Core"),
        RecyclingItem(name: "🍌", correctBin: "Compost Bin", itemDescription: "Banana Peel"),
        RecyclingItem(name: "🥬", correctBin: "Compost Bin", itemDescription: "Lettuce"),
        RecyclingItem(name: "🥕", correctBin: "Compost Bin", itemDescription: "Carrot"),
        RecyclingItem(name: "🍄", correctBin: "Compost Bin", itemDescription: "Mushroom"),
        RecyclingItem(name: "🌽", correctBin: "Compost Bin", itemDescription: "Corn Cob"),
        RecyclingItem(name: "🥑", correctBin: "Compost Bin", itemDescription: "Avocado Pit"),
    ]

    
    // Selected game items (5 items will be randomly picked).
    @State private var items: [RecyclingItem] = []
    @State private var score: Int = 0
    @State private var feedback: String = ""
    @State private var gameWon: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top half: Title, Score, and Bins arranged in two rows.
            topSection
                .frame(maxHeight: .infinity)
            
            Divider()
            
            // Bottom half: Draggable items (emojis with descriptions) and feedback.
            bottomSection
                .frame(maxHeight: .infinity)
        }
        .navigationBarTitle("", displayMode: .inline)
        .overlay(winOverlay)
        .onAppear {
            // Reset game state when the view appears
            items = Array(allItems.shuffled().prefix(5))
            score = 0
            feedback = ""
            gameWon = false
        }
    }
    
    // MARK: - Top Section (Bins)
    
    var topSection: some View {
        VStack(spacing: 10) {
            Text("Recycling Sorting Game")
                .font(.largeTitle)
                .padding(.top)
            
            Text("Score: \(score)")
                .font(.title2)
            
            // Two rows of bins: 3 in first row, 2 in second.
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    RecyclingBinView(binName: "Plastic Bin", onDropAction: handleDrop)
                    RecyclingBinView(binName: "Paper Bin", onDropAction: handleDrop)
                    RecyclingBinView(binName: "Glass Bin", onDropAction: handleDrop)
                }
                HStack(spacing: 10) {
                    RecyclingBinView(binName: "Metal Bin", onDropAction: handleDrop)
                    RecyclingBinView(binName: "Compost Bin", onDropAction: handleDrop)
                }
            }
        }
    }
    
    // MARK: - Bottom Section (Draggable Items)
    
    var bottomSection: some View {
        VStack {
            Text("Drag the item into the correct bin")
                .font(.headline)
                .padding(.top)
            
            // Use HStack with top alignment to ensure all emoji containers line up.
            HStack(alignment: .top, spacing: 20) {
                ForEach(items) { item in
                    VStack(spacing: 5) {
                        // Fixed container for the emoji.
                        Text(item.name)
                            .font(.system(size: 40))
                            .frame(width: 60, height: 60)
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(10)
                            .onDrag { NSItemProvider(object: item.name as NSString) }
                        // Description flows below.
                        Text(item.itemDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            Spacer()
            Text(feedback)
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
        }
    }
    
    // MARK: - Win Overlay
    
    var winOverlay: some View {
        Group {
            if gameWon {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Text("Congratulations!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("You have correctly sorted all of the items!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Go Home")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.7))
                .cornerRadius(20)
                .padding()
            }
        }
    }
    
    // MARK: - Drop Handling
    
    /// Called when an emoji is dropped into a bin.
    /// - Parameters:
    ///   - droppedEmoji: The emoji string dropped.
    ///   - bin: The name of the bin where the emoji was dropped.
    func handleDrop(for droppedEmoji: String, bin: String) {
        guard let index = items.firstIndex(where: { $0.name == droppedEmoji }) else { return }
        let item = items[index]
        if item.correctBin == bin {
            feedback = "Great job! \(item.itemDescription) belongs in \(bin)."
            score += 1
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            AudioServicesPlaySystemSound(1025)
            withAnimation { items.remove(at: index) }
            if items.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { gameWon = true }
            }
        } else {
            feedback = "Oops! \(item.itemDescription) doesn't go in \(bin)."
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            AudioServicesPlaySystemSound(1026)
        }
    }
}

// MARK: - RecyclingBinView

struct RecyclingBinView: View {
    let binName: String
    var onDropAction: (String, String) -> Void  // (droppedEmoji, binName)
    
    var body: some View {
        VStack {
            Text(binName)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
            // Bin drop area using a bin emoji.
            Text("🗑️")
                .font(.system(size: 50))
                .padding()
                .background(Color.green.opacity(0.3))
                .cornerRadius(10)
                .onDrop(of: ["public.text"], isTargeted: nil) { providers in
                    if let provider = providers.first {
                        provider.loadObject(ofClass: NSString.self) { object, error in
                            if let emoji = object as? String {
                                DispatchQueue.main.async {
                                    onDropAction(emoji, binName)
                                }
                            }
                        }
                        return true
                    }
                    return false
                }
        }
        .padding()
    }
}

struct SortingGameView_Previews: PreviewProvider {
    static var previews: some View {
        SortingGameView()
    }
}

