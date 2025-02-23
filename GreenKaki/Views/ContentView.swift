import SwiftUI
import Vision
import CoreML

// Custom button style for subtle scaling effect
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var userInput: String = ""
    @State private var messages: [Message] = [
        Message(text: "Hi! I'm ♻️ Green Kaki! Ask me where to recycle items or scan an item using the camera!", image: nil, isBot: true)
    ]
    @State private var isBotTyping = false
    
    // For ImagePicker
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingActionSheet = false
    
    // Suggestions based on ChatBotModel keywords
    var suggestions: [String] {
        let input = userInput.lowercased().trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty else { return [] }
        return ChatBotModel.recyclingData.keys.filter { $0.contains(input) }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header with gradient background
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
                    
                    // Chat history
                    ScrollView {
                        ScrollViewReader { proxy in
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(messages) { message in
                                    if message.isBot {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                if let image = message.image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: geometry.size.width * 0.6)
                                                        .cornerRadius(10)
                                                }
                                                if let text = message.text {
                                                    Text(text)
                                                        .padding()
                                                        .background(Color.green.opacity(0.2))
                                                        .cornerRadius(15)
                                                        .shadow(radius: 2)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .transition(.move(edge: .leading).combined(with: .opacity))
                                    } else {
                                        HStack {
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                if let image = message.image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: geometry.size.width * 0.6)
                                                        .cornerRadius(10)
                                                }
                                                if let text = message.text {
                                                    Text(text)
                                                        .padding()
                                                        .background(Color.blue.opacity(0.2))
                                                        .cornerRadius(15)
                                                        .shadow(radius: 2)
                                                }
                                            }
                                        }
                                        .transition(.move(edge: .trailing).combined(with: .opacity))
                                    }
                                }
                                if isBotTyping {
                                    HStack {
                                        Text("Green Kaki is thinking...")
                                            .italic()
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .onChange(of: messages.count) { _ in
                                if let lastId = messages.last?.id {
                                    withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                                }
                            }
                        }
                    }
                    
                    // Suggestions Bar
                    if !suggestions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button(action: { userInput = suggestion }) {
                                        Text(suggestion.capitalized)
                                            .font(.caption)
                                            .padding(8)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Input area with TextField, camera, and send button
                    HStack(spacing: 12) {
                        TextField("Type an item...", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button {
                            showingActionSheet = true
                        } label: {
                            Image(systemName: "camera")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .actionSheet(isPresented: $showingActionSheet) {
                            ActionSheet(title: Text("Choose Image Source"), buttons: [
                                .default(Text("Camera")) {
                                    imagePickerSource = .camera
                                    isShowingImagePicker = true
                                },
                                .default(Text("Photo Library")) {
                                    imagePickerSource = .photoLibrary
                                    isShowingImagePicker = true
                                },
                                .cancel()
                            ])
                        }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    .padding()
                    
                    // Navigation to Sorting Game
                    NavigationLink(destination: SortingGameView().transition(.move(edge: .trailing))) {
                        Text("Play Sorting Game")
                            .font(.headline)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.purple]),
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
                .navigationBarHidden(true)
                .sheet(isPresented: $isShowingImagePicker, onDismiss: handleImagePicked) {
                    ImagePicker(image: $selectedImage, sourceType: imagePickerSource)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .edgesIgnoringSafeArea(.all)
    }
    
    func sendMessage() {
        let trimmed = userInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(Message(text: trimmed, image: nil, isBot: false))
        }
        userInput = ""
        isBotTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                let response = ChatBotModel.getResponse(for: trimmed)
                messages.append(Message(text: response, image: nil, isBot: true))
            }
            isBotTyping = false
        }
    }
    
    func handleImagePicked() {
        if let img = selectedImage {
            withAnimation(.easeInOut(duration: 0.3)) {
                messages.append(Message(text: nil, image: img, isBot: false))
            }
            classifySelectedImage(img)
        }
        selectedImage = nil
    }
    
    func classifySelectedImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            withAnimation { messages.append(Message(text: "Could not convert image.", image: nil, isBot: true)) }
            return
        }
        // Replace 'WasteClassifier' with your actual Core ML model name.
        guard let model = try? VNCoreMLModel(for: WasteClassifier().model) else {
            withAnimation { messages.append(Message(text: "Failed to load ML model.", image: nil, isBot: true)) }
            return
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let first = results.first {
                DispatchQueue.main.async {
                    let confidence = Int(first.confidence * 100)
                    let prediction = first.identifier
                    let info = ChatBotModel.recyclingData[prediction.lowercased()] ?? "Recycle accordingly."
                    let responseText = "This is \(prediction) (\(confidence)% confidence). \(info)"
                    withAnimation {
                        messages.append(Message(text: responseText, image: nil, isBot: true))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    withAnimation {
                        messages.append(Message(text: "Could not classify image.", image: nil, isBot: true))
                    }
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    withAnimation {
                        messages.append(Message(text: "Failed to perform classification.", image: nil, isBot: true))
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().previewDevice("iPhone 15 Pro")
            ContentView().previewDevice("iPad Pro (12.9-inch)")
        }
    }
}

