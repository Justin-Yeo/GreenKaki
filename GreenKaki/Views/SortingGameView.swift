import SwiftUI
import AVFoundation

struct SortingGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Bank of 20 recycling items.
    let allItems: [RecyclingItem] = [
        RecyclingItem(name: "🥤", correctBin: "Plastic Bin", itemDescription: "Plastic Bottle"),
        RecyclingItem(name: "🧴", correctBin: "Plastic Bin", itemDescription: "Lotion Bottle"),
        RecyclingItem(name: "🍶", correctBin: "Plastic Bin", itemDescription: "Water Bottle"),
        RecyclingItem(name: "📰", correctBin: "Paper Bin", itemDescription: "Newspaper"),
        RecyclingItem(name: "📦", correctBin: "Paper Bin", itemDescription: "Cardboard Box"),
        RecyclingItem(name: "✉️", correctBin: "Paper Bin", itemDescription: "Envelope"),
        RecyclingItem(name: "🍾", correctBin: "Glass Bin", itemDescription: "Glass Bottle"),
        RecyclingItem(name: "🏺", correctBin: "Glass Bin", itemDescription: "Jar"),
        RecyclingItem(name: "🥫", correctBin: "Metal Bin", itemDescription: "Can"),
        RecyclingItem(name: "🔩", correctBin: "Metal Bin", itemDescription: "Bolt"),
        RecyclingItem(name: "⚙️", correctBin: "Metal Bin", itemDescription: "Gear"),
        RecyclingItem(name: "🍕", correctBin: "Compost Bin", itemDescription: "Pizza Box"),
        RecyclingItem(name: "🍎", correctBin: "Compost Bin", itemDescription: "Apple Core"),
        RecyclingItem(name: "🍌", correctBin: "Compost Bin", itemDescription: "Banana Peel"),
        RecyclingItem(name: "🥬", correctBin: "Compost Bin", itemDescription: "Lettuce"),
        RecyclingItem(name: "🥕", correctBin: "Compost Bin", itemDescription: "Carrot"),
        RecyclingItem(name: "🍄", correctBin: "Compost Bin", itemDescription: "Mushroom"),
        RecyclingItem(name: "🌽", correctBin: "Compost Bin", itemDescription: "Corn Cob"),
        RecyclingItem(name: "🥑", correctBin: "Compost Bin", itemDescription: "Avocado Pit"),
        RecyclingItem(name: "🍇", correctBin: "Compost Bin", itemDescription: "Grapes")
    ]
    
    // Game state: 5 random items.
    @State private var items: [RecyclingItem] = []
    @State private var score: Int = 0
    @State private var feedback: String = ""
    @State private var gameWon: Bool = false
    
    let bins = ["Plastic Bin", "Paper Bin", "Glass Bin", "Metal Bin", "Compost Bin"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header with gradient background.
                    ZStack {
                        // Gradient that starts at the top edge and fills 120 points of height
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 100)
                        
                        // The header text centered within the gradient
                        Text("♻️ Green Kaki")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity)


                    // Top Section: Title, Score, and Bins.
                    topSection(geometry: geometry)
                        .frame(maxHeight: geometry.size.height * 0.45)
                    
                    // Bottom Section: Draggable Items & Feedback.
                    bottomSection
                        .frame(maxHeight: geometry.size.height * 0.45)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
                .onAppear {
                    items = Array(allItems.shuffled().prefix(5))
                    score = 0
                    feedback = ""
                    gameWon = false
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .edgesIgnoringSafeArea(.all)
        .overlay(winOverlay)
    }
    
    // Top Section: Title, Score, and Bins arranged in two rows.
    func topSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 10) {
            Text("Recycling Sorting Game")
                .font(horizontalSizeClass == .regular ? .largeTitle : .title)
                .padding(.top, 5)
            Text("Score: \(score)")
                .font(.title2)
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ForEach(bins.prefix(3), id: \.self) { bin in
                        RecyclingBinView(binName: bin, onDropAction: handleDrop)
                            .frame(maxWidth: .infinity)
                    }
                }
                HStack(spacing: 10) {
                    ForEach(bins.suffix(2), id: \.self) { bin in
                        RecyclingBinView(binName: bin, onDropAction: handleDrop)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Bottom Section: Draggable Items with Descriptions and Feedback.
    var bottomSection: some View {
        VStack {
            Text("Drag the item into the correct bin")
                .font(.headline)
                .padding(.top)
            HStack(alignment: .top, spacing: 20) {
                ForEach(items) { item in
                    VStack(spacing: 5) {
                        Text(item.name)
                            .font(.system(size: 40))
                            .frame(width: 60, height: 60)
                            .background(Color.orange.opacity(0.3))
                            .cornerRadius(10)
                            .onDrag { NSItemProvider(object: item.name as NSString) }
                        Text(item.itemDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
            Text(feedback)
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
        }
    }
    
    // Win Overlay: Displays when game is won.
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
    
    // Handle drop action for a recycling item.
    func handleDrop(for droppedEmoji: String, bin: String) {
        guard let index = items.firstIndex(where: { $0.name == droppedEmoji }) else { return }
        let item = items[index]
        if item.correctBin == bin {
            feedback = "Great job! \(item.itemDescription) belongs in \(bin)."
            score += 1
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            AudioServicesPlaySystemSound(1025)
            withAnimation(.spring()) { items.remove(at: index) }
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

struct RecyclingBinView: View {
    let binName: String
    var onDropAction: (String, String) -> Void  // (droppedEmoji, binName)
    
    var body: some View {
        VStack {
            Text(binName)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
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
        Group {
            SortingGameView().previewDevice("iPhone 15 Pro")
            SortingGameView().previewDevice("iPad Pro (12.9-inch)")
        }
    }
}

