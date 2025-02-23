import SwiftUI
import Vision
import CoreML

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var userInput: String = ""
    @State private var messages: [Message] = [
        Message(text: "Hi! I'm ♻️ Green Kaki! Ask me where to recycle items or scan an item using the camera!", image: nil, isBot: true)
    ]
    @State private var isBotTyping = false
    
    // For ImagePicker (camera / photo library)
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingActionSheet = false
    
    // Suggestions: filter from ChatBotModel's dictionary
    var suggestions: [String] {
        let input = userInput.lowercased().trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty else { return [] }
        return ChatBotModel.recyclingData.keys.filter { $0.contains(input) }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    Text("♻️ Green Kaki")
                        .font(horizontalSizeClass == .regular ? .largeTitle : .title)
                        .fontWeight(.bold)
                        .padding(.top, geometry.size.height * 0.02)
                        .padding(.bottom, 5)
                    
                    // Chat history
                    ScrollView {
                        ScrollViewReader { proxy in
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(messages) { message in
                                    HStack {
                                        if message.isBot {
                                            // Bot side
                                            VStack(alignment: .leading) {
                                                if let image = message.image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: 200)
                                                        .cornerRadius(10)
                                                        .padding(.bottom, 2)
                                                }
                                                if let text = message.text {
                                                    Text(text)
                                                        .padding()
                                                        .background(Color.green.opacity(0.2))
                                                        .cornerRadius(15)
                                                        .shadow(radius: 1)
                                                }
                                            }
                                            Spacer()
                                        } else {
                                            // User side
                                            Spacer()
                                            VStack(alignment: .trailing) {
                                                if let image = message.image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: 200)
                                                        .cornerRadius(10)
                                                        .padding(.bottom, 2)
                                                }
                                                if let text = message.text {
                                                    Text(text)
                                                        .padding()
                                                        .background(Color.blue.opacity(0.2))
                                                        .cornerRadius(15)
                                                        .shadow(radius: 1)
                                                }
                                            }
                                        }
                                    }
                                }
                                // Typing indicator
                                if isBotTyping {
                                    HStack {
                                        Text("GreenKaki is thinking...")
                                            .italic()
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .onChange(of: messages.count) { _ in
                                if let lastId = messages.last?.id {
                                    withAnimation {
                                        proxy.scrollTo(lastId, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Suggestions bar
                    if !suggestions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button {
                                        userInput = suggestion
                                    } label: {
                                        Text(suggestion.capitalized)
                                            .padding(8)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Input area
                    HStack {
                        TextField("Type an item...", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Camera button
                        Button {
                            showingActionSheet = true
                        } label: {
                            Image(systemName: "camera")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
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
                        
                        // Send button
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    
                    // Link to Sorting Game
                    NavigationLink(destination: SortingGameView()) {
                        Text("Play Sorting Game")
                            .font(.headline)
                            .padding()
                            .background(Color.purple.opacity(0.3))
                            .cornerRadius(10)
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
        // Force full-screen style on iPad
        .navigationViewStyle(StackNavigationViewStyle())
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Sending Text
    func sendMessage() {
        let cleanedInput = userInput.trimmingCharacters(in: .whitespaces)
        guard !cleanedInput.isEmpty else { return }
        
        messages.append(Message(text: cleanedInput, image: nil, isBot: false))
        userInput = ""
        isBotTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = ChatBotModel.getResponse(for: cleanedInput)
            messages.append(Message(text: response, image: nil, isBot: true))
            isBotTyping = false
        }
    }
    
    // MARK: - Handling Image Picker
    func handleImagePicked() {
        if let img = selectedImage {
            // Show user's image in chat
            messages.append(Message(text: nil, image: img, isBot: false))
            // Classify the image
            classifySelectedImage(img)
        }
        selectedImage = nil
    }
    
    // MARK: - Image Classification
    func classifySelectedImage(_ image: UIImage) {
        // Replace 'WasteClassifier' with your actual Core ML model class name
        guard let ciImage = CIImage(image: image) else {
            messages.append(Message(text: "Could not convert image.", image: nil, isBot: true))
            return
        }
        guard let model = try? VNCoreMLModel(for: WasteClassifier().model) else {
            messages.append(Message(text: "Failed to load ML model.", image: nil, isBot: true))
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
                    messages.append(Message(text: responseText, image: nil, isBot: true))
                }
            } else {
                DispatchQueue.main.async {
                    messages.append(Message(text: "Could not classify image.", image: nil, isBot: true))
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    messages.append(Message(text: "Failed to perform classification.", image: nil, isBot: true))
                }
            }
        }
    }
}

