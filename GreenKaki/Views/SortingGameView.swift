import SwiftUI
import AVFoundation

struct SortingGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let allItems: [RecyclingItem] = [
        RecyclingItem(name: "🥤", correctBin: "Plastic Bin", itemDescription: "Plastic Cup"),
        RecyclingItem(name: "🧴", correctBin: "Plastic Bin", itemDescription: "Lotion Bottle"),
        RecyclingItem(name: "🛍", correctBin: "Plastic Bin", itemDescription: "Plastic Bag"),
        RecyclingItem(name: "📏", correctBin: "Plastic Bin", itemDescription: "Plastic Ruler"),
        RecyclingItem(name: "🎤", correctBin: "Plastic Bin", itemDescription: "Plastic Microphone Toy"),

        RecyclingItem(name: "📰", correctBin: "Paper Bin", itemDescription: "Newspaper"),
        RecyclingItem(name: "📦", correctBin: "Paper Bin", itemDescription: "Cardboard Box"),
        RecyclingItem(name: "✉️", correctBin: "Paper Bin", itemDescription: "Envelope"),
        RecyclingItem(name: "📜", correctBin: "Paper Bin", itemDescription: "Paper Scroll"),
        RecyclingItem(name: "📕", correctBin: "Paper Bin", itemDescription: "Book"),
        RecyclingItem(name: "📄", correctBin: "Paper Bin", itemDescription: "Loose Paper Sheet"),

        RecyclingItem(name: "🍾", correctBin: "Glass Bin", itemDescription: "Glass Bottle"),
        RecyclingItem(name: "🏺", correctBin: "Glass Bin", itemDescription: "Glass Jar"),
        RecyclingItem(name: "🥛", correctBin: "Glass Bin", itemDescription: "Glass Cup"),
        RecyclingItem(name: "🥂", correctBin: "Glass Bin", itemDescription: "Wine Glass"),
        RecyclingItem(name: "🫙", correctBin: "Glass Bin", itemDescription: "Mason Jar"),
        RecyclingItem(name: "🍯", correctBin: "Glass Bin", itemDescription: "Honey Jar"),

        RecyclingItem(name: "🥫", correctBin: "Metal Bin", itemDescription: "Aluminum Can"),
        RecyclingItem(name: "🔩", correctBin: "Metal Bin", itemDescription: "Bolt"),
        RecyclingItem(name: "⚙️", correctBin: "Metal Bin", itemDescription: "Gear"),
        RecyclingItem(name: "🔧", correctBin: "Metal Bin", itemDescription: "Wrench"),
        RecyclingItem(name: "🔗", correctBin: "Metal Bin", itemDescription: "Metal Chain"),
        RecyclingItem(name: "🗝", correctBin: "Metal Bin", itemDescription: "Metal Key"),
        RecyclingItem(name: "🥄", correctBin: "Metal Bin", itemDescription: "Metal Spoon"),
        RecyclingItem(name: "🛎", correctBin: "Metal Bin", itemDescription: "Small Bell"),

        RecyclingItem(name: "🍎", correctBin: "Compost Bin", itemDescription: "Apple Core"),
        RecyclingItem(name: "🍌", correctBin: "Compost Bin", itemDescription: "Banana Peel"),
        RecyclingItem(name: "🥬", correctBin: "Compost Bin", itemDescription: "Lettuce"),
        RecyclingItem(name: "🥕", correctBin: "Compost Bin", itemDescription: "Carrot"),
        RecyclingItem(name: "🍄", correctBin: "Compost Bin", itemDescription: "Mushroom"),
        RecyclingItem(name: "🌽", correctBin: "Compost Bin", itemDescription: "Corn Cob"),
        RecyclingItem(name: "🥑", correctBin: "Compost Bin", itemDescription: "Avocado Pit"),
    ]

    
    @State private var items: [RecyclingItem] = []
    @State private var score: Int = 0
    @State private var feedback: String = ""
    @State private var gameWon: Bool = false
    
    let bins = ["Plastic Bin", "Paper Bin", "Glass Bin", "Metal Bin", "Compost Bin"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 75)
                        Text("♻️ Green Kaki")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    topSection(geometry: geometry)
                        .frame(maxHeight: geometry.size.height * 0.45)
                    
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
    
    var winOverlay: some View {
        Group {
            if gameWon {
                ZStack {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.yellow)
                            .shadow(radius: 5)
                        
                        Text("Congratulations!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                        
                        Text("You have correctly sorted all of the items!")
                            .font(.system(size: 20, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Go Home")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.85))
                            .shadow(radius: 10)
                    )
                    .padding(.horizontal, 40)
                }
            }
        }
    }

    
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

struct SortingGameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SortingGameView().previewDevice("iPhone 15 Pro")
            SortingGameView().previewDevice("iPad Pro (12.9-inch)")
        }
    }
}

