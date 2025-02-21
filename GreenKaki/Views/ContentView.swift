import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var messages: [Message] = [
        Message(text: "Hi! I’m GreenKaki! Ask me where to recycle items! ♻️", isBot: true)
    ]
    @State private var isBotTyping = false
    
    // Filter suggestions based on current user input
    var suggestions: [String] {
        let input = userInput.lowercased().trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty else { return [] }
        return ChatBotModel.recyclingData.keys.filter { $0.contains(input) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("♻️ Welcome to GreenKaki ♻️")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(1)                  // Ensures a single line
                    .minimumScaleFactor(0.5)       // Shrinks text if needed
                    .padding(.top)
                
                // Chat history area (same as Iteration 2)
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(messages) { message in
                                HStack {
                                    if message.isBot {
                                        Text(message.text)
                                            .padding()
                                            .background(Color.green.opacity(0.2))
                                            .cornerRadius(15)
                                            .shadow(radius: 1)
                                            .padding(.horizontal)
                                        Spacer()
                                    } else {
                                        Spacer()
                                        Text(message.text)
                                            .padding()
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(15)
                                            .shadow(radius: 1)
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
                
                // Suggestions view (same as Iteration 2)
                if !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button(action: {
                                    userInput = suggestion
                                }) {
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
                
                // User input area with a Clear button
                HStack {
                    TextField("Type an item...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    
                    if !userInput.isEmpty {
                        Button(action: {
                            userInput = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical)
                
                // Navigation to Sorting Game
                NavigationLink(destination: SortingGameView()) {
                    Text("Play Sorting Game")
                        .font(.headline)
                        .padding()
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
    
    func sendMessage() {
        let cleanedInput = userInput.lowercased().trimmingCharacters(in: .whitespaces)
        guard !cleanedInput.isEmpty else { return }
        
        messages.append(Message(text: cleanedInput, isBot: false))
        userInput = ""
        isBotTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = ChatBotModel.getResponse(for: cleanedInput)
            messages.append(Message(text: response, isBot: true))
            isBotTyping = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

