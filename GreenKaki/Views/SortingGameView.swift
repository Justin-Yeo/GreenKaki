import SwiftUI
import AVFoundation

struct SortingGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Bank of 20 items
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
    
    // Game state
    @State private var items: [RecyclingItem] = []
    @State private var score: Int = 0
    @State private var feedback: String = ""
    @State private var gameWon: Bool = false
    
    let bins = ["Plastic Bin", "Paper Bin", "Glass Bin", "Metal Bin", "Compost Bin"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    Text("♻️Green Kaki")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, geometry.size.height * 0.02)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Top Section (title, score, bins)
                    topSection(geometry: geometry)
                        .frame(maxHeight: geometry.size.height * 0.45)
                    
                    // Remove the Divider() that was here
                    
                    // Bottom Section (draggable items + feedback)
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
    
    // Top half: Title, Score, Bins
    func topSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 10) {
            Text("Recycling Sorting Game")
                .font(horizontalSizeClass == .regular ? .largeTitle : .title)
                .padding(.top, 5)
            
            Text("Score: \(score)")
                .font(.title2)
            
            // Bins in two rows: 3 in first, 2 in second
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
    
    // Bottom half: Draggable items + feedback
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
    
    // Win overlay
    var winOverlay: some View {
        Group {
            if gameWon {
                Color.black.opacity(0.8)
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
    
    // Handle dropping an emoji into a bin
    func handleDrop(for droppedEmoji: String, bin: String) {
        guard let index = items.firstIndex(where: { $0.name == droppedEmoji }) else { return }
        let item = items[index]
        if item.correctBin == bin {
            feedback = "Great job! \(item.itemDescription) belongs in \(bin)."
            score += 1
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            AudioServicesPlaySystemSound(1025)
            withAnimation {
                items.remove(at: index)
            }
            if items.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameWon = true
                }
            }
        } else {
            feedback = "Oops! \(item.itemDescription) doesn't go in \(bin)."
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            AudioServicesPlaySystemSound(1026)
        }
    }
}

// A single bin drop target
struct RecyclingBinView: View {
    let binName: String
    var onDropAction: (String, String) -> Void
    
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

