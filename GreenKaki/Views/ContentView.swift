import SwiftUI
import Vision
import CoreML

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var messages: [Message] = [
        Message(text: "Hi! I'm GreenKaki! Ask me where to recycle items or scan an item using the camera! ♻️", image: nil, isBot: true)
    ]
    @State private var isBotTyping = false

    // Image recognition state
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingActionSheet = false

    // Suggestions based on recycling data (from ChatBotModel)
    var suggestions: [String] {
        let input = userInput.lowercased().trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty else { return [] }
        return ChatBotModel.recyclingData.keys.filter { $0.contains(input) }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("♻️ Welcome to GreenKaki ♻️")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.top)

                // Chat history
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(messages) { message in
                                HStack {
                                    if message.isBot {
                                        // Bot messages on the left
                                        VStack(alignment: .leading) {
                                            if let image = message.image {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: 200)
                                                    .cornerRadius(10)
                                            }
                                            if let text = message.text {
                                                Text(text)
                                                    .padding()
                                                    .background(Color.green.opacity(0.2))
                                                    .cornerRadius(15)
                                                    .shadow(radius: 1)
                                            }
                                        }
                                        .padding(.horizontal)
                                        Spacer()
                                    } else {
                                        // User messages on the right
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            if let image = message.image {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: 200)
                                                    .cornerRadius(10)
                                            }
                                            if let text = message.text {
                                                Text(text)
                                                    .padding()
                                                    .background(Color.blue.opacity(0.2))
                                                    .cornerRadius(15)
                                                    .shadow(radius: 1)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            if isBotTyping {
                                HStack {
                                    Text("GreenKaki is thinking...")
                                        .italic()
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            }
                        }
                        .onChange(of: messages.count) { _ in
                            if let lastId = messages.last?.id {
                                withAnimation {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Auto-suggestion bar
                if !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button(action: { userInput = suggestion }) {
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

                // Input area: Text field with clear, send, and camera buttons
                HStack {
                    TextField("Type an item...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    if !userInput.isEmpty {
                        Button(action: { userInput = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }

                    // Send button
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    }

                    // Camera button
                    Button(action: { showingActionSheet = true }) {
                        Image(systemName: "camera")
                            .font(.title)
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
                }
                .padding(.vertical)

                // Navigation to Sorting Game
                NavigationLink(destination: SortingGameView()) {
                    Text("Play Sorting Game")
                        .font(.headline)
                        .padding()
                        .background(Color.purple.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("", displayMode: .inline)
            // Present the ImagePicker when needed
            .sheet(isPresented: $isShowingImagePicker, onDismiss: handleImagePicked) {
                ImagePicker(image: $selectedImage, sourceType: imagePickerSource)
            }
        }
    }

    // Process a text message
    func sendMessage() {
        let cleanedInput = userInput.lowercased().trimmingCharacters(in: .whitespaces)
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

    // Called when an image is picked
    func handleImagePicked() {
        if let image = selectedImage {
            // Add the uploaded image as a user message
            messages.append(Message(text: nil, image: image, isBot: false))
            // Then classify the image
            classifySelectedImage(image: image)
        }
        selectedImage = nil
    }

    // Classify the given image using the ML model and post a bot message with the result.
    // Classify the given image using the ML model and post a bot message with the result.
    func classifySelectedImage(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            messages.append(Message(text: "Could not process the image.", image: nil, isBot: true))
            return
        }
        // Replace 'WasteClassifier' with your actual model's generated class name.
        guard let model = try? VNCoreMLModel(for: WasteClassifier().model) else {
            messages.append(Message(text: "Failed to load ML model.", image: nil, isBot: true))
            return
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let firstResult = results.first {
                DispatchQueue.main.async {
                    let confidence = Int(firstResult.confidence * 100)
                    // Lowercase the prediction so it matches the keys in our dictionary.
                    let predictionKey = firstResult.identifier.lowercased()
                    // Look up the recycling instruction from our mapping dictionary.
                    let recyclingInstruction = ChatBotModel.recyclingData[predictionKey] ?? "Recycle accordingly."
                    let responseText = "This is \(firstResult.identifier.capitalized) (\(confidence)% confidence). \(recyclingInstruction)"
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

