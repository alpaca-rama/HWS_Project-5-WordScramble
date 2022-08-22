//
//  ContentView.swift
//  Project-5-WordScramble
//
//  Created by Luca Capriati on 2022/08/13.
//
// Challanges:
// Project 5 - Challange 1: Disallow answers that are shorter than three letters or are just our start word.
// Project 5 - Challange 2: Add a toolbar button that calls startGame(), so users can restart with a new word whenever they want to.
// Project 5 - Challange 3: Put a text view somewhere so you can track and show the player’s score for a given root word.
//  How you calculate score is down to you, but something involving number of words and their letter count would be reasonable.

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    // Project 5 - Challange 1
    @State private var score = 0

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                                // my own extra
                                .foregroundColor(word.count == 3 ? .red : word.count == 4 ? .orange : word.count == 5 ? .yellow : word.count == 6 ? .green : word.count == 7 ? .blue : .indigo)
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            // Project 5 - Challange 2
            .toolbar {
                Button("New Game", action: startGame)
            }
            // Project 5 - Extra
            .safeAreaInset(edge: .bottom) {
                Text("Score: \(score)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        // Project 5 - Challange 1
        guard answer.count >= 3 else {
            wordError(title: "Word too short", message: "Words must be at least three letters long.")
            return
        }
        // Project 5 - Challange 1
        guard answer != rootWord else {
            wordError(title: "Nice try...", message: "You can't user your starting word!")
            return
        }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }

        newWord = ""
        // Project 5 - Challange 3
        score += answer.count
    }

    func startGame() {
        // Project 5 - Challange 2
        newWord = ""
        usedWords.removeAll()
        // Project 5 - Challange 3
        score = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
