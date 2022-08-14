//
//  ContentView.swift
//  Project-5-WordScramble
//
//  Created by Luca Capriati on 2022/08/13.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var isErrorShowing = false
    // Challange 3
    @State private var score = 0
    // Challange 3 - My Addition
    @State private var scoreAddedAmount = 0
    
    private let minWordSize = 3
    
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
//                                .foregroundColor(wordScoreColor == "blue" ? .red : .black)
                                .foregroundColor(word.count == 3 ? .red : word.count == 4 ? .red : word.count == 5 ? .blue : word.count == 6 ? .blue : word.count == 7 ? .green : word.count == 8 ? .indigo : .black)
                            Text(word)
                        }
                    }
                }
                
                Section() {
                    HStack {
                        Text("Score: \(score)")
                            .font(.title)
                        // My own added code
                        Text("(+\(scoreAddedAmount))")
                            .foregroundColor(scoreAddedAmount == 1 ? .red : scoreAddedAmount == 2 ? .blue : scoreAddedAmount == 3 ? .green : scoreAddedAmount == 10 ? .indigo : .white)
                            
                    }
                    
                }
            }
            // Challange 2
            .toolbar {
                Button("Restart", action: startGame)
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $isErrorShowing) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            wordError(title: "No word entered", message: "There must be characters entered (Minimum of 3 charaters)")
            return
        }
        
        // Challange 1
        guard isLongEnough(word: answer) else {
            wordError(title: "Word is too short", message: "The word must be 3 or more characters.")
            return
        }
        
        // Challange 1
        guard isNotStartingWord(word: answer) else {
            wordError(title: "Same as starting word", message: "The word cannot be the starting word, '\(rootWord)'")
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
            wordError(title: "Word not recognised", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        updateScore(word: answer)
        
        newWord = ""
    }
    
    func startGame() {
        // Challange 2
        withAnimation {
            usedWords.removeAll()
        }
        // My added code
        scoreAddedAmount = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
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
    
    // Challange 1
    func isLongEnough(word: String) -> Bool {
        return word.count >= minWordSize
    }
    
    // Challange 1
    func isNotStartingWord(word: String) -> Bool {
        return word != rootWord
    }
    
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        isErrorShowing = true
    }
    
    func updateScore(word: String) {
        switch word.count {
        case 3...4:
            scoreAddedAmount = 1
            score += scoreAddedAmount
        case 5:
            scoreAddedAmount = 2
            score += scoreAddedAmount
        case 6...7:
            scoreAddedAmount = 3
            score += scoreAddedAmount
        case 8:
            scoreAddedAmount = 10
            score += scoreAddedAmount
        default:
            scoreAddedAmount = 0
            score += scoreAddedAmount
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
