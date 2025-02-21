import SwiftUI
import AVFoundation

struct SortingGameView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var items: [RecyclingItem] = [
        RecyclingItem(name: "Plastic Bottle", correctBin: "Plastic Bin"),
        RecyclingItem(name: "Newspaper", correctBin: "Paper Bin"),
        RecyclingItem(name: "Glass Jar", correctBin: "Glass Bin"),
        RecyclingItem(name: "Soda Can", correctBin: "Metal Bin"),
        RecyclingItem(name: "Pizza Box", correctBin: "Compost Bin"),
        RecyclingItem(name: "Cardboard", correctBin: "Paper Bin")
    ].shuffled()
    
    @State private var score: Int = 0
    @State private var feedback: String = ""
    @State private var gameWon: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Recycling Sorting Game")
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("Score: \(score)")
                    .font(.title2)
                
                // Draggable items area
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items) { item in
                            Text(item.name)
                                .padding()
                                .background(Color.orange.opacity(0.3))
                                .cornerRadius(10)
                                .onDrag {
                                    return NSItemProvider(object: item.name as NSString)
                                }
                        }
                    }
                    .padding()
                }
                
                // Horizontally scrollable bins
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        RecyclingBinView(binName: "Plastic Bin") { droppedItem in
                            handleDrop(for: droppedItem, bin: "Plastic Bin")
                        }
                        RecyclingBinView(binName: "Paper Bin") { droppedItem in
                            handleDrop(for: droppedItem, bin: "Paper Bin")
                        }
                        RecyclingBinView(binName: "Glass Bin") { droppedItem in
                            handleDrop(for: droppedItem, bin: "Glass Bin")
                        }
                        RecyclingBinView(binName: "Metal Bin") { droppedItem in
                            handleDrop(for: droppedItem, bin: "Metal Bin")
                        }
                        RecyclingBinView(binName: "Compost Bin") { droppedItem in
                            handleDrop(for: droppedItem, bin: "Compost Bin")
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Feedback text
                Text(feedback)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.top)
                
                Spacer()
            }
            
            // Overlay win screen when game is won
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
    
    // Process drop actions and update game state
    func handleDrop(for itemName: String, bin: String) {
        if let index = items.firstIndex(where: { $0.name == itemName }) {
            let item = items[index]
            if item.correctBin == bin {
                feedback = "Great job! \(item.name) belongs in \(bin)."
                score += 1
                // Haptic feedback for success
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                AudioServicesPlaySystemSound(1025)
                withAnimation {
                    items.remove(at: index)
                }
                // Check if all items have been sorted
                if items.isEmpty {
                    // Slight delay before showing the win overlay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        gameWon = true
                    }
                }
            } else {
                feedback = "Oops! \(item.name) doesn't go in \(bin)."
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                AudioServicesPlaySystemSound(1026)
            }
        }
    }
}

struct RecyclingBinView: View {
    let binName: String
    var onDropAction: (String) -> Void
    
    var body: some View {
        VStack {
            Text(binName)
                .font(.headline)
                .padding()
                .frame(width: 100, height: 100)
                .background(Color.green.opacity(0.3))
                .cornerRadius(10)
                .onDrop(of: ["public.text"], isTargeted: nil) { providers in
                    if let provider = providers.first {
                        provider.loadObject(ofClass: NSString.self) { object, error in
                            if let item = object as? String {
                                DispatchQueue.main.async {
                                    onDropAction(item)
                                }
                            }
                        }
                        return true
                    }
                    return false
                }
        }
    }
}

